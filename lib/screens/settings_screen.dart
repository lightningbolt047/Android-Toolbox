import 'package:adb_gui/components/allow_pre_release_toggle.dart';
import 'package:adb_gui/components/page_subheading.dart';
import 'package:adb_gui/components/updater_dialog.dart';
import 'package:adb_gui/components/window_buttons.dart';
import 'package:adb_gui/services/update_services.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool _checkingForUpdates=false;

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
                Container(
                  color: Colors.blue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomMinimizeWindowButton(),
                      CustomMaximizeWindowButton(),
                      CustomCloseWindowButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const PageSubheading(subheadingName: "Updates",),
            const AllowPreReleaseToggle(),
            ListTile(
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
            const PageSubheading(subheadingName: "Legal"),
            ListTile(
              title: const Text("Licenses",style: TextStyle(
                fontSize: 20,
              ),),
              onTap: () async{
                showAboutDialog(
                    context: context,
                    applicationName: "Android-Toolbox",applicationVersion: (await PackageInfo.fromPlatform()).version,
                    applicationIcon: const Text("⚡",style: TextStyle(
                      fontSize: 32,
                      color: Colors.blue
                    ),),
                  applicationLegalese: "The developer shall not be responsible in case of loss or damage to life and property resulting from use of this application"
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
