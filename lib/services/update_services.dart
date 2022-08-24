import 'dart:convert';
import 'dart:io';
import 'package:adb_gui/services/platform_services.dart';
import 'package:adb_gui/services/shared_prefs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:version/version.dart';
import 'package:http/http.dart' as http;

Future<Map<String,dynamic>> checkForUpdates() async{
  //Scenario 0 - User does not want pre-release builds:
  //Fetches the latest release info using getLatestGithubReleaseInfo()
  //User can choose to update the app thereby downloading and installing the latest stable build
  //Scenario 1 - User wants pre release builds:
  //Fetches all release info finds the latest build irrespective of whether it is marked as pre-release
  //Show a dialog to the user saying an update is available and proceed with it

  //An 'Update is available' dialog is showed only if one of the release assets contains the respective platform name (Eg. windows, linux)
  //If current version is 1.0.0 and a release version 1.0.1 is available
  //Example: For Windows, only if there is an asset containing 'windows' as its name will the "Update is available" show

  PackageInfo currentPackageInfo = await PackageInfo.fromPlatform();
  List<String> currentVersionByType = currentPackageInfo.version.split(".");
  Version currentVersion=Version(int.parse(currentVersionByType[0]),int.parse(currentVersionByType[1]),int.parse(currentVersionByType[2]));
  try{
    Map<String,dynamic> latestGithubReleaseInfo=await getLatestGithubReleaseInfo();
    List<String> latestVersionSplitByType=latestGithubReleaseInfo['tag_name'].split(".");
    Version latestVersion=Version(int.parse(latestVersionSplitByType[0]), int.parse(latestVersionSplitByType[1]), int.parse(latestVersionSplitByType[2]));

    if(currentVersion < latestVersion && !latestGithubReleaseInfo['prerelease']){
      String assetLink="";
      bool updateAvailable=false;
      for(int i=0;i<latestGithubReleaseInfo['assets'].length;i++){
        if(latestGithubReleaseInfo['assets'][i].toString().contains(getPlatformName())){
          assetLink=latestGithubReleaseInfo['assets'][i]['browser_download_url'];
          updateAvailable=true;
        }
      }
      return {
        'updateAvailable':updateAvailable,
        'version':latestGithubReleaseInfo['tag_name'],
        'assetLink':assetLink
      };
    }
    if((await getAllowPreReleasePreference())!){
      return await getLatestGithubPreRelease(currentVersion);
    }
    return {
      'updateAvailable':false
    };
  }catch(e){
    return {
      'error':true
    };
  }
}


Future<Map<String, dynamic>> getLatestGithubPreRelease(Version currentVersion) async{
  http.Response response=await http.get(Uri.parse("https://api.github.com/repos/lightningbolt047/Android-Toolbox/releases"));
  Version latestVersion=currentVersion;
  Map<String,dynamic> latestReleaseInfo={
    'updateAvailable':false
  };
  if(response.statusCode==200){
    List<dynamic> allReleases=jsonDecode(response.body);
    for(int i=0;i<allReleases.length;i++){
      Version releaseVersion=Version.parse(allReleases[i]["tag_name"]);
      if(latestVersion<releaseVersion){
        for(int j=0;j<allReleases[i]['assets'].length;j++){
          if(allReleases[i]['assets'][j]['name'].contains(getPlatformName())){
            latestVersion=releaseVersion;
            latestReleaseInfo['updateAvailable']=true;
            latestReleaseInfo['version']=allReleases[i]['tag_name'];
            latestReleaseInfo['assetLink']=allReleases[i]['assets'][j]['browser_download_url'];
            latestReleaseInfo['preRelease']=allReleases[i]['prerelease'];
          }
        }
      }
    }
  }
  return latestReleaseInfo;
}


Future<Map<String,dynamic>> getLatestGithubReleaseInfo() async{
  //Fetches latest GitHub release info
  http.Response response=await http.get(Uri.parse("https://api.github.com/repos/lightningbolt047/Android-Toolbox/releases/latest"),headers: {
    "Accept":"application/vnd.github.v3+.json"
  });

  if(response.statusCode==200) {
    return jsonDecode(response.body);
  }
  throw "Something went wrong when checking for updates";
}

Future<String> downloadRelease(String url) async{
  //Download the bytes in the TEMP directory defined by the Operating Systems
  //Temp directory for Windows: C:\Users\<user>\AppData\Local\Temp
  //Creates a file named update.exe for Windows, update.tar.xz for Linux
  //Launches the update.exe on Windows
  //Launches the TEMP directory and selects the update.tar.xz file
  //User has to extract the .tar.xz file to their pwd
  Directory saveDirectory=await getTemporaryDirectory();
  String appendSymbol=Platform.isWindows?"\\":"/";
  File latestRelease=File(saveDirectory.path+appendSymbol+"update.${Platform.isWindows?"exe":"tar.xz"}");
  if(await latestRelease.exists()){
    await latestRelease.delete();
  }
  http.Response response=await http.get(Uri.parse(url));
  if(response.statusCode==200){
    //Save file and return path to file;
    await latestRelease.create();
    await latestRelease.writeAsBytes(response.bodyBytes);
    return saveDirectory.path+appendSymbol+"update.${Platform.isWindows?"exe":"tar.xz"}";
  }
  throw "Error occurred when attempting to download file";
}