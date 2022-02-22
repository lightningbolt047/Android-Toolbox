import 'package:adb_gui/utils/enums.dart';
import 'package:flutter/material.dart';

class APKDownloadDialog extends StatefulWidget {
  final Future<int> exitCode;
  const APKDownloadDialog({Key? key,required this.exitCode}) : super(key: key);

  @override
  _APKDownloadDialogState createState() => _APKDownloadDialogState(exitCode);
}

class _APKDownloadDialogState extends State<APKDownloadDialog> {

  final Future<int> exitCode;
  ProcessStatus processStatus=ProcessStatus.working;

  _APKDownloadDialogState(this.exitCode);

  void monitorProgress() async{
    if(await exitCode==0){
      setState(() {
        processStatus=ProcessStatus.success;
      });
    }else{
      setState(() {
        processStatus=ProcessStatus.fail;
      });
    }
  }

  @override
  void initState() {
    monitorProgress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: processStatus==ProcessStatus.working?const Text("Downloading APK(s)"):processStatus==ProcessStatus.success?const Text("Success"):const Text("Failed to Download APK"),
      content: processStatus==ProcessStatus.working?const LinearProgressIndicator():processStatus==ProcessStatus.success?const Text("Successfully downloaded APK(s) to your Downloads directory"):Text("Exit Code: $exitCode"),
      actions: [
        if(processStatus!=ProcessStatus.working)
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
      ],
    );
  }
}
