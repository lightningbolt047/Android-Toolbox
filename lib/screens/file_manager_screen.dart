import 'dart:io';
import 'package:adb_gui/components/file_transfer_progress.dart';
import 'package:adb_gui/components/icon_name_material_button.dart';
import 'package:adb_gui/components/simple_file_transfer_progress.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:adb_gui/models/device.dart';
import 'package:adb_gui/services/android_api_checks.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/vars.dart';

class FileManagerScreen extends StatefulWidget {
  final Device device;
  const FileManagerScreen({Key? key, required this.device}) : super(key: key);

  @override
  _FileManagerScreenState createState() => _FileManagerScreenState(device);
}

class _FileManagerScreenState extends State<FileManagerScreen> {

  final Device device;

  final List<FileTransferJob> _fileTransferJobs = [];
  int _totalJobCount = 0;

  _FileManagerScreenState(this.device);

  String _currentPath = "/sdcard/";
  final TextEditingController _addressBarEditingController =
      TextEditingController();
  final TextEditingController _renameFieldController = TextEditingController();

  final _addressBarFocus = FocusNode();
  final _renameItemFocus = FocusNode();

  Future<List<Item>> getDirectoryContents() async {
    ProcessResult result;
    if(isLegacyAndroid(device.androidAPILevel)){
      result=await Process.run(adbExecutable, ["-s", device.id, "shell", "ls", "\"$_currentPath\""]);
    }else{
      result=await Process.run(adbExecutable, ["-s", device.id, "shell", "ls","-p", "\"$_currentPath\""]);
    }
    // result=await Process.run(adbExecutable, ["-s", deviceID, "shell", "ls","-p", "\"$_currentPath\""]);
    List<String> directoryContentDetails = (result.stdout).split("\n");
    directoryContentDetails.removeLast();
    List<Item> directoryItems=[];
    for(int i=0;i<directoryContentDetails.length;i++){
      directoryContentDetails[i]=directoryContentDetails[i].trim();
      directoryItems.add(Item(directoryContentDetails[i].trim().endsWith("/")?directoryContentDetails[i].replaceAll("/", "").trim():directoryContentDetails[i].trim(),await getFileType(directoryContentDetails[i].trim())));
    }
    return directoryItems;
  }

  void addFileTransferJob(FileTransferType fileTransferType, String itemName) {
    FileTransferJob newJob =
        FileTransferJob(fileTransferType, _currentPath + itemName, itemName);

    for (int i = 0; i < _fileTransferJobs.length; i++) {
      if (_fileTransferJobs[i].checkSameItem(newJob)) {
        if (_fileTransferJobs[i].jobType == newJob.jobType) {
          return;
        }
        setState(() {
          _fileTransferJobs[i] = newJob;
        });
        return;
      }
    }
    setState(() {
      if (_fileTransferJobs.length < 4) {
        _fileTransferJobs.add(newJob);
      } else {
        _fileTransferJobs[(_totalJobCount) % 4] = newJob;
      }
      _totalJobCount++;
    });
  }

  void addPath(String fileItemName) async {
    if (await findFileItemType(fileItemName) == FileContentTypes.file) {
      return;
    }
    setState(() {
      _renameFieldController.text="";
      if (_currentPath[_currentPath.length - 1] != "/") {
        _currentPath += "/";
      }
      _currentPath += fileItemName + "/";
      _addressBarEditingController.text = _currentPath;
    });
  }

  void removePath() {
    List<String> directories = _currentPath.split("/");
    if (_currentPath == "/") {
      return;
    }
    String newPath = "";
    int toRemove = _currentPath[_currentPath.length - 1] == "/" ? 2 : 1;
    for (int i = 0; i < directories.length - toRemove; i++) {
      newPath += directories[i] + "/";
    }
    setState(() {
      _currentPath = newPath;
      _addressBarEditingController.text = _currentPath;
    });
  }

  void deleteItem(String itemName, BuildContext context) async {
    ProcessResult result = await Process.run(adbExecutable, [
      "-s",
      device.id,
      "shell",
      "rm",
      "-r",
      "\"${_currentPath + itemName}\""
    ]);
    if (result.exitCode == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$itemName deleted successfully")));
      ScaffoldMessenger.of(context).deactivate();
      setState(() {});
    }
  }

  void uploadContent(FileUploadType uploadType) async {
    String? sourcePath = "";
    if (uploadType == FileUploadType.file) {
      FilePickerResult? filePicker = await FilePicker.platform.pickFiles();
      sourcePath = filePicker?.files.single.path;
    } else {
      sourcePath = await FilePicker.platform.getDirectoryPath();
    }
    if (sourcePath == null) {
      return;
    }
    Process process = await Process.start(
      adbExecutable,
      ["-s", device.id, "push", sourcePath, _currentPath],
    );
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => FileTransferProgress(process: process));
    setState(() {});
    // Process.runSync("adb", ["pull",(_currentPath[_currentPath.length-1]=="/"?_currentPath:_currentPath+"/")+itemName,chosenDirectory]);
  }

  void transferFile(FileTransferType fileTransferType, int index,
      BuildContext context) async {
    Process process;

    if (fileTransferType == FileTransferType.move) {
      process = await Process.start(adbExecutable, [
        "-s",
        device.id,
        "shell",
        "mv",
        "\"${_fileTransferJobs[index].itemPath}\"",
        "\"$_currentPath\""
      ]);
    } else {
      process = await Process.start(adbExecutable, [
        "-s",
        device.id,
        "shell",
        "cp",
        "-r",
        "\"${_fileTransferJobs[index].itemPath}\"",
        "\"$_currentPath\""
      ]);
    }

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SimpleFileTransferProgress(
              process: process,
              fileTransferType: fileTransferType,
            ));
    setState(() {
      _fileTransferJobs.removeAt(index);
    });
  }

  void renameItem(String itemName,String newName) async {
    if(itemName==newName){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("New name cannot be the same as old name")));
      ScaffoldMessenger.of(context).deactivate();
      return;
    }else if(newName.endsWith(" ") || newName.endsWith("\r") || newName.endsWith(" \r") || newName.endsWith("\r ")){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Name")));
      Scaffold.of(context).deactivate();
    }

    ProcessResult result = await Process.run(adbExecutable, [
      "-s",
      device.id,
      "shell",
      "mv",
      "\"${_currentPath + itemName}\"",
      "\"${_currentPath + newName}\""
    ]);

    if (result.exitCode == 0) {
      setState(() {
        _renameFieldController.text="";
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Renamed $itemName to $newName")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Failed to rename! Check if new name is valid! It must not contain spaces or special characters")));
    }
  }

  Future<FileContentTypes> findFileItemType(String fileItemName) async {
    ProcessResult result = await Process.run(adbExecutable, [
      "-s",
      device.id,
      "shell",
      "ls",
      "\"$_currentPath" + fileItemName + "\""
    ]);

    if (result.stdout.split("\r\n")[0] == _currentPath + fileItemName) {
      return FileContentTypes.file;
    }
    return FileContentTypes.directory;
  }

  void downloadContent(String itemName) async {
    String? chosenDirectory = await FilePicker.platform.getDirectoryPath();

    if (chosenDirectory == null) {
      return;
    }
    Process process = await Process.start(adbExecutable,
        ["-s", device.id, "pull", _currentPath + itemName, chosenDirectory]);
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => FileTransferProgress(process: process));
    setState(() {});
  }

  // String getPathStringFromDirectoryStack(){
  //   String pathString="/";
  //   for(int i=0;i<_directoryStack.length;i++){
  //     pathString+=_directoryStack[i]+"/";
  //   }
  //   return pathString;
  // }

  Future<FileContentTypes> getFileType(String fileName) async {
    bool isLegacyAndroidFile=false;
    if(isLegacyAndroid(device.androidAPILevel)){
      ProcessResult result=await Process.run(adbExecutable,["-s",device.id,"shell","ls","\"${_currentPath+fileName}\""]);
      // print(result.stdout.toString().trim().contains(_currentPath+fileName));
      if(result.stdout.toString().trim().contains(_currentPath+fileName)){
        isLegacyAndroidFile=true;
      }
    }
    String fileExtension = fileName.split(".").last;
    if(fileName!="sdcard" && (isLegacyAndroidFile || (!isLegacyAndroid(device.androidAPILevel) && !fileName.endsWith("/")))){
      if (fileExtension == "pdf") {
        return FileContentTypes.pdf;
      } else if (fileExtension == "zip" ||
          fileExtension == "tar" ||
          fileExtension == "gz" ||
          fileExtension == "rar" ||
          fileExtension == "7z") {
        return FileContentTypes.archive;
      } else if (fileExtension == "apk") {
        return FileContentTypes.apk;
      } else if (fileExtension == "doc" ||
          fileExtension == "txt" ||
          fileExtension == "docx" ||
          fileExtension == "odt" ||
          fileExtension == "ppt" ||
          fileExtension == "pptx" ||
          fileExtension == "xls" ||
          fileExtension == "xlsx" ||
          fileExtension == "csv") {
        return FileContentTypes.document;
      } else if (fileExtension == "png" ||
          fileExtension == "jpg" ||
          fileExtension == "jpeg" ||
          fileExtension == "gif" ||
          fileExtension == "raw") {
        return FileContentTypes.image;
      } else if (fileExtension == "mp4" ||
          fileExtension == "mkv" ||
          fileExtension == "webm" ||
          fileExtension == "mpeg") {
        return FileContentTypes.video;
      } else if (fileExtension == "mp3" ||
          fileExtension == "wma" ||
          fileExtension == "flac" ||
          fileExtension == "wav" ||
          fileExtension == "ogg") {
        return FileContentTypes.audio;
      } else if (fileExtension == "torrent") {
          return FileContentTypes.torrent;
      } else if (fileExtension == "cer") {
          return FileContentTypes.securityCertificate;
      }
      return FileContentTypes.file;
    }

    return FileContentTypes.directory;
  }

  void updatePathFromTextField(String value) {
    setState(() {
      if (value.isEmpty) {
        _currentPath = "/";
        _addressBarEditingController.text = "/";
        return;
      }
      _currentPath = value[value.length - 1] == "/" ? value : value + "/";
      _addressBarEditingController.text = _currentPath;
    });
    _addressBarFocus.previousFocus();
  }

  IconData getFileIconByType(FileContentTypes fileType) {
    // FileContentTypes fileType = getFileType(fileName);
    if (fileType == FileContentTypes.pdf) {
      return FontAwesomeIcons.filePdf;
    } else if (fileType == FileContentTypes.document) {
      return FontAwesomeIcons.fileWord;
    } else if (fileType == FileContentTypes.image) {
      return FontAwesomeIcons.fileImage;
    } else if (fileType == FileContentTypes.video) {
      return FontAwesomeIcons.fileVideo;
    } else if (fileType == FileContentTypes.audio) {
      return FontAwesomeIcons.fileAudio;
    } else if (fileType == FileContentTypes.apk) {
      return FontAwesomeIcons.android;
    } else if (fileType == FileContentTypes.archive) {
      return FontAwesomeIcons.fileArchive;
    } else if (fileType == FileContentTypes.torrent) {
      return FontAwesomeIcons.magnet;
    } else if (fileType == FileContentTypes.securityCertificate) {
      return FontAwesomeIcons.key;
    } else if(fileType == FileContentTypes.file){
      return FontAwesomeIcons.file;
    }
    return FontAwesomeIcons.folder;
  }

  @override
  void initState() {
    _addressBarEditingController.text = _currentPath;
    super.initState();
  }

  @override
  void dispose() {
    _renameFieldController.dispose();
    _addressBarEditingController.dispose();
    _addressBarFocus.dispose();
    _renameItemFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
            builder: (context, constraints) => Column(
                  children: [
                    Container(
                      color: Colors.grey[200],
                      width: constraints.maxWidth,
                      height: 45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: Colors.blueGrey,
                            splashRadius: 1,
                            onPressed: () {
                              removePath();
                            },
                          ),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 4),
                            child: TextField(
                              controller: _addressBarEditingController,
                              focusNode: _addressBarFocus,
                              textAlign: TextAlign.left,
                              textAlignVertical: TextAlignVertical.top,
                              maxLines: 1,
                              onSubmitted: updatePathFromTextField,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.zero),
                                focusColor: Colors.blue,
                                suffixIcon: _addressBarFocus.hasFocus
                                    ? IconButton(
                                        icon: const Icon(
                                            Icons.arrow_forward_rounded),
                                        hoverColor: Colors.transparent,
                                        splashRadius: 1,
                                        splashColor: Colors.transparent,
                                        onPressed: () {
                                          updatePathFromTextField(
                                              _addressBarEditingController
                                                  .text);
                                        },
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.refresh),
                                        hoverColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        splashRadius: 1,
                                        onPressed: () {
                                          setState(() {});
                                        },
                                      ),
                              ),
                            ),
                          )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PopupMenuButton(
                              child: Row(
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.upload,
                                    color: Colors.blue,
                                  ),
                                  SizedBox.fromSize(
                                    size: const Size(4, 0),
                                  ),
                                  const Text(
                                    "Upload Items",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.blue),
                                  ),
                                ],
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Icon(
                                        FontAwesomeIcons.fileUpload,
                                        color: Colors.blue,
                                      ),
                                      Text(
                                        "Upload File",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    uploadContent(FileUploadType.file);
                                  },
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Icon(
                                        FontAwesomeIcons.folderPlus,
                                        color: Colors.blue,
                                      ),
                                      Text(
                                        "Upload Folder",
                                        style: TextStyle(color: Colors.blue),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    uploadContent(FileUploadType.directory);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_fileTransferJobs.isNotEmpty)
                      Container(
                        color: Colors.grey[200],
                        width: constraints.maxWidth,
                        height: 45,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            for (int i = 0; i < _fileTransferJobs.length; i++)
                              ClipboardChip(
                                itemName: _fileTransferJobs[i].itemName,
                                jobIndex: i,
                                fileTransferType: _fileTransferJobs[i].jobType,
                                transferFile: transferFile,
                                parentContext: context,
                              ),
                            const Spacer(),
                            IconNameMaterialButton(
                                icon: const Icon(
                                  Icons.clear_all_rounded,
                                  size: 35,
                                  color: Colors.blueGrey,
                                ),
                                text: const Text(
                                  "Clear",
                                  style: TextStyle(
                                      color: Colors.blueGrey, fontSize: 20),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _totalJobCount = 0;
                                    _fileTransferJobs.clear();
                                  });
                                }),
                          ],
                        ),
                      )
                  ],
                )),
        Expanded(
          child: FutureBuilder(
            future: getDirectoryContents(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
              if (snapshot.connectionState!=ConnectionState.done || !snapshot.hasData) {
                return Shimmer.fromColors(
                  baseColor: const Color(0xFFE0E0E0),
                  highlightColor: const Color(0xFFF5F5F5),
                  enabled: true,
                  child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, mainAxisExtent: 75
                      ),
                      itemCount: int.parse((MediaQuery.of(context).size.height/25).toStringAsFixed(0)),
                      itemBuilder: (context,index){
                        return Row(
                          children: [
                            SizedBox.fromSize(
                              size: const Size(25, 0),
                            ),
                            Container(
                              height:20,
                              width:20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox.fromSize(
                              size: const Size(25, 0),
                            ),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                height: 25,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        );
                      },
                  ),
                );
              }
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        FontAwesomeIcons.solidFolderOpen,
                        color: Colors.grey,
                        size: 100,
                      ),
                      Text(
                        "Directory is Empty",
                        style: TextStyle(color: Colors.grey, fontSize: 30),
                      )
                    ],
                  ),
                );
              }
              return GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, mainAxisExtent: 75),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return _renameFieldController.text!=snapshot.data![index].itemName?MaterialButton(
                      onPressed: () {
                        if(snapshot.data![index].itemContentType==FileContentTypes.directory){
                          setState(() {
                            addPath(snapshot.data![index].itemName);
                          });
                        }else{
                          downloadContent(snapshot.data![index].itemName);
                        }
                      },
                      shape: const RoundedRectangleBorder(),
                      elevation: 5,
                      hoverElevation: 10,
                      child: Row(
                        children: [
                          SizedBox.fromSize(
                            size: const Size(25, 0),
                          ),
                          Icon(getFileIconByType(snapshot.data![index].itemContentType),color: Colors.blue,),
                          SizedBox.fromSize(
                            size: const Size(25, 0),
                          ),
                          Expanded(
                            child: Text(
                              snapshot.data![index].itemName,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          PopupMenuButton(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: Colors.blueGrey,
                              ),
                              itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const ListTile(
                                          leading: Icon(
                                            FontAwesomeIcons.download,
                                            color: Colors.blue,
                                          ),
                                          title: Text(
                                            "Download",
                                            style: TextStyle(
                                                color: Colors.blue),
                                          )),
                                      onTap: () {
                                        downloadContent(snapshot.data![index].itemName);
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: const ListTile(
                                          leading: Icon(
                                            Icons.drive_file_rename_outline,
                                            color: Colors.blue,
                                          ),
                                          title: Text(
                                            "Rename",
                                            style: TextStyle(
                                                color: Colors.blue),
                                          )),
                                      onTap: () async {
                                        _renameItemFocus.requestFocus();
                                        setState(() {
                                          _renameFieldController.text=snapshot.data![index].itemName;
                                        });
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: const ListTile(
                                          leading: Icon(
                                            FontAwesomeIcons.copy,
                                            color: Colors.blue,
                                          ),
                                          title: Text(
                                            "Copy",
                                            style: TextStyle(
                                                color: Colors.blue),
                                          )),
                                      onTap: () {
                                        addFileTransferJob(
                                            FileTransferType.copy,
                                            snapshot.data![index].itemName
                                        );
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: const ListTile(
                                          leading: Icon(
                                            FontAwesomeIcons.cut,
                                            color: Colors.blue,
                                          ),
                                          title: Text(
                                            "Cut",
                                            style: TextStyle(
                                                color: Colors.blue),
                                          )),
                                      onTap: () {
                                        addFileTransferJob(
                                            FileTransferType.move,
                                            snapshot.data![index].itemName
                                        );
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: const ListTile(
                                          leading: Icon(
                                            FontAwesomeIcons.trash,
                                            color: Colors.blue,
                                          ),
                                          title: Text(
                                            "Delete",
                                            style: TextStyle(
                                                color: Colors.blue),
                                          )),
                                      onTap: () {
                                        deleteItem(
                                            snapshot.data![index].itemName,
                                            context);
                                      },
                                    ),
                                  ])
                        ],
                      ),
                    ):Row(
                      children: [
                        SizedBox.fromSize(
                          size: const Size(25, 0),
                        ),
                        Icon(getFileIconByType(snapshot.data![index].itemContentType),color: Colors.blue,),
                        SizedBox.fromSize(
                          size: const Size(25, 0),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  focusNode: _renameItemFocus,
                                  controller: _renameFieldController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    focusColor: Colors.blue,
                                    hintText: "New name here",
                                  ),
                                  onSubmitted: (value){
                                    renameItem(snapshot.data![index].itemName,_renameFieldController.text);
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle,color: Colors.green,),
                                splashRadius: 8,
                                onPressed: () {
                                  renameItem(snapshot.data![index].itemName,_renameFieldController.text);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel,color: Colors.red,),
                                splashRadius: 8,
                                onPressed: () {
                                  setState(() {
                                    _renameFieldController.text="";
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  });
            },
          ),
        )
      ],
    );
  }
}

class ClipboardChip extends StatelessWidget {
  final String itemName;
  final int jobIndex;
  final FileTransferType fileTransferType;
  final Function transferFile;
  final BuildContext parentContext;
  const ClipboardChip(
      {Key? key,
      required this.itemName,
      required this.jobIndex,
      required this.fileTransferType,
      required this.transferFile,
      required this.parentContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int colorIndex = itemName.codeUnitAt(0) % clipboardChipColors.length;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Chip(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: clipboardChipColors[colorIndex]),
            borderRadius: BorderRadius.circular(20),
          ),
          onDeleted: () {
            transferFile(fileTransferType, jobIndex, parentContext);
          },
          deleteButtonTooltipMessage: "Paste here",
          deleteIcon: Icon(
            fileTransferType == FileTransferType.move
                ? Icons.drive_file_move
                : Icons.paste,
            color: clipboardChipColors[colorIndex],
          ),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          labelStyle: TextStyle(color: clipboardChipColors[colorIndex]),
          // backgroundColor: Colors.pink,
          label: Text(
            itemName,
            overflow: TextOverflow.fade,
          ),
        ),
      ),
    );
  }
}

class FileTransferJob {
  FileTransferType jobType;
  String itemPath, itemName;
  FileTransferJob(this.jobType, this.itemPath, this.itemName);

  bool checkSameItem(FileTransferJob fileTransferJob) {
    return itemPath == fileTransferJob.itemPath &&
        itemName == fileTransferJob.itemName;
  }
}

class Item{
  String itemName;
  FileContentTypes itemContentType;
  Item(this.itemName,this.itemContentType);
}
