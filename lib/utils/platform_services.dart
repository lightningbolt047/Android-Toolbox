
import 'dart:io';

String getPlatformName(){
  if(Platform.isWindows){
    return "windows";
  }else if(Platform.isMacOS){
    return "macos";
  }
  return "linux";
}