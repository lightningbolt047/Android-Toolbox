import 'package:adb_gui/services/platform_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:io';

Future<void> setAllowPreReleasePreference(bool value) async {
  SharedPreferences pref=await SharedPreferences.getInstance();
  pref.setBool("allowPreRelease", value);
}

Future<bool?> getAllowPreReleasePreference() async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  if(pref.getBool("allowPreRelease")==null){
    await setAllowPreReleasePreference(false);
    return false;
  }
  return pref.getBool("allowPreRelease");
}

Future<void> setThemeModePreference(ThemeMode themeMode) async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  pref.setInt("themeMode", themeMode.index);
}

Future<ThemeMode> getThemeModePreference() async{
  SharedPreferences pref=await SharedPreferences.getInstance();

  if(pref.getInt("themeMode")==null){
    ThemeMode themeMode=(Platform.isWindows && !isWindows11())?ThemeMode.dark:ThemeMode.system;
    await setThemeModePreference(themeMode);
    return themeMode;
  }
  return ThemeMode.values[pref.getInt("themeMode")!];
}

Future<void> setKillADBDuringStartPreference(bool value) async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  pref.setBool("killADBDuringStart", value);
}

Future<bool?> getKillADBDuringStartPreference() async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  if(pref.getBool("killADBDuringStart")==null){
    await setKillADBDuringStartPreference(true);
    return true;
  }
  return pref.getBool("killADBDuringStart");
}

Future<void> setKillADBOnExitPreference(bool value) async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  pref.setBool("killADBOnExit", value);
}

Future<bool?> getKillADBOnExitPreference() async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  if(pref.getBool("killADBOnExit")==null){
    await setKillADBOnExitPreference(true);
    return true;
  }
  return pref.getBool("killADBOnExit");
}

Future<bool?> getCheckUpdatesDuringStartupPreference() async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  if(pref.getBool("checkUpdatesDuringStartup")==null){
    await setCheckUpdatesDuringStartupPreference(true);
    return true;
  }
  return pref.getBool("checkUpdatesDuringStartup");
}

Future<void> setCheckUpdatesDuringStartupPreference(bool value) async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  pref.setBool("checkUpdatesDuringStartup", value);
}

Future<void> setShowHiddenFilesPreference(bool value) async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  pref.setBool("showHiddenFiles", value);
}

Future<bool?> getShowHiddenFilesPreference() async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  if(pref.getBool("showHiddenFiles")==null){
    await setShowHiddenFilesPreference(false);
    return false;
  }
  return pref.getBool("showHiddenFiles");
}