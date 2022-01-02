import 'package:adb_gui/screens/connection_initiation_screen.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'vars.dart';
import 'dart:io';

void main() {

  if(kDebugMode){
    adbExecutable="adb";
  }else{
    if(Platform.isWindows){
      adbExecutable="data/flutter_assets/assets/adb.exe";
    }else if(Platform.isLinux){
      adbExecutable="data/flutter_assets/assets/adb";
    }
  }

  runApp(const MaterialApp(
    home: ConnectionInitiationScreen(),
  ));

  doWhenWindowReady(() {
    const initialSize = Size(1000, 625);
    appWindow.minSize = const Size(850, 525);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title="ADB GUI";
    appWindow.show();
  });
}