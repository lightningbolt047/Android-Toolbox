import 'dart:io';

import 'package:adb_gui/services/update_services.dart';
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
    }else if(_error){
      return const Text("Download failed");
    }
    return Text("New update available! ${(updateInfo['preRelease']!=null && updateInfo['preRelease'])?"(Prerelease)":""}",style: const TextStyle(
        color: Colors.blue
    ),);
  }

  Widget _getDialogContent(){
    if(_isDownloading){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Update download in progress",style: TextStyle(
            ),
          ),
          SizedBox(
            width: 25,
          ),
          CircularProgressIndicator()
        ],
      );
    }else if(_error){
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
        if(!_isDownloading)
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
        if(!_isDownloading)
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
  final bool disabled;
  UpdateNowButton({Key? key,required this.updateFileLink,required this.beforeExecution,required this.onError,required this.afterExecution,this.disabled=false}) : super(key: key);

  void installUpdate(String pathToFile) async{
    if(Platform.isWindows){
      Process.run("start",[pathToFile],runInShell: true);
    }
    await Process.run(adbExecutable, ["kill-server"],runInShell: true);
    super.onPressed!();
  }

  @override
  Widget build(BuildContext context){
    return TextButton(
      child: const Text("Update Now",style: TextStyle(
          color: Colors.blue
      ),),
      onPressed: disabled?null:() async{
        beforeExecution();
        try{
          // print(await downloadRelease(updateFileLink));
          installUpdate(await downloadRelease(updateFileLink));

        }catch(e){
          onError();
        }
        afterExecution();
      },
    );
  }
}
