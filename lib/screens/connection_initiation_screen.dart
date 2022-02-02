import 'dart:async';
import 'dart:io';
import 'package:adb_gui/components/icon_name_material_button.dart';
import 'package:adb_gui/components/updater_dialog.dart';
import 'package:adb_gui/components/window_buttons.dart';
import 'package:adb_gui/screens/home_screen.dart';
import 'package:adb_gui/screens/settings_screen.dart';
import 'package:adb_gui/services/shared_prefs.dart';
import 'package:adb_gui/services/update_services.dart';
import 'package:adb_gui/utils/vars.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adb_gui/models/device.dart';
import 'package:shimmer/shimmer.dart';


class ConnectionInitiationScreen extends StatefulWidget {
  const ConnectionInitiationScreen({Key? key}) : super(key: key);

  @override
  _ConnectionInitiationScreenState createState() => _ConnectionInitiationScreenState();
}

class _ConnectionInitiationScreenState extends State<ConnectionInitiationScreen> with SingleTickerProviderStateMixin {

  int selectedDeviceIndex=0;
  final TextEditingController _addressFieldController=TextEditingController();
  final TextEditingController _pairingCodeFieldController=TextEditingController();
  final TextEditingController _pairingAddressFieldController=TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Device> devices=[];
  bool _serverStarted=false;


  Future<List<Device>> getDevices() async{
    if(!_serverStarted){
      if(Platform.isLinux && !kDebugMode){
        await Process.run("chmod",["+x",adbExecutable]);
      }
      if(!kDebugMode && (await getKillADBDuringStartPreference())!){
        await Process.run(adbExecutable,["kill-server"]);
      }
      await Process.run(adbExecutable, ["start-server"]);
      _serverStarted=true;
    }
    ProcessResult result=await Process.run(adbExecutable, ["devices"]);
    List<String> devicesResultFromConsole=result.stdout.split("\n");
    devicesResultFromConsole.removeLast();
    devicesResultFromConsole.removeLast();
    devicesResultFromConsole.removeAt(0);

    if(selectedDeviceIndex>=devicesResultFromConsole.length && devicesResultFromConsole.isNotEmpty){
      selectedDeviceIndex=devicesResultFromConsole.length-1;
    }

    for(int i=0;i<devicesResultFromConsole.length;i++){
      if(_addressFieldController.text==devicesResultFromConsole[i].split("	")[0].trim()){
        selectedDeviceIndex=i;
        _addressFieldController.clear();
      }
    }

    devices.clear();
    for(int i=0;i<devicesResultFromConsole.length;i++){
      List<String> deviceInfoSplit=devicesResultFromConsole[i].split("	");
      devices.add(Device(i, deviceInfoSplit[0].trim(), deviceInfoSplit[1].trim()=="device"?"Available":deviceInfoSplit[1].trim().replaceRange(0, 1, deviceInfoSplit[1].trim()[0].toUpperCase()),selectedDeviceIndex, (index)=>setState((){
        selectedDeviceIndex=index;
        for(int j=0;j<devices.length;j++){
          devices[j].selectedDeviceIndex=index;
        }
      })));
    }
    return devices;
  }

  void checkUpdatesBackground() async {
    Map<String, dynamic> updateInfo = await checkForUpdates();
    if (updateInfo['updateAvailable']!=null && updateInfo['updateAvailable']) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => UpdaterDialog(updateInfo: updateInfo),
      );
    }
  }

  Future<String> getDeviceProperty(String deviceID,String property) async{
    ProcessResult result=await Process.run(adbExecutable, ["-s",deviceID,"shell","getprop",property]);
    String devicePropertyValue=result.stdout.trim();
    return devicePropertyValue;
  }

  Future<Device> getDeviceAllProperties(Device device) async{
    device.setOtherDeviceAttributes(
      await getDeviceProperty(device.id, "ro.product.model"),
      await getDeviceProperty(device.id, "ro.product.manufacturer"),
      await getDeviceProperty(device.id, "ro.build.version.release"),
      int.parse(await getDeviceProperty(device.id, "ro.build.version.sdk")),
    );
    return device;
  }

  Future<List<Device>> getAllDevicesInfo() async {
    await getDevices();

    for(int i=0;i<devices.length;i++){
      devices[i]=await getDeviceAllProperties(devices[i]);
    }
    return devices;
  }

  void clearAllFields(){
    _pairingCodeFieldController.text="";
    _pairingAddressFieldController.text="";
    _addressFieldController.text="";
  }

  Future<bool> onAddressSubmit(String value) async{
    ProcessResult result=await Process.run(adbExecutable, ["connect",value]);
    if(result.stdout.toString().contains("connected")){
      setState(() {});
      clearAllFields();
      return true;
    }else if(result.stdout.toString().contains("failed")){
      await showDialog(context: context,barrierDismissible:false, builder: (context){
        return AlertDialog(
          title: const Text("Pair with Device (Android 11+)",style: TextStyle(
            fontWeight: FontWeight.w600
          ),),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Wi-Fi pairing code",style: TextStyle(
                color: Colors.grey[600]
              ),),
              const SizedBox(
                height: 8,
              ),
              TextField(
                controller: _pairingCodeFieldController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                    ),
                    focusColor: Colors.blue,
                  hintText: "000000",
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500]
                  ),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              // Text("136271"),
              Text("IP address & Port",style: TextStyle(
                color: Colors.grey[500]
              ),),
              const SizedBox(
                height: 8,
              ),
              TextField(
                controller: _pairingAddressFieldController,
                onSubmitted: (value)=>Navigator.pop(context),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusColor: Colors.blue,
                    hintText: "192.168.0.1:12345",
                    hintStyle: TextStyle(
                      color: Colors.grey[500]
                    ),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: const Text("OK",style: TextStyle(
                    color: Colors.blue
                  ),),
              ),
            ),
          ],
        );
      });
      ProcessResult pairResult=await Process.run(adbExecutable, ["pair",_pairingAddressFieldController.text,_pairingCodeFieldController.text]);
      if(pairResult.stdout.toString().trim().contains("Failed")){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pairResult.stdout.toString().trim())));
        ScaffoldMessenger.of(context).deactivate();
        return false;
      }
      return await onAddressSubmit(value);
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Target device refused connection! Check the address and try again. Make sure to be connected to the same network")));
    ScaffoldMessenger.of(context).deactivate();
    return false;
  }

  List<DataRow> getEmptyDeviceDataRows(BuildContext context){
    return [
      for(int i=0;i<5;i++)
        DataRow(
            cells: [
              for(int j=0;j<6;j++)
                DataCell(Container(
                  width: MediaQuery.of(context).size.width*0.1,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(25)
                  ),
                )),
            ]
        )
    ];
  }


  @override
  void initState() {
    _animationController=AnimationController(vsync: this,duration: const Duration(milliseconds: 500));
    _fadeAnimation=Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.decelerate));
    super.initState();
    checkUpdatesBackground();
  }


  @override
  void dispose() {
    _addressFieldController.dispose();
    _pairingCodeFieldController.dispose();
    _pairingAddressFieldController.dispose();
    _animationController.dispose();
    super.dispose();
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
                const Text("Android Toolbox",style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),),
                const Spacer(),
                WindowMaterialButton(
                  // buttonColor: Colors.blue,
                  buttonIcon: const Icon(Icons.settings,color: Colors.white,),
                  onPressed: (){
                    Navigator.push(context, CupertinoPageRoute(builder: (context)=>const SettingsScreen()));
                  },
                ),
                CustomMinimizeWindowButton(),
                CustomMaximizeWindowButton(),
                CustomCloseWindowButton(),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left:8.0,right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Lets get you connected",style: Theme.of(context).textTheme.headline3,),
                IconNameMaterialButton(
                    icon: Icon(Icons.refresh_rounded, size: 35,color: Theme.of(context).brightness==Brightness.light?Colors.blue:Colors.white,),
                    text: Text("Refresh", style: TextStyle(
                        color: Theme.of(context).brightness==Brightness.light?Colors.blue:Colors.white,
                        fontSize: 20
                    ),),
                    onPressed: (){
                      setState(() {});
                    }),
              ],
            ),
          ),
          SizedBox.fromSize(
            size: const Size(0,15),
          ),
          Expanded(
            child: Column(
              children: [
                FutureBuilder(
                    future:getAllDevicesInfo(),
                    builder: (BuildContext context,AsyncSnapshot<List<Device>> snapshot) {
                      if(!snapshot.hasData){
                        return Shimmer.fromColors(
                            baseColor: Theme.of(context).brightness==Brightness.light?const Color(0xFFE0E0E0):Colors.black12,
                            highlightColor: Theme.of(context).brightness==Brightness.light?const Color(0xFFF5F5F5):Colors.blueGrey,
                            enabled: true,
                            child: DevicesDataTable(deviceDataRows: getEmptyDeviceDataRows(context))
                        );
                      }
                      List<DataRow> deviceDataRows=[];
                      for(int i=0;i<snapshot.data!.length;i++){
                        deviceDataRows.add(snapshot.data![i].getDeviceInfoAsDataRow(context));
                      }
                      _animationController.forward(from: 0);
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: LimitedBox(
                                child: DevicesDataTable(deviceDataRows: deviceDataRows),
                              ),
                            ),
                            SizedBox.fromSize(
                              size: const Size(8,0),
                            ),
                          ],
                        ),
                      );
                    }
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Tip: You will need to enable USB debugging on your phone and authorize this device for it to show up here",style: TextStyle(
                        color: Colors.grey,
                      ),),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: 350,
                            maxHeight: 50,
                            minWidth: 50,
                            minHeight: 50
                        ),
                        child: TextField(
                          textAlign: TextAlign.left,
                          controller: _addressFieldController,
                          textAlignVertical: TextAlignVertical.top,
                          maxLines: 1,
                          onSubmitted: (value){
                            onAddressSubmit(value);
                          },
                          decoration: InputDecoration(
                            labelText: "Wireless ADB Address (optional)",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            suffixIcon: MaterialButton(
                              child: const Text("Connect",style: TextStyle(
                                  color: Colors.blue
                              ),),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              onPressed: (){
                                onAddressSubmit(_addressFieldController.text);
                              },
                            ),
                            hintText: "192.168.0.1:1246",
                            hintStyle: TextStyle(
                              color: Colors.grey[500]
                            ),
                            focusColor: Colors.blue,
                          ),
                        ),
                      ),
                      if(Platform.isWindows)
                        MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        color: Theme.of(context).brightness==Brightness.light?Colors.blue:Colors.blueGrey,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset("assets/WSA_logo.png",fit: BoxFit.contain,),
                            ),
                            const Text("Connect to Windows Subsystem for Android",maxLines: 3,overflow: TextOverflow.ellipsis,style: TextStyle(
                                color: Colors.white
                            ),),
                          ],
                        ),
                        onPressed: () async{
                          if(await onAddressSubmit("127.0.0.1:58526")){
                            Device wsaDevice=await getDeviceAllProperties(Device.wsaCons("127.0.0.1:58526"));
                            await Navigator.push(context, CupertinoPageRoute(builder: (context)=>HomeScreen(device:wsaDevice,)));
                            setState(() {});
                            return;
                          }
                          showDialog(context: context, builder: (context){
                            return AlertDialog(
                              title: const Text("Unable to connect",style: TextStyle(
                                color: Colors.blue
                              ),),
                              content: const Text("Make sure to start Windows Subsystem for Android and enable Developer Mode before attempting to connect"),
                              actions: [
                                TextButton(
                                    onPressed: (){
                                      Navigator.pop(context);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("OK",style: TextStyle(
                                        color: Colors.blue,
                                      ),),
                                    )
                                ),
                              ],
                            );
                          });
                        },
                      ),
                      Builder(
                          builder: (context) {
                            return MaterialButton(
                              shape: const CircleBorder(),
                              // color: Colors.blue,
                              color: Theme.of(context).brightness==Brightness.light?Colors.blue:Colors.blueGrey,
                              disabledColor: Colors.grey,
                              child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.arrow_forward_rounded,color: Colors.white,size: 45,)
                              ),
                              onPressed: () async {
                                if(devices.length<=selectedDeviceIndex){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(devices.isEmpty?"No devices found! Check your USB drivers":"Invalid Device Selected")
                                      )
                                  );
                                  ScaffoldMessenger.of(context).deactivate();
                                  return;
                                }
                                await Navigator.push(context, CupertinoPageRoute(builder: (context)=>HomeScreen(device:devices[selectedDeviceIndex])));
                                setState(() {});
                              },
                            );
                          }
                      ),
                    ],
                  ),
                ),
                SizedBox.fromSize(
                  size: const Size(0,10),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class DevicesDataTable extends StatelessWidget {

  final List<DataRow> deviceDataRows;

  const DevicesDataTable({Key? key,required this.deviceDataRows}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection:Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
              label: Text("Select",maxLines: 3,style: Theme.of(context).textTheme.headline6,)
          ),
          DataColumn(
              label: Text("S No.",maxLines: 3,style: Theme.of(context).textTheme.headline6,)
          ),
          DataColumn(
              label: Text("Model",maxLines: 3,style: Theme.of(context).textTheme.headline6,)
          ),
          DataColumn(
              label: Text("Manufacturer",maxLines: 3,style: Theme.of(context).textTheme.headline6,)
          ),
          DataColumn(
              label: Text("Android",maxLines: 3,style: Theme.of(context).textTheme.headline6,)
          ),
          DataColumn(
              label: Text("Status",maxLines: 3,style: Theme.of(context).textTheme.headline6,)
          ),
        ], rows: deviceDataRows,
      ),
    );
  }
}


