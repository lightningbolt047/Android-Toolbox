
import 'dart:io';

String getPlatformName(){
  if(Platform.isWindows){
    return "windows";
  }else if(Platform.isMacOS){
    return "macOS";
  }
  return "linux";
}

bool isWindows11(){
  String versionInfo=Platform.operatingSystemVersion;
  String buildNumber=versionInfo.split(" ").last;
  buildNumber=buildNumber.replaceAll(")", "");
  return int.parse(buildNumber)>=22000;

}

bool isWSA(String deviceID){
  return (deviceID=="127.0.0.1:58526" || deviceID=="localhost:58526");
}