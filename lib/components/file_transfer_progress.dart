import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FileTransferProgress extends StatefulWidget {
  final Process process;

  const FileTransferProgress({Key? key,required this.process}) : super(key: key);

  @override
  _FileTransferProgressState createState() => _FileTransferProgressState(process);
}

class _FileTransferProgressState extends State<FileTransferProgress> {

  final Process process;
  int exitCode=20000;
  String _consoleOutput="Do not panic if it looks stuck\n\n";




  _FileTransferProgressState(this.process);

  void monitorTransferStatus() async{
    exitCode=await process.exitCode;
    setState(() {});
  }

  @override
  void initState() {
    process.stdout.listen((event) {
      setState(() {
        _consoleOutput+=String.fromCharCodes(event);
      });
    });
    monitorTransferStatus();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      elevation: 3,
      child: LayoutBuilder(
        builder: (context,constraints) {
          return SizedBox(
            height: constraints.maxHeight*0.75,
            width: constraints.maxWidth*0.5,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("File Transfer Operation",style: TextStyle(
                          color: Colors.blue,
                          fontSize: 25,
                        ),),
                        if(exitCode==20000)
                          const CircularProgressIndicator()
                        else if(exitCode==0)
                          const Icon(FontAwesomeIcons.check,color: Colors.green,)
                        else
                          const Icon(Icons.cancel,color: Colors.red,)
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: SingleChildScrollView(
                        reverse: true,
                        scrollDirection: Axis.vertical,
                        child: Text(_consoleOutput),
                      ),
                    ),
                  ),
                  SizedBox.fromSize(
                    size: const Size(0,4),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                      ),
                      color: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                        child: Text(exitCode!=0?"Cancel":"Close",style: const TextStyle(color: Colors.white),),
                      ),
                      onPressed: (){
                        if(exitCode!=0){
                          process.kill();
                        }
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
