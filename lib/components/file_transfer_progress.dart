import 'dart:io';
import 'package:adb_gui/services/file_services.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

class FileTransferProgress extends StatefulWidget {
  final Process process;
  final Function getSourceSize;
  final Function getDestinationSize;
  final String sourcePath;
  final String destinationPath;
  final FileTransferType fileTransferType;

  const FileTransferProgress({Key? key,required this.process,required this.getSourceSize, required this.getDestinationSize,required this.sourcePath, required this.destinationPath,required this.fileTransferType}) : super(key: key);

  @override
  _FileTransferProgressState createState() => _FileTransferProgressState(process,getSourceSize,getDestinationSize,sourcePath,destinationPath,fileTransferType);
}

class _FileTransferProgressState extends State<FileTransferProgress> {

  final Process process;
  final Function getSourcePathSize;
  final Function getDestinationPathSize;
  final FileTransferType fileTransferType;
  final String sourcePath;
  final String destinationPath;
  int exitCode=20000;
  String _consoleOutput="Do not panic if it looks stuck\n\n";
  int sourcePathSize=0;
  int destinationPathSize=0;
  bool _calculatingProgress=false;


  _FileTransferProgressState(this.process,this.getSourcePathSize,this.getDestinationPathSize,this.sourcePath,this.destinationPath,this.fileTransferType);



  void getSourceSizeAndUpdateProgress() async{
    sourcePathSize=await getSourcePathSize(sourcePath);
    setState(() {});
  }

  String getSizeAsMegaBytes(int numBytes){
    return (numBytes/(1024*1024)).toStringAsFixed(2);
  }

  String convertKBtoMB(int numBytes){
    return (numBytes/1024).toStringAsFixed(2);
  }

  String destinationSizeMB(){
    if(exitCode==0){
      return sourceSizeMB();
    }
    return fileTransferType==FileTransferType.phoneToPC?getSizeAsMegaBytes(destinationPathSize):convertKBtoMB(destinationPathSize);
  }

  String sourceSizeMB(){
    return fileTransferType==FileTransferType.phoneToPC?convertKBtoMB(sourcePathSize):getSizeAsMegaBytes(sourcePathSize);
  }

  void calculateProgress(){
    Timer.periodic(const Duration(seconds: 2), (timer) async{
      if(!_calculatingProgress && exitCode==20000){
        setState(() {
          _calculatingProgress=true;
        });
        destinationPathSize=await getDestinationPathSize(destinationPath+(fileTransferType==FileTransferType.phoneToPC?getPlatformDelimiter():"")+getLastPathElement(sourcePath));
        setState(() {
          _calculatingProgress=false;
        });
      }
    });
  }



  void monitorTransferStatus() async{
    exitCode=await process.exitCode;
    setState(() {
      if(exitCode==0){
        _consoleOutput+="\nOperation Complete";
      }
    });
  }

  @override
  void initState() {
    getSourceSizeAndUpdateProgress();
    calculateProgress();
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
            height: constraints.maxHeight*0.5,
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
                  if(exitCode!=0)
                    Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        LinearProgressIndicator(
                          value: (sourcePathSize==0 || destinationPathSize==0)?null:((double.parse(destinationSizeMB())/double.parse(sourceSizeMB()))),
                        ),
                        if(sourcePathSize!=0 && destinationPathSize!=0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${destinationSizeMB()}MB of ${sourceSizeMB()}MB complete",overflow: TextOverflow.fade,style: const TextStyle(
                                fontWeight: FontWeight.w600
                              ),),
                              Text(((double.parse(destinationSizeMB())/double.parse(sourceSizeMB()))*100).toStringAsFixed(2)+" %",overflow: TextOverflow.fade,style: const TextStyle(
                                fontWeight: FontWeight.w600
                              ),)
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Text("Calculating size",style: TextStyle(
                                fontWeight: FontWeight.w600
                              ),)
                            ],
                          )
                      ],
                    ),
                  const SizedBox(
                    height: 8,
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
