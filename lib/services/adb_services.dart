import 'dart:io';

import 'package:adb_gui/models/device.dart';
import 'package:adb_gui/models/item.dart';
import 'package:adb_gui/services/string_services.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:adb_gui/utils/vars.dart';
import 'android_api_checks.dart';
import 'file_services.dart';

class ADBService{
  final Device device;

  ADBService({required this.device});

  Future<List<Item>> getDirectoryContents(String currentPath) async {
    ProcessResult result;
    if(isPreMarshmallowAndroid(device.androidAPILevel)){
      result=await Process.run(adbExecutable, ["-s", device.id, "shell", "ls", "\"$currentPath\""]);
    }else{
      result=await Process.run(adbExecutable, ["-s", device.id, "shell", "ls","-p", "\"$currentPath\""]);
    }
    // result=await Process.run(adbExecutable, ["-s", deviceID, "shell", "ls","-p", "\"$_currentPath\""]);
    List<String> directoryContentDetails = (result.stdout).split("\n");
    directoryContentDetails.removeLast();
    List<Item> directoryItems=[];
    directoryContentDetails=getTrimmedStringList(directoryContentDetails);
    for(int i=0;i<directoryContentDetails.length;i++){
      directoryItems.add(Item(directoryContentDetails[i].endsWith("/")?directoryContentDetails[i].replaceAll("/", ""):directoryContentDetails[i],await getFileType(device:device,currentPath:currentPath,fileName:directoryContentDetails[i])));
    }
    return directoryItems;
  }

  void deleteItem({required String itemPath,Function? beforeExecution, Function? onSuccess, Function? onFail}) async {
    if(beforeExecution != null){
      beforeExecution();
    }
    ProcessResult result = await Process.run(adbExecutable, [
      "-s",
      device.id,
      "shell",
      "rm",
      "-r",
      "\"$itemPath\""
    ]);
    if(result.exitCode == 0 && onSuccess!=null) {
      onSuccess();
    }
  }

  void uploadContent({required currentPath, required FileItemType uploadType, Function? onProgress}) async {
    String? sourcePath = await pickFileFolderFromDesktop(uploadType: uploadType,dialogTitle:uploadType==FileItemType.file?"Select File":"Select Directory",allowedExtensions: ["*"]);

    if (sourcePath == null) {
      return;
    }
    Process process = await Process.start(
      adbExecutable,
      ["-s", device.id, "push", sourcePath, currentPath],
    );
    if(onProgress!=null){
      onProgress(process,getDesktopFileSize,getFileItemSize,sourcePath,currentPath);
    }
  }

  Future<ProcessResult> executeLs(String path) async{
    return await Process.run(adbExecutable, [
      "-s",
      device.id,
      "shell",
      "ls",
      "\"$path\""
    ]);
  }

  Future<Process> fileCopy({required oldPath, required newPath}) async{
    Process process = await Process.start(adbExecutable, [
      "-s",
      device.id,
      "shell",
      "cp",
      "-r",
      "\"$oldPath\"",
      "\"$newPath\""
    ]);
    return process;
  }

  Future<Process> fileMove({required oldPath, required newPath}) async{
    Process process = await Process.start(adbExecutable, [
      "-s",
      device.id,
      "shell",
      "mv",
      "\"$oldPath\"",
      "\"$newPath\""
    ]);
    return process;
  }

  Future<ProcessResult> fileRename({required oldPath,required newPath}) async{
    return await Process.run(adbExecutable, [
      "-s",
      device.id,
      "shell",
      "mv",
      "\"$oldPath\"",
      "\"$newPath\""
    ]);
  }

  void downloadContent({required String itemPath,Function? onProgress}) async {
    String? chosenDirectory = await pickFileFolderFromDesktop(uploadType:FileItemType.directory,dialogTitle: "Where to download",allowedExtensions: ["*"]);

    if (chosenDirectory == null) {
      return;
    }
    Process process = await Process.start(adbExecutable, ["-s", device.id, "pull", itemPath, chosenDirectory]);
    if(onProgress!=null){
      onProgress(process,getFileItemSize,getDesktopFileSize,itemPath,chosenDirectory);
    }
  }

  Future<int> getFileItemSize(String filePath) async{
    ProcessResult processResult=await Process.run(adbExecutable, ["-s",device.id,"shell","du","-s","\"$filePath\""]);
    return int.parse(processResult.stdout.toString().split("\t")[0]);
  }
  
  Future<List<Map<String,String>>> getAppPackageNames(AppType appType) async{
    List<String> arguments=["-s",device.id,"shell","pm","list","packages",appType==AppType.system?"-s":"-3","-i"];
    if(isPreIceCreamSandwichAndroid(device.androidAPILevel)){
      arguments.removeLast();
    }
    ProcessResult result=await Process.run(adbExecutable, arguments);
    List<String> packageInfoList=result.stdout.toString().split("\n");
    packageInfoList.removeLast();
    List<Map<String,String>> packageInfoMap=[];
    for(int i=0;i<packageInfoList.length;i++){
      List<String> packageInfo = packageInfoList[i].split("  ");
      packageInfoMap.add({
        'packageName':packageInfo[0].split(":")[1],
        'installer':packageInfo[1].split("=")[1].trim()
      });
    }
    return packageInfoMap;
  }

  Future<void> forceStopPackage(String packageName) async{
    await Process.run(adbExecutable, ["-s",device.id,"shell","am","force-stop",packageName]);
  }

  Future<int> uninstallApp({required String packageName, bool keepData=false}) async{
    ProcessResult result;
    if(keepData){
      result=await Process.run(adbExecutable, ["-s",device.id,"shell","pm","uninstall","-k",packageName]);
    }else{
      result=await Process.run(adbExecutable, ["-s",device.id,"uninstall",packageName]);
    }
    return result.exitCode;
  }

  Future<Process> installSingleApk(String apkFilePath) async{
    // apkFilePath.replaceAll(" ", "` ");
    return await Process.start(adbExecutable, ["-s",device.id,"install",apkFilePath]);
  }

  Future<Process> installMultipleForSinglePackage(List<String> apkFilePaths) async{
    List<String> processArgs=["-s",device.id,"install-multiple"];
    for(int i=0;i<apkFilePaths.length;i++){
      processArgs.add(apkFilePaths[i]);
    }
    return await Process.start(adbExecutable, processArgs);
  }

  Future<Process> batchInstallApk(List<String> apkFilePaths) async{
    List<String> processArgs=["-s",device.id,"install-multi-package"];
    for(int i=0;i<apkFilePaths.length;i++){
      processArgs.add(apkFilePaths[i]);
    }
    return await Process.start(adbExecutable, processArgs);
  }

  Future<int> suspendApp(String packageName) async{
    ProcessResult result = await Process.run(adbExecutable, ["-s",device.id,"shell","pm","suspend",packageName]);
    return result.exitCode;
  }

  Future<int> unsuspendApp(String packageName) async{
    ProcessResult result = await Process.run(adbExecutable, ["-s",device.id,"shell","pm","unsuspend",packageName]);
    return result.exitCode;
  }

  Future<int> compileApp(String packageName, CompilationMode compilationMode) async{
    ProcessResult result = await Process.run(adbExecutable, ["-s",device.id,"shell","pm","compile","-m",getCompilationModeAsString(compilationMode),"-f",packageName]);
    return result.exitCode;
  }


}