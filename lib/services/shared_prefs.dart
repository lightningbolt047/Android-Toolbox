import 'package:shared_preferences/shared_preferences.dart';

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