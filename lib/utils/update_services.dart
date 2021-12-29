import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

import '../enums.dart';

Future<UpdateStatus> checkForUpdates() async{
  PackageInfo currentPackageInfo = await PackageInfo.fromPlatform();
  List<String> currentVersionByType = currentPackageInfo.version.split(".");
  Version currentVersion=Version(int.parse(currentVersionByType[0]),int.parse(currentVersionByType[1]),int.parse(currentVersionByType[2]));
  //TODO check for latest version using github api
  Version latestVersion=Version(1, 2, 3);
  if(currentVersion < latestVersion){
    return UpdateStatus.available;
  }
  return UpdateStatus.latest;
}