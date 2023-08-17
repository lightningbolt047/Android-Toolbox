import 'package:adb_gui/services/shared_prefs.dart';
import 'package:flutter/material.dart';

class ThemeModeService extends ChangeNotifier{
  Future<void> setThemeMode(ThemeMode themeMode) async{
    await setThemeModePreference(themeMode);
    notifyListeners();
  }
}

ThemeModeService themeModeService=ThemeModeService();