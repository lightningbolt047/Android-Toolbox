import 'package:adb_gui/screens/connection_initiation_screen.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'utils/vars.dart';
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

  runApp(MaterialApp(
    themeMode: ThemeMode.light,
    theme: ThemeData(
      textTheme: const TextTheme(
        headline3: TextStyle(
          color: Colors.blue,
          fontSize: 40,
        ),
        headline5: TextStyle(
            color: Colors.blue,
            fontSize: 25,
            fontWeight: FontWeight.w600
        ),
      ),
    ),
    darkTheme: ThemeData.dark().copyWith(
      primaryColor: Colors.blueGrey,
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        dense: true,
        iconColor: Colors.blue,
      ),
      textTheme: const TextTheme(
        headline3: TextStyle(
          color: Colors.white,
          fontSize: 40,
        ),
        headline5: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600
        ),
        headline6: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
        subtitle1: TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
        bodyText2: TextStyle(
          color: Colors.white70,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) => Colors.blueGrey),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.black54
      ),
      toggleableActiveColor: Colors.blueGrey
    ),
    home: const ConnectionInitiationScreen(),
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