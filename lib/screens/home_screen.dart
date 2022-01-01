import 'package:adb_gui/components/window_buttons.dart';
import 'package:adb_gui/enums.dart';
import 'package:adb_gui/models/device.dart';
import 'package:adb_gui/screens/file_manager_screen.dart';
import 'package:adb_gui/screens/power_controls_screen.dart';
import 'package:adb_gui/services/android_api_checks.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final Device device;
  const HomeScreen({Key? key,required this.device}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState(device);
}

class _HomeScreenState extends State<HomeScreen> {

  Screens _currentScreen=Screens.fileManager;
  final Device device;

  _HomeScreenState(this.device);


  String _getScreenName(Screens screenEnum){
    if(screenEnum==Screens.fileManager){
      return "Files";
    }else if(screenEnum==Screens.powerControls){
      return "Power Controls";
    }
    return "Wtf??";
  }

  @override
  void initState() {
    super.initState();
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
                Text("${_getScreenName(_currentScreen)} (${device.id} - ${device.model})",overflow: TextOverflow.ellipsis,style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20
                ),),
                const Spacer(),
                if(isLegacyAndroid(device.androidAPILevel))
                  WindowMaterialButton(
                  buttonColor: Colors.blue,
                  hoverColor: Colors.amber[300],
                  buttonIcon: Icon(Icons.warning,color: Colors.amber[700],),
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (context)=>AlertDialog(
                        title: const Text("Performance Alert",style: TextStyle(
                          color: Colors.blue
                        ),),
                        content: Text("You may experience degraded performance since your device runs on Android ${device.androidVersion} .\nThe recommended Android version is 7.0 and above"),
                        actions: [
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("OK",style: TextStyle(
                                color: Colors.blue
                              ),),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                WindowMaterialButton(
                  buttonColor: Colors.blue,
                  buttonIcon: const Icon(Icons.exit_to_app_rounded,color: Colors.white,),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
                CustomMinimizeWindowButton(),
                CustomMaximizeWindowButton(),
                CustomCloseWindowButton(),
              ],
            ),
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: (){
        //       Navigator.pop(context);
        //     },
        //     icon: const Icon(Icons.exit_to_app,color: Colors.white,),
        //   ),
        // ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10))),
        child: Builder(builder: (context) {
          return ListView(
            children: [
              DrawerHeader(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.grey],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0, bottom: 4),
                        child: Text(
                          "ADB GUI",
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                    ],
                  )),
              ListTile(
                leading: const Icon(Icons.drive_file_move),
                title: const Text("File Manager"),
                onTap: (){
                  setState(() {
                    _currentScreen=Screens.fileManager;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.power_settings_new_rounded),
                title: const Text("Power Controls"),
                onTap: (){
                  setState(() {
                    _currentScreen=Screens.powerControls;
                  });
                  Navigator.pop(context);
                },
              ),

            ],
          );
        }),
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context){
                if(_currentScreen==Screens.fileManager){
                  return FileManagerScreen(device: device,);
                }else if(_currentScreen==Screens.powerControls){
                  return PowerControlsScreen(device: device);
                }
                return PowerControlsScreen(device: device);
              },
            ),
          ),
        ],
      ),
    );
  }
}
