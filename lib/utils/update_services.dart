import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';
import 'package:http/http.dart' as http;

Future<Map<String,dynamic>> checkForUpdates() async{
  PackageInfo currentPackageInfo = await PackageInfo.fromPlatform();
  List<String> currentVersionByType = currentPackageInfo.version.split(".");
  Version currentVersion=Version(int.parse(currentVersionByType[0]),int.parse(currentVersionByType[1]),int.parse(currentVersionByType[2]));
  Map<String,dynamic> latestGithubReleaseInfo=await getLatestGithubReleaseInfo();
  List<String> latestVersionSplitByType=latestGithubReleaseInfo['tag_name'].split(".");
  Version latestVersion=Version(int.parse(latestVersionSplitByType[0]), int.parse(latestVersionSplitByType[1]), int.parse(latestVersionSplitByType[2]));
  if(currentVersion < latestVersion && !latestGithubReleaseInfo['prerelease']){
    return {
      'updateAvailable':true,
      'version':latestGithubReleaseInfo['tag_name'],
      'assetLink':latestGithubReleaseInfo['assets'][0]['browser_download_url']
    };
  }
  return {
    'updateAvailable':false
  };
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