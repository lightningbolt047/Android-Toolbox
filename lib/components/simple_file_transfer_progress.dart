import 'dart:io';
import 'package:adb_gui/utils/enums.dart';
import 'package:flutter/material.dart';

import '../utils/const.dart';

class SimpleFileTransferProgress extends StatefulWidget {
  final Process process;
  final FileTransferType fileTransferType;
  const SimpleFileTransferProgress({Key? key,required this.process,required this.fileTransferType}) : super(key: key);

  @override
  _SimpleFileTransferProgressState createState() => _SimpleFileTransferProgressState(process,fileTransferType);
}

class _SimpleFileTransferProgressState extends State<SimpleFileTransferProgress> {

  final Process process;
  final FileTransferType fileTransferType;

  int exitCode=20000;

  _SimpleFileTransferProgressState(this.process,this.fileTransferType);



  void monitorTransferStatus() async{
    exitCode=await process.exitCode;
    setState(() {});
  }

  @override
  void initState() {
    monitorTransferStatus();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("File ${fileTransferType==FileTransferType.move?"move":"copy"}",style: const TextStyle(
        color: kAccentColor
      ),),
      content: exitCode==20000?const LinearProgressIndicator():exitCode==0?Text("File ${fileTransferType==FileTransferType.move?"move":"copy"} complete"):Text("File ${fileTransferType==FileTransferType.move?"move":"copy"} failed"),
      actions: [
        TextButton(
            onPressed: exitCode==20000?null:(){
                Navigator.pop(context);
            },
            child: const Text("Close",style: TextStyle(
              color: kAccentColor
            ),),
        )
      ],
    );
  }
}
