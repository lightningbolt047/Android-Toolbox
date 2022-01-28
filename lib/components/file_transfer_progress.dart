import 'dart:io';
import 'package:adb_gui/components/console_output.dart';
import 'package:adb_gui/services/file_services.dart';
import 'package:adb_gui/services/string_services.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:percent_indicator/linear_percent_indicator.dart';

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

  // String convertKBtoMB(int numBytes){
  //   return (numBytes/1024).toStringAsFixed(2);
  // }




  void calculateProgress(){
    Timer.periodic(const Duration(seconds: 2), (timer) async{
      if(!_calculatingProgress && exitCode==20000){
        setState(() {
          _calculatingProgress=true;
        });
        destinationPathSize=math.max(destinationPathSize, await getDestinationPathSize(destinationPath+(fileTransferType==FileTransferType.phoneToPC?getPlatformDelimiter():"")+getLastPathElement(sourcePath)));
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
                  ConsoleOutput(consoleOutput: _consoleOutput),
                  SizedBox.fromSize(
                    size: const Size(0,4),
                  ),
                  if(exitCode!=0)
                    Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        LinearPercentIndicator(
                          animateFromLastPercent: true,
                          animation: true,
                          padding: const EdgeInsets.all(0),
                          progressColor: Colors.blue,
                          percent: (sourcePathSize==0 || destinationPathSize==0 || destinationPathSize>=sourcePathSize?0:(destinationPathSize/sourcePathSize)),
                        ),
                        if(sourcePathSize!=0 && destinationPathSize!=0 && destinationPathSize<sourcePathSize)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${getFileSizeWithUnits(destinationPathSize.toDouble())} of ${getFileSizeWithUnits(sourcePathSize.toDouble())} complete",overflow: TextOverflow.fade,style: const TextStyle(
                                fontWeight: FontWeight.w600
                              ),),
                              Text(((destinationPathSize/sourcePathSize)*100).toStringAsFixed(2)+" %",overflow: TextOverflow.fade,style: const TextStyle(
                                fontWeight: FontWeight.w600
                              ),)
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Text("Calculating progress",style: TextStyle(
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
