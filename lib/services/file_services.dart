import 'dart:io';

import 'package:adb_gui/models/device.dart';
import 'package:adb_gui/services/adb_services.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:adb_gui/utils/vars.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'android_api_checks.dart';

Future<FileContentTypes> getFileType({required Device device,required String currentPath,required String fileName}) async {
  bool isLegacyAndroidFile=false;
  if(isPreMarshmallowAndroid(device.androidAPILevel)){
    ProcessResult result=await Process.run(adbExecutable,["-s",device.id,"shell","ls","\"${currentPath+fileName}\""]);
    // print(result.stdout.toString().trim().contains(_currentPath+fileName));
    if(result.stdout.toString().trim().contains(currentPath+fileName)){
      isLegacyAndroidFile=true;
    }
  }
  String fileExtension = fileName.split(".").last;
  if(fileName!="sdcard" && (isLegacyAndroidFile || (!isPreMarshmallowAndroid(device.androidAPILevel) && !fileName.endsWith("/")))){
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
    } else if (fileExtension == "doc" || fileExtension == "txt" || fileExtension == "docx" || fileExtension == "odt") {
      return FileContentTypes.wordDocument;
    }else if(fileExtension == "ppt" || fileExtension == "pptx"){
      return FileContentTypes.powerpoint;
    }else if(fileExtension == "xls" || fileExtension == "xlsx" || fileExtension == "csv"){
      return FileContentTypes.excel;
    }else if (fileExtension == "png" ||
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


Future<FileContentTypes> findFileItemType(ADBService adbService, String currentPath, String fileItemName) async {

  ProcessResult result=await adbService.executeLs(currentPath+fileItemName);

  if (result.stdout.split("\r\n")[0] == currentPath + fileItemName) {
    return FileContentTypes.file;
  }
  return FileContentTypes.directory;
}


Future<String?> pickFileFolderFromDesktop({required FileItemType uploadType, required String dialogTitle, required List<String> allowedExtensions}) async{
  if (uploadType == FileItemType.file) {
    FilePickerResult? filePicker = await FilePicker.platform.pickFiles(dialogTitle: dialogTitle, type: allowedExtensions[0]=="*"?FileType.any:FileType.custom, allowedExtensions: allowedExtensions);
    return filePicker?.files.single.path;
  } else {
    return await FilePicker.platform.getDirectoryPath(dialogTitle: dialogTitle);
  }
}

Future<List<String?>> pickMultipleFilesFromDesktop({required String dialogTitle,required List<String> allowedExtensions}) async{
  FilePickerResult? filePicker = await FilePicker.platform.pickFiles(dialogTitle: dialogTitle,allowMultiple: true, type: allowedExtensions[0]=="*"?FileType.any:FileType.custom, allowedExtensions: allowedExtensions);
  List<String?> filePaths=[];
  if(filePicker==null){
    return filePaths;
  }
  for(int i=0;i<filePicker.files.length;i++){
    filePaths.add(filePicker.files[i].path);
  }
  return filePaths;
}


String getLastPathElement(String path){

  if(path.contains("\\")){
    List<String> elements=path.split("\\");
    if(path.endsWith("\\")){
      return elements[elements.length-2];
    }
    return elements[elements.length-1];
  }
  List<String> elements=path.split("/");
  if(path.endsWith("/")){
    return elements[elements.length-2];
  }
  return elements[elements.length-1];
}

String getPlatformDelimiter(){
  if(Platform.isWindows){
    return "\\";
  }
  return "/";
}


Future<int> getDesktopFileSize(String filePath) async{
  int size=0;

  File file=File(filePath);
  if(await file.exists()){
    return file.length();
  }
  Directory root=Directory(filePath);
  if(await root.exists()){
    List<FileSystemEntity> element=root.listSync(recursive: true,followLinks: false);
    for (FileSystemEntity element in element) {
      if(element is File){
        size+=await element.length();
      }
    }
  }
  return size;


}


IconData getFileIconByType(FileContentTypes fileType) {
  switch(fileType){
    case FileContentTypes.pdf: return FontAwesomeIcons.filePdf;
    case FileContentTypes.wordDocument: return FontAwesomeIcons.fileWord;
    case FileContentTypes.powerpoint: return FontAwesomeIcons.filePowerpoint;
    case FileContentTypes.excel: return FontAwesomeIcons.fileExcel;
    case FileContentTypes.image: return FontAwesomeIcons.fileImage;
    case FileContentTypes.video: return FontAwesomeIcons.fileVideo;
    case FileContentTypes.audio: return FontAwesomeIcons.fileAudio;
    case FileContentTypes.apk: return FontAwesomeIcons.android;
    case FileContentTypes.archive: return FontAwesomeIcons.fileArchive;
    case FileContentTypes.torrent: return FontAwesomeIcons.magnet;
    case FileContentTypes.securityCertificate: return FontAwesomeIcons.key;
    case FileContentTypes.file: return FontAwesomeIcons.file;
    default: return FontAwesomeIcons.folder;
  }
}