import 'package:adb_gui/screens/connection_initiation_screen.dart';
import 'package:adb_gui/services/shared_prefs.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'utils/vars.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

void main() async {

  if(kDebugMode && Platform.isWindows){
    adbExecutable="adb";
  }else{
    if(Platform.isWindows){
      adbExecutable="data/flutter_assets/assets/adb.exe";
    }else if(Platform.isLinux){
      adbExecutable="data/flutter_assets/assets/adb";
    }
  }

  runApp(MaterialApp(
    themeMode: await getThemeModePreference(),
    theme: ThemeData(
      primaryColor: Colors.blue,
      textTheme: TextTheme(
        headline1: GoogleFonts.quicksand(),
        headline2: GoogleFonts.quicksand(),
        headline3: GoogleFonts.quicksand(color: Colors.blue,fontSize: 40,),
        headline4: GoogleFonts.quicksand(),
        headline5: GoogleFonts.quicksand(color: Colors.blue,fontSize: 25,fontWeight: FontWeight.w600),
        headline6: GoogleFonts.quicksand(),
        subtitle1: GoogleFonts.quicksand(),
        subtitle2: GoogleFonts.quicksand(),
        bodyText1: GoogleFonts.quicksand(),
        bodyText2: GoogleFonts.quicksand(),
        button: GoogleFonts.quicksand(),
        caption: GoogleFonts.quicksand(),
      ),
    ),
    darkTheme: ThemeData.dark().copyWith(
      primaryColor: Colors.blueGrey,
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        dense: true,
        iconColor: Colors.blue,
      ),
      textTheme: TextTheme(
        headline1: GoogleFonts.quicksand(),
        headline2: GoogleFonts.quicksand(),
        headline3: GoogleFonts.quicksand(color: Colors.white,fontSize: 40),
        headline4: GoogleFonts.quicksand(),
        headline5: GoogleFonts.quicksand(color: Colors.white,fontSize: 25,fontWeight: FontWeight.w600),
        headline6: GoogleFonts.quicksand(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),
        subtitle1: GoogleFonts.quicksand(color: Colors.white,fontSize: 15),
        subtitle2: GoogleFonts.quicksand(),
        bodyText1: GoogleFonts.quicksand(),
        bodyText2: GoogleFonts.quicksand(color: Colors.white70),
        caption: GoogleFonts.quicksand(),
        button: GoogleFonts.quicksand(),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) => Colors.blueGrey),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.black
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