import 'package:adb_gui/screens/connection_initiation_screen.dart';
import 'package:adb_gui/services/shared_prefs.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'utils/vars.dart';
import 'dart:io';
import 'services/platform_services.dart';
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

  WidgetsFlutterBinding.ensureInitialized();

  await Window.initialize();

  ThemeMode themeModePreference=await getThemeModePreference();

  if(Platform.isWindows){
    await Window.hideWindowControls();
    if(isWindows11()){
      await Window.setEffect(
          effect: WindowEffect.mica,
          dark: themeModePreference==ThemeMode.dark?true:themeModePreference==ThemeMode.light?false:SchedulerBinding.instance!.window.platformBrightness==Brightness.dark
      );
    }else{
      await Window.setEffect(
        effect: WindowEffect.solid,
        color: const Color(0xFF212121),
      );
    }
  }else if(Platform.isLinux){
    await Window.setEffect(
      effect: WindowEffect.solid,
      color: themeModePreference==ThemeMode.dark?const Color(0xFF212121):themeModePreference==ThemeMode.light?Colors.white70:SchedulerBinding.instance!.window.platformBrightness==Brightness.dark?const Color(0xFF212121):Colors.white70,
    );
  }

  runApp(MaterialApp(
    themeMode: themeModePreference,
    theme: ThemeData(
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: TextTheme(
        headline1: GoogleFonts.quicksand(),
        headline2: GoogleFonts.quicksand(),
        headline3: GoogleFonts.quicksand(color: Colors.blue,fontSize: 40,),
        headline4: GoogleFonts.quicksand(),
        headline5: GoogleFonts.quicksand(color: Colors.blue,fontSize: 25,fontWeight: FontWeight.w600),
        headline6: GoogleFonts.quicksand(fontSize: 20,fontWeight: FontWeight.w500),
        subtitle1: GoogleFonts.quicksand(fontSize: 15),
        subtitle2: GoogleFonts.quicksand(),
        bodyText1: GoogleFonts.quicksand(),
        bodyText2: GoogleFonts.quicksand(),
        button: GoogleFonts.quicksand(),
        caption: GoogleFonts.quicksand(),
      ),
    ),
    darkTheme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Platform.isLinux?Colors.black26:Colors.transparent,
      primaryColor: Colors.blueGrey,
      cardColor: Colors.transparent,
      popupMenuTheme: const PopupMenuThemeData(
        color: Color(0xFF212121)
      ),
      bannerTheme: const MaterialBannerThemeData(
        backgroundColor: Color(0xFF212121)
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.blue,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: Colors.grey[900],
      ),
      dialogBackgroundColor: Colors.grey[900],
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey[900],
        contentTextStyle: const TextStyle(
          color: Colors.white
        )
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