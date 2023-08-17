import 'package:adb_gui/screens/connection_initiation_screen.dart';
import 'package:adb_gui/screens/theme_mode_service.dart';
import 'package:adb_gui/services/shared_prefs.dart';
import 'package:adb_gui/utils/const.dart';
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

  if(kDebugMode && (Platform.isWindows || Platform.isMacOS)){
    adbExecutable="adb";
  }else{
    if(Platform.isWindows){
      adbExecutable="data/flutter_assets/assets/adb.exe";
    }else if(Platform.isLinux){
      adbExecutable="data/flutter_assets/assets/adb";
    }else if(Platform.isMacOS){
      adbExecutable="data/flutter_assets/assets/adbMac";
    }
  }

  WidgetsFlutterBinding.ensureInitialized();

  await Window.initialize();

  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(1000, 625);
    appWindow.minSize = const Size(850, 525);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title="Android Toolbox";
    appWindow.show();
  });
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  void _setWindowTheme(ThemeMode themeModePreference) async{
    if(Platform.isWindows){
      await Window.hideWindowControls();
      if(isWindows11()){
        await Window.setEffect(
            effect: WindowEffect.mica,
            dark: themeModePreference==ThemeMode.dark?true:themeModePreference==ThemeMode.light?false:SchedulerBinding.instance.window.platformBrightness==Brightness.dark
        );
      }else{
        await Window.setEffect(
          effect: WindowEffect.acrylic,
          color: kDarkModeMenuColor.withOpacity(0.75),
        );
      }
    }else if(Platform.isLinux){
      await Window.setEffect(
        effect: WindowEffect.solid,
        color: themeModePreference==ThemeMode.dark?kDarkModeMenuColor:themeModePreference==ThemeMode.light?Colors.white70:SchedulerBinding.instance.window.platformBrightness==Brightness.dark?kDarkModeMenuColor:Colors.white70,
      );
    } else if(Platform.isMacOS) {
      await Window.setEffect(
        effect: WindowEffect.windowBackground
        // color: Colors.white
      );
    }
  }

  @override
  void initState() {
    themeModeService.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getThemeModePreference(),
      builder: (BuildContext context,AsyncSnapshot<ThemeMode> snapshot){
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(),);
        }
        _setWindowTheme(snapshot.data!);
        return MaterialApp(
          themeMode: snapshot.data!,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: kAccentColor),
            // primaryColor: kAccentColor,
            appBarTheme: const AppBarTheme(
              backgroundColor: kAccentColor,
            ),
            // toggleableActiveColor: kAccentColor,
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: kAccentColor,
            ),
            scaffoldBackgroundColor: Colors.transparent,
            textTheme: TextTheme(
              displayLarge: GoogleFonts.quicksand(),
              displayMedium: GoogleFonts.quicksand(),
              displaySmall: GoogleFonts.quicksand(color: kAccentColor,fontSize: 40,),
              headlineMedium: GoogleFonts.quicksand(),
              headlineSmall: GoogleFonts.quicksand(color: kAccentColor,fontSize: 25,fontWeight: FontWeight.w600),
              titleLarge: GoogleFonts.quicksand(fontSize: 20,fontWeight: FontWeight.w500,),
              titleMedium: GoogleFonts.quicksand(fontSize: 15),
              titleSmall: GoogleFonts.quicksand(),
              bodyLarge: GoogleFonts.quicksand(),
              bodyMedium: GoogleFonts.quicksand(),
              labelLarge: GoogleFonts.quicksand(),
              bodySmall: GoogleFonts.quicksand(),
            ),
            dialogTheme: DialogTheme(
              titleTextStyle: GoogleFonts.quicksand(
                fontSize: 20,
                color: kAccentColor,
                fontWeight: FontWeight.w500,
              ),
            )
          ),
          darkTheme: ThemeData.dark().copyWith(
            useMaterial3: true,
            scaffoldBackgroundColor: Platform.isLinux?Colors.black26:Colors.transparent,
            primaryColor: Colors.blueGrey,
            // cardColor: Colors.transparent,
            cardTheme: const CardTheme(
              shadowColor: Colors.transparent,
              color: Colors.transparent,
            ),
            popupMenuTheme: const PopupMenuThemeData(
                color: kDarkModeMenuColor
            ),
            bannerTheme: const MaterialBannerThemeData(
                backgroundColor: Colors.transparent
            ),
            appBarTheme: const AppBarTheme(
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
            ),
            listTileTheme: const ListTileThemeData(
              textColor: Colors.white,
              iconColor: kAccentColor,
            ),
            drawerTheme: const DrawerThemeData(
              backgroundColor: kDarkModeMenuColor,
            ),
            dialogBackgroundColor: kDarkModeMenuColor,
            snackBarTheme: const SnackBarThemeData(
                backgroundColor: kDarkModeMenuColor,
                contentTextStyle: TextStyle(
                    color: Colors.white
                )
            ),
            textTheme: TextTheme(
              displayLarge: GoogleFonts.quicksand(),
              displayMedium: GoogleFonts.quicksand(),
              displaySmall: GoogleFonts.quicksand(color: Colors.white,fontSize: 40),
              headlineMedium: GoogleFonts.quicksand(),
              headlineSmall: GoogleFonts.quicksand(color: Colors.white,fontSize: 25,fontWeight: FontWeight.w600),
              titleLarge: GoogleFonts.quicksand(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),
              titleMedium: GoogleFonts.quicksand(color: Colors.white,fontSize: 15),
              titleSmall: GoogleFonts.quicksand(),
              bodyLarge: GoogleFonts.quicksand(),
              bodyMedium: GoogleFonts.quicksand(color: Colors.white70),
              bodySmall: GoogleFonts.quicksand(),
              labelLarge: GoogleFonts.quicksand(),
            ),
            radioTheme: RadioThemeData(
              fillColor: MaterialStateProperty.resolveWith((states) => Colors.blueGrey),
            ),
            buttonTheme: const ButtonThemeData(
                buttonColor: Colors.black
            ),
            // toggleableActiveColor: Colors.blueGrey,
          ),
          home: const ConnectionInitiationScreen(),
        );
      },
    );
  }
}
