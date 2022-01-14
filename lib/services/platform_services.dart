
import 'dart:io';

String getPlatformName(){
  if(Platform.isWindows){
    return "windows";
  }else if(Platform.isMacOS){
    return "macOS";
  }
  return "linux";
}

bool isWSA(String deviceID){
  return (deviceID=="127.0.0.1:58526" || deviceID=="localhost:58526");
}