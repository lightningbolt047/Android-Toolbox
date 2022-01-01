import 'dart:convert';
import 'dart:io';

import 'package:adb_gui/services/platform_services.dart';
import 'package:adb_gui/services/shared_prefs.dart';
import 'package:adb_gui/vars.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:version/version.dart';
import 'package:http/http.dart' as http;

Future<Map<String,dynamic>> checkForUpdates() async{
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
  http.Response response=await http.get(Uri.parse("https://api.github.com/repos/lightningbolt047/Android-Toolbox/releases/latest"),headers: {
    "Accept":"application/vnd.github.v3+.json"
  });

  if(response.statusCode==200) {
    return jsonDecode(response.body);
  }
  throw "Something went wrong when checking for updates";
}

Future<String> downloadRelease(String url) async{
  Directory saveDirectory=await getTemporaryDirectory();
  String appendSymbol=Platform.isWindows?"\\":"/";
  File latestRelease=File(saveDirectory.path+appendSymbol+"update.exe");
  if(await latestRelease.exists()){
    await latestRelease.delete();
  }
  http.Response response=await http.get(Uri.parse(url));
  if(response.statusCode==200){
    //TODO Save file and return path to file;
    await latestRelease.create();
    await latestRelease.writeAsBytes(response.bodyBytes);
    return saveDirectory.path+appendSymbol+"update.exe";
  }
  throw "Error occurred when attempting to download file";
}