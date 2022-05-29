import 'dart:io';

import 'package:adb_gui/components/console_output.dart';
import 'package:adb_gui/components/page_subheading.dart';
import 'package:adb_gui/models/device.dart';
import 'package:adb_gui/services/adb_services.dart';
import 'package:adb_gui/services/file_services.dart';
import 'package:adb_gui/services/string_services.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/const.dart';

class ApkInstallDialog extends StatefulWidget {
  final Device device;
  const ApkInstallDialog({Key? key,required this.device}) : super(key: key);

  @override
  _ApkInstallDialogState createState() => _ApkInstallDialogState(device);
}

class _ApkInstallDialogState extends State<ApkInstallDialog> {

  final Device device;

  _ApkInstallDialogState(this.device);

  AppInstallType appInstallType = AppInstallType.single;
  String consoleOutput = "";
  late ADBService adbService;
  int totalInstallations=0;
  int installed=0;

  ProcessStatus processStatus = ProcessStatus.notStarted;



  List<String> selectedFiles = [];


  void pickApksAndInstall() async{
    Process? process;
    if(appInstallType==AppInstallType.single){
      String? filePath=await pickFileFolderFromDesktop(fileItemType: FileItemType.file, dialogTitle: "Select Single APK", allowedExtensions: ["apk"]);
      if(filePath!=null){
        setState(() {
          selectedFiles.clear();
          selectedFiles.add(filePath);
        });
        process=await adbService.installSingleApk(filePath);
      }
    }else{
      List<String?> filePaths = await pickMultipleFilesFromDesktop(dialogTitle: "Select APKs to install",allowedExtensions: ["apk"]);
      if(filePaths.isNotEmpty){
        setState(() {
          selectedFiles.clear();
          for(int i=0;i<filePaths.length;i++){
            selectedFiles.add(filePaths[i]!);
          }
        });
        if(appInstallType==AppInstallType.multiApks){
          process=await adbService.installMultipleForSinglePackage(selectedFiles);
        }else{
          // process = await adbService.batchInstallApk(selectedFiles);
          if(selectedFiles.isNotEmpty){
            setState(() {
              totalInstallations=selectedFiles.length;
              installed=0;
              consoleOutput="";
              processStatus=ProcessStatus.working;
            });
          }
          for(int i=0;i<selectedFiles.length;i++){
            ProcessResult appInstallResult=await adbService.installSingleApkComplete(selectedFiles[i]);
            if(appInstallResult.exitCode==0){
              setState(() {
                consoleOutput+=appInstallResult.stdout+"\n";
                installed+=1;
                if(installed==totalInstallations){
                  processStatus=ProcessStatus.success;
                }
              });
            }else{
              setState(() {
                consoleOutput+=appInstallResult.stdout+"\n";
                consoleOutput+="Failed to install ${selectedFiles[i]} with exit code ${appInstallResult.exitCode}";
                processStatus=ProcessStatus.fail;
              });
              break;
            }
          }
        }
      }
    }
    if(process!=null){
      setState(() {
        totalInstallations=0;
        installed=0;
        consoleOutput="";
        processStatus=ProcessStatus.working;
      });
      process.stdout.listen((event) {
        setState(() {
          consoleOutput+=String.fromCharCodes(event);
        });
      });
      monitorProgress(process);
    }
  }

  void monitorProgress(Process process) async {
    int exitCode = await process.exitCode;

    setState(() {
      if(exitCode==0){
        consoleOutput+="\nProcess completed successfully\n\n";
        processStatus=ProcessStatus.success;
      }else{
        consoleOutput+="\nAPK install failed with exit code $exitCode\n\n";
        processStatus=ProcessStatus.fail;
      }
    });
  }



  @override
  void initState() {
    adbService=ADBService(device: device);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      elevation: 3,
      child: LayoutBuilder(
        builder: (context,constraints){
          return SizedBox(
            height: constraints.maxHeight*0.75,
            width: constraints.maxWidth*0.5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const PageSubheading(subheadingName: "Install Apk"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppInstallTypeRadioText(value: appInstallType, groupValue: AppInstallType.single, label: "Single APK", onChanged: (value){
                        setState(() {
                          if(appInstallType!=AppInstallType.single){
                            selectedFiles.clear();
                          }
                          appInstallType=AppInstallType.single;
                        });
                      }),
                      AppInstallTypeRadioText(value: appInstallType, groupValue: AppInstallType.multiApks, label: "Split APKs", onChanged: (value){
                        setState(() {
                          if(appInstallType!=AppInstallType.multiApks){
                            selectedFiles.clear();
                          }
                          appInstallType=AppInstallType.multiApks;
                        });
                      }),
                      AppInstallTypeRadioText(value: appInstallType, groupValue: AppInstallType.batch, label: "Batch Install", onChanged: (value){
                        setState(() {
                          if(appInstallType!=AppInstallType.batch){
                            selectedFiles.clear();
                          }
                          appInstallType=AppInstallType.batch;
                        });
                      }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Files",style: TextStyle(
                        fontSize: 25
                      ),),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        color: Theme.of(context).brightness==Brightness.light?kAccentColor:Colors.blueGrey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: const [
                              Icon(FontAwesomeIcons.file,color: Colors.white,),
                              SizedBox(
                                width: 8,
                              ),
                              Text("Select Files and Install",maxLines: 3,overflow: TextOverflow.ellipsis,style: TextStyle(
                                  color: Colors.white
                              ),),
                            ],
                          ),
                        ),
                        onPressed: pickApksAndInstall,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  ConsoleOutput(consoleOutput: getStringFromStringList(selectedFiles)+"\n"+consoleOutput),
                  if(processStatus==ProcessStatus.working)
                    SizedBox(
                      width: constraints.maxWidth*0.5,
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: appInstallType==AppInstallType.batch?installed/totalInstallations:null,
                          ),
                          if(appInstallType==AppInstallType.batch)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("$installed of $totalInstallations app(s) installed",style: const TextStyle(
                                  fontWeight: FontWeight.w600
                                ),),
                                Text("${((installed/totalInstallations)*100).toStringAsFixed(2)}%",style: const TextStyle(
                                  fontWeight: FontWeight.w600
                                ),)
                              ],
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(
                    height: 8,
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    color: kAccentColor,
                    disabledColor: Colors.grey,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                      child: Text("Close",style: TextStyle(color: Colors.white),),
                    ),
                    onPressed: processStatus==ProcessStatus.working?null:(){
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppInstallTypeRadioText extends StatelessWidget {

  final AppInstallType value;
  final AppInstallType groupValue;
  final Function onChanged;
  final String label;

  const AppInstallTypeRadioText({Key? key,required this.value,required this.groupValue, required this.onChanged, this.label="Label"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio(value: value, groupValue: groupValue, onChanged: (value){
          onChanged(value);
        }),
        Text(label,style: const TextStyle(
          fontSize: 15
        ),),
      ],
    );
  }
}
