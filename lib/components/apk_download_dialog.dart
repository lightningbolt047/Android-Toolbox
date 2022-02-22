import 'package:adb_gui/utils/enums.dart';
import 'package:flutter/material.dart';

class APKDownloadDialog extends StatefulWidget {
  final Future<int> numAPKDownloaded;
  const APKDownloadDialog({Key? key,required this.numAPKDownloaded}) : super(key: key);

  @override
  _APKDownloadDialogState createState() => _APKDownloadDialogState(numAPKDownloaded);
}

class _APKDownloadDialogState extends State<APKDownloadDialog> {

  final Future<int> numAPKDownloaded;
  ProcessStatus processStatus=ProcessStatus.working;

  _APKDownloadDialogState(this.numAPKDownloaded);

  void monitorProgress() async{
    if(await numAPKDownloaded>0){
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
      title: processStatus==ProcessStatus.working?const Text("Downloading APK(s)"):processStatus==ProcessStatus.success?const Text("Success"):const Text("Failed to save APK"),
      content: processStatus==ProcessStatus.working?const LinearProgressIndicator():processStatus==ProcessStatus.success?const Text("Successfully saved APK(s) to the selected directory"):Text("Exit Code: $numAPKDownloaded"),
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
