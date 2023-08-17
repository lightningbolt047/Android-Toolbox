import 'dart:io';
import 'package:adb_gui/components/page_subheading.dart';
import 'package:adb_gui/models/device.dart';
import 'package:adb_gui/utils/vars.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PowerControlsScreen extends StatelessWidget {
  final Device device;
  const PowerControlsScreen({Key? key,required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const PageSubheading(subheadingName: "Basic"),
        ActionTile(
          leadingIcon: const Icon(FontAwesomeIcons.powerOff,color: Colors.red,),
          titleText: "Power Off",
          subtitleText: "Shuts the device down",
          deviceID: device.id,
          arguments: const ["shell","reboot","-p"],
        ),
        ActionTile(
          leadingIcon: const Icon(FontAwesomeIcons.android,color: Colors.green,),
          titleText: "Reboot (System)",
          subtitleText: "Reboot and boot back into Android",
          deviceID: device.id,
          arguments: const ["reboot"],
        ),
        const PageSubheading(subheadingName: "Advanced"),
        ActionTile(
          leadingIcon: const Icon(Icons.settings,color: Colors.blueGrey),
          titleText: "Reboot to bootloader",
          subtitleText: "Reboot and boot into the bootloader (May vary by device)",
          deviceID: device.id,
          arguments: const ["reboot","bootloader"],
        ),
        ActionTile(
          leadingIcon: const Icon(Icons.settings_backup_restore_rounded,color: Color(0xFF1592B4),),
          titleText: "Reboot to recovery",
          subtitleText: "Reboot and boot into the recovery (May vary by device)",
          deviceID: device.id,
          arguments: const ["reboot","recovery"],
        ),
        ActionTile(
          leadingIcon: const Icon(Icons.system_update_rounded,color: Colors.blueAccent),
          titleText: "Reboot to sideload",
          subtitleText: "Reboot directly into recovery's sideload mode (May vary by device)",
          deviceID: device.id,
          arguments: const ["reboot","sideload"],
        ),
        ActionTile(
          leadingIcon: const Icon(Icons.warning,color: Colors.amber),
          titleText: "Reboot to fastboot",
          subtitleText: "Reboot and boot into fastboot mode (May vary by device)",
          deviceID: device.id,
          arguments: const ["reboot","fastboot"],
        ),
      ],
    );
  }
}


class ActionTile extends StatefulWidget {
  final String deviceID;
  final List<String> arguments;
  final String titleText;
  final Icon leadingIcon;
  final String subtitleText;

  const ActionTile({Key? key,required this.deviceID,required this.arguments,required this.titleText,required this.leadingIcon,required this.subtitleText}) : super(key: key);

  @override
  _ActionTileState createState() => _ActionTileState(deviceID,arguments,titleText,leadingIcon,subtitleText);
}


class _ActionTileState extends State<ActionTile> {

  final String deviceID;
  final List<String> arguments;
  final String titleText;
  final Icon leadingIcon;
  final String subtitleText;

  _ActionTileState(this.deviceID,this.arguments,this.titleText,this.leadingIcon,this.subtitleText);


  bool _doingWork=false;
  bool _doneOnce=false;
  bool _error=false;

  void performAction() async{
    List<String> fullArguments=["-s",deviceID];
    fullArguments.addAll(arguments);
    setState(() {
      _doingWork=true;
    });
    ProcessResult processResult=await Process.run(adbExecutable, fullArguments);

    setState(() {
      if(processResult.exitCode==0){
       _error=false;
      }else{
        _error=true;
      }
      _doneOnce=true;
      _doingWork=false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leadingIcon,
      title: Text(titleText,style: const TextStyle(
        fontSize: 15
      ),),
      onTap: performAction,
      subtitle: Text(subtitleText),
      trailing: _doingWork?const CircularProgressIndicator():(_error && _doneOnce)?const Icon(Icons.error,color: Colors.red,):_doneOnce?const Icon(Icons.check_circle,color: Colors.green,):const Icon(Icons.arrow_forward_rounded),
    );
  }
}

