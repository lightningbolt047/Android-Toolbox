import 'dart:io';
import 'package:adb_gui/services/update_services.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

class UpdaterDialog extends StatefulWidget {
  final Map<String,dynamic> updateInfo;
  const UpdaterDialog({Key? key,required this.updateInfo}) : super(key: key);

  @override
  _UpdaterDialogState createState() => _UpdaterDialogState(updateInfo);
}

class _UpdaterDialogState extends State<UpdaterDialog> {

  final Map<String,dynamic> updateInfo;

  _UpdaterDialogState(this.updateInfo);

  bool _isDownloading=false;
  bool _error=false;

  Widget _getDialogTitle(){
    if(_isDownloading){
      return Text("Downloading Update",style: TextStyle(
        color: SystemTheme.accentColor.accent
      ),);
    }else if(_error){
      return const Text("Download failed");
    }
    return Text("New update available! ${(updateInfo['preRelease']!=null && updateInfo['preRelease'])?"(Prerelease)":""}",style: TextStyle(
        color: SystemTheme.accentColor.accent
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
              child: Text("Close",style: TextStyle(
                  color: SystemTheme.accentColor.accent
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

class BackgroundUpdateUI extends StatefulWidget {
  final Map<String,dynamic> updateInfo;
  const BackgroundUpdateUI({Key? key,required this.updateInfo}) : super(key: key);

  @override
  _BackgroundUpdateUIState createState() => _BackgroundUpdateUIState(updateInfo);
}

class _BackgroundUpdateUIState extends State<BackgroundUpdateUI> {

  ProcessStatus processStatus = ProcessStatus.notStarted;
  final Map<String,dynamic> updateInfo;

  _BackgroundUpdateUIState(this.updateInfo);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if(processStatus==ProcessStatus.notStarted)...[
          const Icon(Icons.update_rounded),
          const SizedBox(
            width: 16,
          ),
          Text("A new update is available to download! Version: ${updateInfo['version']} ${(updateInfo['preRelease']!=null && updateInfo['preRelease'])?"(Prerelease)":""}"),
          const Spacer(),
          UpdateNowButton(
            updateFileLink: updateInfo['assetLink'],
            beforeExecution: (){
              setState(() {
                processStatus = ProcessStatus.working;
              });
            },
            onError: (){
              setState(() {
                processStatus = ProcessStatus.fail;
              });
            },
            afterExecution: (){
              setState(() {
                processStatus = ProcessStatus.success;
              });
            },
          ),
        ],
        if(processStatus==ProcessStatus.working)...[
          const CircularProgressIndicator(),
          const SizedBox(
            width: 16,
          ),
          const Text("Downloading Update"),
        ],
        if(processStatus==ProcessStatus.fail)...[
          const Icon(Icons.cancel,color: Colors.red,),
          const SizedBox(
            width: 16,
          ),
          const Text("Failed to download update"),
        ],
        if(processStatus==ProcessStatus.success)...[
          const Icon(Icons.check_circle,color: Colors.green,),
          const SizedBox(
            width: 16,
          ),
          const Text("Update download successful"),
        ],
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
    // await Process.run(adbExecutable, ["kill-server"],runInShell: true);
    if(Platform.isWindows){
      Process.run("start",[pathToFile],runInShell: true);
      Process.run("taskkill", ["/IM","adb.exe","/F"],runInShell: true);
    }else if(Platform.isLinux){
      Process.run("nautilus", [pathToFile],runInShell: true);
    }
    super.onPressed!();
  }

  @override
  Widget build(BuildContext context){
    return TextButton(
      onPressed: disabled?null:() async{
        beforeExecution();
        try{
          // print(await downloadRelease(updateFileLink));
          installUpdate(await downloadRelease(updateFileLink));

        }catch(e){
          onError();
          return;
        }
        afterExecution();
      },
      child: Text("Update Now",style: TextStyle(
          color: SystemTheme.accentColor.accent
      ),),
    );
  }
}
