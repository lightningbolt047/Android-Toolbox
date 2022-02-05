import 'dart:io';
import 'package:adb_gui/components/preference_toggle.dart';
import 'package:adb_gui/components/page_subheading.dart';
import 'package:adb_gui/components/updater_dialog.dart';
import 'package:adb_gui/components/window_buttons.dart';
import 'package:adb_gui/services/shared_prefs.dart';
import 'package:adb_gui/services/update_services.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {

  bool _checkingForUpdates=false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;


  Future<String> getSelectedThemeModeAsString() async{
    ThemeMode selectedThemeMode=await getThemeModePreference();
    if(selectedThemeMode==ThemeMode.light){
      return "Light Mode";
    }else if(selectedThemeMode==ThemeMode.dark){
      return "Dark Mode";
    }
    return "Follow System";
  }

  @override
  void initState() {
    _animationController=AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500)
    );

    _fadeAnimation=Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _slideAnimation=Tween<Offset>(
      begin: const Offset(0,5),
      end: Offset.zero
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    super.initState();

    _animationController.forward();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: double.infinity,
          height: 50,
          child: MoveWindow(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text("Settings",style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomMinimizeWindowButton(),
                    CustomMaximizeWindowButton(),
                    CustomCloseWindowButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const PageSubheading(subheadingName: "Appearance"),
                  PopupMenuButton(
                    tooltip: "Select Theme Mode",
                    offset: Offset(MediaQuery.of(context).size.width,0),
                    child: ListTile(
                      dense: true,
                      title: const Text("Theme Mode",style: TextStyle(
                        fontSize: 20
                      ),),
                      subtitle: const Text("Requires restart for change to take effect"),
                      trailing: FutureBuilder(
                          future: getSelectedThemeModeAsString(),
                          builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                            if(!snapshot.hasData){
                              return const CircularProgressIndicator();
                            }
                            return Text(snapshot.data!,style: TextStyle(
                              color: Theme.of(context).brightness==Brightness.light?Colors.blue:null,
                              fontSize: 20
                            ),);
                          },
                        )
                    ),
                    itemBuilder: (BuildContext context)=>[
                      PopupMenuItem(
                        child: ListTile(
                            leading: Icon(
                              Icons.wb_sunny_rounded,
                              color: Theme.of(context).brightness==Brightness.light?Colors.blue:null,
                            ),
                            dense:false,
                            title: Text(
                              "Light Mode",
                              style: TextStyle(
                                color: Theme.of(context).brightness==Brightness.light?Colors.blue:null,
                              ),
                            ),
                        ),
                        onTap: () async {
                          await setThemeModePreference(ThemeMode.light);
                          setState(() {});
                        }
                      ),
                      PopupMenuItem(
                          child: ListTile(
                              leading: Icon(
                                Icons.mode_night_rounded,
                                color: Theme.of(context).brightness==Brightness.light?Colors.blue:null,
                              ),
                              dense:false,
                              title: Text(
                                "Dark Mode",
                                style: TextStyle(
                                  color: Theme.of(context).brightness==Brightness.light?Colors.blue:null,
                                ),
                              )),
                          onTap: () async{
                            await setThemeModePreference(ThemeMode.dark);
                            setState(() {});
                          }
                      ),
                      PopupMenuItem(
                          child: ListTile(
                              leading: Icon(
                                Icons.brightness_auto,
                                color: Theme.of(context).brightness==Brightness.light?Colors.blue:null,
                              ),
                              dense:false,
                              title: Text(
                                "Follow System",
                                style: TextStyle(
                                  color: Theme.of(context).brightness==Brightness.light?Colors.blue:null,
                                ),
                              )),
                          onTap: () async{
                            await setThemeModePreference(ThemeMode.system);
                            setState(() {});
                          }
                      ),
                    ],
                  ),
                  const PageSubheading(subheadingName: "ADB behavior"),
                  PreferenceToggle(
                    titleText: "Kill ADB server during start",
                    subtitleText: "Fixes incompatibility if any other version of ADB server is running (Leave this on if it does not bother you)",
                    getPreference: getKillADBDuringStartPreference,
                    onChanged: (value) async{
                      await setKillADBDuringStartPreference(value);
                    },
                  ),
                  PreferenceToggle(
                    titleText: "Kill ADB server on exit",
                    subtitleText: "Turning this off will leave ADB server running even after exiting this application. The application will kill ADB during updates even if this toggle is turned off (Leave this on if it does not bother you)",
                    getPreference: getKillADBOnExitPreference,
                    onChanged: (value) async{
                      await setKillADBOnExitPreference(value);
                    },
                  ),
                  const PageSubheading(subheadingName: "Updates",),
                  PreferenceToggle(
                    titleText: "Check for updates during application startup",
                    subtitleText: "If you disable this option, you will have to manually check for updates to even know if a new version has been released",
                    getPreference: getCheckUpdatesDuringStartupPreference,
                    onChanged: (value) async{
                      await setCheckUpdatesDuringStartupPreference(value);
                    },
                  ),
                  PreferenceToggle(
                    titleText: "Allow pre-release updates",
                    subtitleText: "Pre-Release builds may be unstable and are not for the faint of hearts. Pre-Release builds may even break updates forcing you to install some upcoming builds manually",
                    getPreference: getAllowPreReleasePreference,
                    onChanged: (value) async{
                      await setAllowPreReleasePreference(value);
                    },
                  ),
                  ListTile(
                    dense: true,
                    title: const Text("Check for updates",style: TextStyle(
                      fontSize: 20,
                    ),),
                    subtitle: FutureBuilder(
                      future: PackageInfo.fromPlatform(),
                      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot){
                        if(!snapshot.hasData){
                          return const Text("Loading...");
                        }
                        return Text("Version ${snapshot.data!.version}");
                      },
                    ),
                    trailing: _checkingForUpdates?const CircularProgressIndicator():const Icon(Icons.check,color: Colors.green,),
                    onTap: () async{
                      setState(() {
                        _checkingForUpdates=true;
                      });
                      Map<String,dynamic> updateInfo=await checkForUpdates();
                      if(updateInfo['updateAvailable']!=null && updateInfo['updateAvailable']){
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context)=>UpdaterDialog(updateInfo:updateInfo),
                        );
                      }else if(updateInfo['updateAvailable']!=null && !updateInfo['updateAvailable']){
                        showDialog(context: context, builder: (context)=>AlertDialog(
                          title: const Text("No update available!",style: TextStyle(
                              color: Colors.blue
                          ),),
                          content: const Text("You are already on the latest version"),
                          actions: [
                            TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ));
                      }else{
                      showDialog(
                          context: context,
                          builder: (context)=>AlertDialog(
                            title: const Text("Failed to check update",style: TextStyle(
                              color: Colors.blue
                            ),),
                            content: const Text("Check your internet connection and try again"),
                            actions: [
                              TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("OK"),
                                  ),
                              )
                            ],
                          ),
                      );
                    }
                      setState(() {
                        _checkingForUpdates=false;
                      });
                    },
                  ),
                  const PageSubheading(subheadingName: "Info"),
                  ListTile(
                    dense: true,
                    title: const Text("Built with Flutter",style: TextStyle(
                      fontSize: 20,
                    ),),
                    subtitle: Text("Dart:  ${Platform.version}"),
                  ),
                  const PageSubheading(subheadingName: "Legal"),
                  ListTile(
                    dense: true,
                    title: const Text("Licenses",style: TextStyle(
                      fontSize: 20,
                    ),),
                    onTap: () async{
                      showAboutDialog(
                          context: context,
                          applicationName: "Android-Toolbox",applicationVersion: (await PackageInfo.fromPlatform()).version,
                          applicationIcon: Image.asset("assets/lightningBoltLogo.png",scale: 5,),
                        applicationLegalese: "The developer shall not be responsible in case of loss or damage to life and property resulting from use of this application"
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
