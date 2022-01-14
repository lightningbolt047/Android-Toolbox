import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

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
    await setThemeModePreference(ThemeMode.system);
    return ThemeMode.system;
  }
  return ThemeMode.values[pref.getInt("themeMode")!];
}