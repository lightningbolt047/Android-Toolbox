import 'dart:io';

import 'package:adb_gui/utils/update_services.dart';
import 'package:adb_gui/vars.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class UpdaterDialog extends StatefulWidget {
  final Map<String,dynamic> updateInfo;
  const UpdaterDialog({Key? key,required this.updateInfo}) : super(key: key);

  @override
  _UpdaterDialogState createState() => _UpdaterDialogState(updateInfo);
}

class _UpdaterDialogState extends State<UpdaterDialog> {

  final Map<String,dynamic> updateInfo;
  bool _isDownloading=false;
  bool _error=false;

  Widget _getDialogTitle(){
    if(_isDownloading){
      return const Text("Downloading Update",style: TextStyle(
        color: Colors.blue
      ),);
    }else if(!_error){
      return const Text("Download failed");
    }
    return const Text("New update available!",style: TextStyle(
        color: Colors.blue
    ),);
  }

  Widget _getDialogContent(){
    if(_isDownloading){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Update download in progress",style: TextStyle(
            color: Colors.blue
            ),
          ),
          CircularProgressIndicator()
        ],
      );
    }else if(!_error){
      return const Text("Check your internet connection and try again");
    }
    return Text("A new update is available to download! Version: ${updateInfo['version']}");
  }

  _UpdaterDialogState(this.updateInfo);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _getDialogTitle(),
      content: _getDialogContent(),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            child: const Text("Close",style: TextStyle(
                color: Colors.blue
            ),),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: UpdateNowButton(
            updateFileLink: updateInfo['assetLink'],
            beforeExecution: (){
              setState(() {
                _isDownloading=true;
              });
            },
            onError: (){
              setState(() {
                _error=true;
              });
            },
            afterExecution: (){
              setState(() {
                _isDownloading=false;
              });
            },
          )
        )
      ],
    );
  }
}

class UpdateNowButton extends CloseWindowButton{
  final VoidCallback beforeExecution;
  final VoidCallback onError;
  final VoidCallback afterExecution;
  final String updateFileLink;
  UpdateNowButton({Key? key,required this.updateFileLink,required this.beforeExecution,required this.onError,required this.afterExecution}) : super(key: key);

  void installUpdate(String pathToFile) async{
    if(Platform.isWindows){
      Process.start(pathToFile,[],runInShell: true,mode: ProcessStartMode.detached);
    }
    await Process.run(adbExecutable, ["kill-server"]);
    super.onPressed!();
  }

  @override
  Widget build(BuildContext context){
    return TextButton(
      child: const Text("Update Now",style: TextStyle(
          color: Colors.blue
      ),),
      onPressed: () async{
        beforeExecution();
        try{
          installUpdate(await downloadRelease(updateFileLink));

        }catch(e){
          onError();
        }
        afterExecution();
      },
    );
  }
}
