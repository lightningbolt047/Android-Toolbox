import 'package:adb_gui/components/prompt_dialog.dart';
import 'package:adb_gui/components/select_compilation_mode_dialog.dart';
import 'package:adb_gui/components/set_app_installer_dialog.dart';
import 'package:adb_gui/components/simple_rectangle_icon_material_button.dart';
import 'package:adb_gui/models/device.dart';
import 'package:adb_gui/services/adb_services.dart';
import 'package:adb_gui/services/android_api_checks.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PackageInfo extends StatelessWidget {

  final Device device;
  final Map<String,String> packageInfo;
  final ADBService adbService;
  final VoidCallback onUninstallComplete;

  const PackageInfo({Key? key,required this.device,required this.packageInfo, required this.adbService,required this.onUninstallComplete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(packageInfo['packageName']==null){
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.android,color: Colors.grey,size: 100,),
              Text(
                "Select an App",
                style: TextStyle(color: Colors.grey, fontSize: 30),
              )
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 0,
        leading: Container(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("App info",style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
            fontSize: 20
        ),),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.android,color: Colors.green,size: 60,)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(packageInfo['packageName']!,maxLines: 2,overflow: TextOverflow.ellipsis,style: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
              ),),
            ],
          ),
          Divider(
            thickness: 2,
            color: Colors.grey[200],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SimpleRectangleIconMaterialButton(
                buttonText: "Offload",
                buttonIcon: const Icon(FontAwesomeIcons.archive,color: Colors.blue,),
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (context)=>PromptDialog(
                      title: "Offload ${packageInfo['packageName']!}?",
                      contentText: "This will uninstall the app while retaining its data. Yes that's right! Upon re-installation, the app will continue from where it was left off (Similar to what iOS does). If you want to remove the data completely, install the app again and uninstall normally",
                      onConfirm: () async{
                        if(await adbService.uninstallApp(packageName: packageInfo['packageName']!,keepData: true)!=0){
                          await showDialog(
                            context: context,
                            builder: (context)=>AlertDialog(
                              title: const Text("Error",style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600
                              ),),
                              content: const Text("An error occurred"),
                              actions: [
                                TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child: const Text("OK",style: TextStyle(
                                      color: Colors.blue
                                  ),),
                                ),
                              ],
                            ),
                          );
                        }else{
                          onUninstallComplete();
                        }
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              SimpleRectangleIconMaterialButton(
                buttonText: "Force stop",
                buttonIcon: const Icon(Icons.warning_amber_rounded,color: Colors.blue,),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context)=>PromptDialog(
                      title: "Force Stop?",
                      contentText: "If you force stop an app, it may misbehave",
                      onConfirm: () async{
                        await adbService.forceStopPackage(packageInfo['packageName']!);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              SimpleRectangleIconMaterialButton(
                buttonText: "Uninstall",
                buttonIcon: const Icon(Icons.delete,color: Colors.blue,),
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (context)=>PromptDialog(
                      title: packageInfo['packageName']!,
                      contentText: "Do you want to uninstall this app?",
                      onConfirm: () async{
                        if(await adbService.uninstallApp(packageName: packageInfo['packageName']!)!=0){
                          await showDialog(
                            context: context,
                            builder: (context)=>AlertDialog(
                              title: const Text("Error",style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600
                              ),),
                              content: const Text("An error occurred"),
                              actions: [
                                TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child: const Text("OK",style: TextStyle(
                                    color: Colors.blue
                                  ),),
                                ),
                              ],
                            ),
                          );
                        }else{
                          onUninstallComplete();
                        }
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          Divider(
            thickness: 2,
            color: Colors.grey[200],
          ),
          if(appSuspendSupported(device.androidAPILevel) || appCompilationSupported(device.androidAPILevel))
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if(appSuspendSupported(device.androidAPILevel))
                    Tooltip(
                      message: "Suspending Apps will disable the ability to launch them on your phone. Don't fret! Your data will remain intact and may unsuspend them by using the unsuspend option",
                      child: SimpleRectangleIconMaterialButton(
                        buttonIcon: const Icon(Icons.ac_unit, color: Colors.blue,),
                        buttonText: "Suspend",
                        onPressed: () async {
                          if((await adbService.suspendApp(packageInfo['packageName']!))==0){
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("App Suspended")));
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to Suspend App")));
                          }
                        },
                      ),
                    ),
                  if(appSuspendSupported(device.androidAPILevel))
                    Tooltip(
                    message: "Unsuspending apps will restore normal functionality",
                    child: SimpleRectangleIconMaterialButton(
                      buttonIcon: const Icon(Icons.wb_sunny_rounded, color: Colors.blue,),
                      buttonText: "Unsuspend",
                      onPressed: () async {
                        if((await adbService.unsuspendApp(packageInfo['packageName']!))==0){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("App Un-Suspended")));
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to Un-Suspend App")));
                        }
                      },
                    ),
                  ),
                  if(appCompilationSupported(device.androidAPILevel))
                    Tooltip(
                      message: "You can opt to trade speed for space or vice versa. Applications may take up less or more space depending on your choice",
                      child: SimpleRectangleIconMaterialButton(
                        buttonIcon: const Icon(Icons.refresh_rounded, color: Colors.blue,),
                        buttonText: "Recompile",
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context)=>SelectCompilationModeDialog(packageName: packageInfo['packageName']!,adbService: adbService,),
                          );
                        },
                      ),
                    ),
                ],
              ),
              Divider(
                thickness: 2,
                color: Colors.grey[200],
              ),
            ],
          ),
          AppActionListTile(
            titleText: (packageInfo['installer'])=="null"?"Not Specified":packageInfo['installer']!,
            subtitleText: "Installer",
            onTap: (){},
          ),
        ],
      ),
    );
  }
}


class AppActionListTile extends StatelessWidget {

  final String titleText;
  final String subtitleText;
  final VoidCallback onTap;

  const AppActionListTile({Key? key, required this.titleText, required this.subtitleText, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(titleText,style: const TextStyle(
        fontSize: 20
      ),),
      dense: true,
      onTap: onTap,
      subtitle: Text(subtitleText),
    );
  }
}
