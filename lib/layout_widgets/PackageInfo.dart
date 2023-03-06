import 'package:adb_gui/components/apk_download_dialog.dart';
import 'package:adb_gui/components/prompt_dialog.dart';
import 'package:adb_gui/components/select_compilation_mode_dialog.dart';
import 'package:adb_gui/components/simple_rectangle_icon_material_button.dart';
import 'package:adb_gui/models/device.dart';
import 'package:adb_gui/services/adb_services.dart';
import 'package:adb_gui/services/android_api_checks.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/file_services.dart';
import '../utils/const.dart';

class PackageInfo extends StatelessWidget {

  final Device device;
  final Map<String,dynamic> packageInfo;
  final ADBService adbService;
  final VoidCallback onUninstallComplete;

  const PackageInfo({Key? key,required this.device,required this.packageInfo, required this.adbService,required this.onUninstallComplete}) : super(key: key);

  Future<int> performUninstall() async{
    if(packageInfo['appType']==AppType.user){
      return await adbService.uninstallApp(packageName: packageInfo['packageName']!);
    }
    return await adbService.uninstallSystemAppForUser(packageName: packageInfo['packageName']!);
  }

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
            color: kAccentColor,
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(packageInfo['packageName'],maxLines: 2,overflow: TextOverflow.ellipsis,style: const TextStyle(
                  fontSize: 20,
                  color: kAccentColor,
                ),),
              ],
            ),
          ),
          Divider(
            thickness: 2,
            color: Colors.grey[200],
          ),
          Row(
            // if(packageInfo['appType']==AppType.user)
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SimpleRectangleIconMaterialButton(
                buttonText: "Get Apk(s)",
                buttonIcon: const Icon(Icons.business_center,color: Colors.blue,),
                onPressed: () async {
                  String? chosenDirectory = await pickFileFolderFromDesktop(fileItemType: FileItemType.directory, dialogTitle: "Where to download", allowedExtensions: ["*"]);
                  if (chosenDirectory == null) {
                    return; // user cancelled and no app is fetched
                  }
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context)=>APKDownloadDialog(numAPKDownloaded: adbService.getAppPackages(packageInfo['packageName']!,chosenDirectory),),
                  );

                },
              ),
              SimpleRectangleIconMaterialButton(
                buttonText: "Open",
                buttonIcon: const Icon(Icons.open_in_new,color: kAccentColor,),
                onPressed: () async{
                  int exitCode=await adbService.launchApp(packageName: packageInfo['packageName']!);
                  if(exitCode!=0){
                    showDialog(
                      context: context,
                      builder: (context)=>AlertDialog(
                        title: const Text("Error"),
                        content: Text("Unable to launch application!${exitCode==252?" No activity found":""}. Exit Code: $exitCode"),
                        actions: [
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: const Text("OK"),
                          )
                        ],
                      ),
                    );
                  }
                },
              ), // if(packageInfo['appType']==AppType.user)
              SimpleRectangleIconMaterialButton(
                buttonText: "Uninstall",
                buttonIcon: const Icon(Icons.delete,color: kAccentColor,),
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (context)=>PromptDialog(
                      title: packageInfo['packageName']!,
                      contentText: packageInfo['appType']==AppType.system?"This is a system app and uninstalling it will only uninstall for the active user. Proceed?":"Do you want to uninstall this app?",
                      onConfirm: () async{
                        if(await performUninstall()!=0){
                          await showDialog(
                            context: context,
                            builder: (context)=>AlertDialog(
                              title: const Text("Error",style: TextStyle(
                                color: kAccentColor,
                                fontWeight: FontWeight.w600
                              ),),
                              content: const Text("An error occurred"),
                              actions: [
                                TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child: const Text("OK",style: TextStyle(
                                    color: kAccentColor
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
                buttonIcon: const Icon(Icons.warning_amber_rounded,color: kAccentColor,),
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
                          buttonIcon: const Icon(Icons.ac_unit, color: kAccentColor,),
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
                        buttonIcon: const Icon(Icons.wb_sunny_rounded, color: kAccentColor,),
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
                    if(packageInfo['appType']==AppType.user)
                      SimpleRectangleIconMaterialButton(
                        buttonText: "Offload",
                        buttonIcon: const Icon(FontAwesomeIcons.archive,color: kAccentColor,),
                        onPressed: (){
                          showDialog(
                            context: context,
                            builder: (context)=>PromptDialog(
                              title: "Offload ${packageInfo['packageName']!}?",
                              contentText: "This will uninstall the app while retaining its data. Yes that's right! Upon re-installation, the app will continue from where it was left off (Similar to what offloading in iOS does). If you want to remove the data completely, install the app again and uninstall normally.",
                              onConfirm: () async{
                                if(await adbService.uninstallApp(packageName: packageInfo['packageName']!,keepData: true)!=0){
                                  await showDialog(
                                    context: context,
                                    builder: (context)=>AlertDialog(
                                      title: const Text("Error",style: TextStyle(
                                          color: kAccentColor,
                                          fontWeight: FontWeight.w600
                                      ),),
                                      content: const Text("An error occurred"),
                                      actions: [
                                        TextButton(
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                          child: const Text("OK",style: TextStyle(
                                              color: kAccentColor
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
                    if(appCompilationSupported(device.androidAPILevel))
                      Tooltip(
                        message: "You can opt to trade speed for space or vice versa. Applications may take up less or more space depending on your choice",
                        child: SimpleRectangleIconMaterialButton(
                          buttonIcon: const Icon(Icons.refresh_rounded, color: kAccentColor,),
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
          // Row(
          //   // if(packageInfo['appType']==AppType.user)
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     SimpleRectangleIconMaterialButton(
          //       buttonText: "Revoke Internet Access",
          //       buttonIcon: const Icon(Icons.block_rounded,color: Colors.blue,),
          //       onPressed: () async {
          //         int exitCode=await adbService.revokeInternetAccess(packageInfo['packageName']);
          //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exitCode==0?"Internet access revoked for ${packageInfo['packageName']}":"Failed to revoke internet access")));
          //       },
          //     ),
          //     SimpleRectangleIconMaterialButton(
          //       buttonText: "Grant internet access",
          //       buttonIcon: const Icon(FontAwesomeIcons.globe,color: kAccentColor,),
          //       onPressed: () async{
          //         int exitCode=await adbService.grantInternetAccess(packageInfo['packageName']);
          //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exitCode==0?"Internet access granted for ${packageInfo['packageName']}":"Failed to grant internet access")));
          //       },
          //     ),
          //   ],
          // ),
          // Divider(
          //   thickness: 2,
          //   color: Colors.grey[200],
          // ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      dense: true,
      onTap: onTap,
      subtitle: Text(subtitleText),
    );
  }
}
