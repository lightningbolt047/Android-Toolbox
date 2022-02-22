import 'dart:io';

import 'package:adb_gui/models/device.dart';
import 'package:adb_gui/models/item.dart';
import 'package:adb_gui/models/storage.dart';
import 'package:adb_gui/services/shared_prefs.dart';
import 'package:adb_gui/services/string_services.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:adb_gui/utils/vars.dart';
import 'package:path/path.dart' as pather;
import 'android_api_checks.dart';
import 'file_services.dart';

class ADBService{
  final Device device;

  ADBService({required this.device});

  Future<List<Item>> getDirectoryContents(String currentPath) async {
    List<String> arguments=["-s", device.id, "shell", "ls"];
    bool? showHiddenFilesPreference=await getShowHiddenFilesPreference();
    if(showHiddenFilesPreference!=null && showHiddenFilesPreference){
      arguments.add("-a");
    }
    if(!isPreMarshmallowAndroid(device.androidAPILevel)){
      arguments.add("-p");
    }
    arguments.add("\"$currentPath\"");
    ProcessResult result=await Process.run(adbExecutable, arguments);
    // result=await Process.run(adbExecutable, ["-s", deviceID, "shell", "ls","-p", "\"$_currentPath\""]);
    List<String> directoryContentDetails = (result.stdout).split("\n");
    directoryContentDetails.removeLast();
    List<Item> directoryItems=[];
    directoryContentDetails=getTrimmedStringList(directoryContentDetails);
    for(int i=0;i<directoryContentDetails.length;i++){
      if(directoryContentDetails[i]=="./" || directoryContentDetails[i]=="../"){
        continue;
      }
      directoryItems.add(Item(directoryContentDetails[i].endsWith("/")?directoryContentDetails[i].replaceAll("/", ""):directoryContentDetails[i],getFileType(device:device,currentPath:currentPath,fileName:directoryContentDetails[i])));
    }
    return directoryItems;
  }

  Future<List<Storage>> getExternalStorages() async{
    List<Item> storages=await getDirectoryContents("/storage/");
    List<Storage> externalStorages=[];
    for(int i=0;i<storages.length;i++){
      if(storages[i].itemName!="self" && storages[i].itemName!="emulated" && storages[i].itemName!="." && storages[i].itemName!=".."){
        externalStorages.add(Storage("/storage/${storages[i].itemName}/", storages[i].itemName));
      }
    }
    return externalStorages;
  }



  Future<int> deleteItem({required String itemPath,Function? beforeExecution, Function? onSuccess, Function? onFail}) async {
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
    return result.exitCode;
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
    return int.parse(processResult.stdout.toString().split("\t")[0])*1024;
  }
  
  Future<List<Map<String,dynamic>>> getAppPackageInfo(AppType appType) async{
    List<String> arguments=["-s",device.id,"shell","pm","list","packages",appType==AppType.system?"-s":"-3","-i"];
    if(isPreIceCreamSandwichAndroid(device.androidAPILevel)){
      arguments.removeLast();
    }
    ProcessResult result=await Process.run(adbExecutable, arguments);
    List<String> packageInfoList=result.stdout.toString().split("\n");
    packageInfoList.removeLast();
    List<Map<String,dynamic>> packageInfoMap=[];
    for(int i=0;i<packageInfoList.length;i++){
      List<String> packageInfo = packageInfoList[i].split("  ");
      packageInfoMap.add({
        'packageName':packageInfo[0].split(":")[1],
        'installer':packageInfo[1].split("=")[1].trim(),
        'appType':appType
      });
    }
    return packageInfoMap;
  }

  Future<int> getAppPackages(String packageName,String chosenDirectory) async {
    // stdout.writeln("Destination folder: " + chosenDirectory);

    ProcessResult result = await Process.run(adbExecutable, ["-s", device.id, "shell", "pm", "path", packageName]);
    List<String> lines = result.stdout.toString().split("\n");

    List<String> paths = List.empty(growable: true);
    for (int i=0; i<lines.length; i++) {
      String line = lines[i].trim();
      if (line.startsWith("package:")) {
        paths.add(line.substring(8)); // 8: "package:".length
      }
    }

    if (paths.isEmpty) {
      return 0;
    }

    if (paths.length == 1) { // only one package found, the most common case now
      // rename the destination file name by package name
      chosenDirectory = pather.join(chosenDirectory, packageName + ".apk");
    } else {
      // make a new directory named as package name if more than one package found
      chosenDirectory = pather.join(chosenDirectory, packageName);
      Directory dir =  Directory(chosenDirectory);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }

    for (int i=0; i<paths.length; i++) {
      // download the package
      await Process.run(adbExecutable, ["-s", device.id, "pull", paths[i], chosenDirectory]);
      // stdout.writeln(result.stdout.toString());
    }

    return paths.length;
  }

  Future<List<String>> getUninstalledSystemApps() async{
    ProcessResult result = await Process.run(adbExecutable, ["-s",device.id,"shell","pm","list","packages","-s"]);
    List<String> systemApps = result.stdout.toString().split("\n");
    systemApps.removeLast();
    for(int i=0;i<systemApps.length;i++){
      systemApps[i] = systemApps[i].trim();
    }

    result = await Process.run(adbExecutable, ["-s",device.id,"shell","pm","list","packages","-u","-s"]);
    List<String> systemAppsIncludingUninstalled = result.stdout.toString().split("\n");
    systemAppsIncludingUninstalled.removeLast();
    for(int i=0;i<systemAppsIncludingUninstalled.length;i++){
      systemAppsIncludingUninstalled[i]=systemAppsIncludingUninstalled[i].trim();
    }

    List<String> uninstalledSystemApps=[];

    for(int i=0;i<systemAppsIncludingUninstalled.length;i++){
      if(!systemApps.contains(systemAppsIncludingUninstalled[i])){
        uninstalledSystemApps.add(systemAppsIncludingUninstalled[i].split(":")[1]);
      }
    }

    return uninstalledSystemApps;
  }

  Future<Process> reinstallSystemApp(String packageName) async{
    return await Process.start(adbExecutable, ["-s",device.id,"shell","pm","install-existing",packageName]);
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

  Future<String> getCurrentUserID() async{
    ProcessResult result = await Process.run(adbExecutable, ["-s",device.id,"shell","am","get-current-user"]);
    return result.stdout.toString().trim();
  }

  Future<int> uninstallSystemAppForUser({required String packageName}) async{
    ProcessResult result =  await Process.run(adbExecutable, ["-s",device.id,"shell","pm","uninstall","-k","--user",await getCurrentUserID(),packageName]);
    return result.exitCode;
  }

  Future<int> launchApp({required String packageName}) async{
    ProcessResult result=await Process.run(adbExecutable, ["-s",device.id,"shell","monkey","-p",packageName,"1"]);
    return result.exitCode;
  }

  Future<Process> reinstallSystemAppForUser({required String packageName}) async{
    return await Process.start(adbExecutable, ["-s",device.id,"shell","pm","install-existing",packageName]);
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

  Future<ProcessResult> installSingleApkComplete(String apkFilePath) async{
    return await Process.run(adbExecutable, ["-s",device.id,"install",apkFilePath]);
  }

  // Future<Process> batchInstallApk(List<String> apkFilePaths) async{
  //   List<String> processArgs=["-s",device.id,"install-multi-package"];
  //   for(int i=0;i<apkFilePaths.length;i++){
  //     processArgs.add(apkFilePaths[i]);
  //   }
  //   return await Process.start(adbExecutable, processArgs);
  // }

  Future<int> suspendApp(String packageName) async{
    ProcessResult result = await Process.run(adbExecutable, ["-s",device.id,"shell","pm","suspend",packageName]);
    return result.exitCode;
  }
  
  Future<List<String>> getAPKFilePathOnDevice(String packageName) async{
    ProcessResult result=await Process.run(adbExecutable, ["-s",device.id,"shell","pm","path",packageName]);
    List<String> lines=result.stdout.toString().split("\n");
    lines.removeLast();
    List<String> paths=[];
    for(int i=0;i<lines.length;i++){
      paths.add(lines[i].split(":")[1].trim());
    }
    return paths;
  }

  Future<int> unsuspendApp(String packageName) async{
    ProcessResult result = await Process.run(adbExecutable, ["-s",device.id,"shell","pm","unsuspend",packageName]);
    return result.exitCode;
  }

  Future<int> compileApp(String packageName, CompilationMode compilationMode) async{
    ProcessResult result = await Process.run(adbExecutable, ["-s",device.id,"shell","pm","compile","-m",getCompilationModeAsString(compilationMode),"-f",packageName]);
    return result.exitCode;
  }

  Future<int> excludeFromMediaScanner(String path) async{
    ProcessResult result=await Process.run(adbExecutable, ["-s",device.id,"shell","touch","\"$path.nomedia\""]);
    return result.exitCode;
  }

  Future<int> includeInMediaScanner(String path) async{
    return deleteItem(itemPath: path+".nomedia");
  }


}