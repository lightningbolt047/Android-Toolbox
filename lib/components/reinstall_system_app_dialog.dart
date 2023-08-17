import 'dart:io';
import 'package:adb_gui/components/page_subheading.dart';
import 'package:adb_gui/services/adb_services.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/const.dart';

class ReinstallSystemAppDialog extends StatefulWidget {

  final ADBService adbService;

  const ReinstallSystemAppDialog({Key? key,required this.adbService}) : super(key: key);

  @override
  _ReinstallSystemAppDialogState createState() => _ReinstallSystemAppDialogState(adbService);
}

class _ReinstallSystemAppDialogState extends State<ReinstallSystemAppDialog> with SingleTickerProviderStateMixin {


  ProcessStatus processStatus = ProcessStatus.notStarted;
  final ADBService adbService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;


  _ReinstallSystemAppDialogState(this.adbService);



  @override
  void initState() {

    _animationController=AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500)
    );

    _fadeAnimation=Tween<double>(
      begin: 0,
      end: 1
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.decelerate));

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      elevation: 3,
      child: LayoutBuilder(
        builder: (context,constraints){
          return SizedBox(
            height: constraints.maxHeight*0.75,
            width: constraints.maxWidth*0.5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const PageSubheading(subheadingName: "Reinstall System App"),
                  const SizedBox(
                    height: 4,
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: adbService.getUninstalledSystemApps(),
                      builder: (BuildContext context,AsyncSnapshot<List<String>> snapshot) {

                        _animationController.forward(from: 0);

                        if(snapshot.connectionState != ConnectionState.done || !snapshot.hasData){
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Shimmer.fromColors(
                                baseColor: Theme.of(context).brightness==Brightness.light?const Color(0xFFE0E0E0):Colors.black12,
                                highlightColor: Theme.of(context).brightness==Brightness.light?const Color(0xFFF5F5F5):Colors.blueGrey,
                                enabled: true,
                                child: const GetEmptyListView()
                            ),
                          );
                        }

                        if(snapshot.data!.isEmpty){
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.android,color: Colors.grey,size: 100,),
                                Text(
                                  "No System App to Install",
                                  style: TextStyle(color: Colors.grey, fontSize: 25),
                                )
                              ],
                            ),
                          );
                        }

                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context,index){
                              return ListTile(
                                leading: const Icon(Icons.android,color: Colors.green,size: 35,),
                                title: Text(snapshot.data![index]),
                                onTap: () async{
                                  Process process = await adbService.reinstallSystemAppForUser(packageName: snapshot.data![index]);
                                  await showDialog(
                                    context: context,
                                    builder: (context)=>ReinstallProgressDialog(
                                      process: process,
                                    ),
                                  );
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        );
                      }
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    color: kAccentColor,
                    disabledColor: Colors.grey,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                      child: Text("Close",style: TextStyle(color: Colors.white),),
                    ),
                    onPressed: processStatus==ProcessStatus.working?null:(){
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class GetEmptyListView extends StatelessWidget {
  const GetEmptyListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context,index){
        return ListTile(
          leading: Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle
            ),
          ),
          title: Container(
            width: 50,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(25)
            ),
          ),
        );
      },
    );
  }
}


class ReinstallProgressDialog extends StatefulWidget {
  final Process process;

  const ReinstallProgressDialog({Key? key, required this.process}) : super(key: key);

  @override
  _ReinstallProgressDialogState createState() => _ReinstallProgressDialogState(process);
}

class _ReinstallProgressDialogState extends State<ReinstallProgressDialog> {

  int exitCode = 20000;

  final Process process;

  _ReinstallProgressDialogState(this.process);

  void monitorStatus() async{
    exitCode = await process.exitCode;
    setState(() {});
  }

  @override
  void initState() {
    monitorStatus();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(exitCode==20000?"Reinstalling":exitCode==0?"Install success":"Installation failed"),
      content: exitCode==20000?Row(
        children: const [
          CircularProgressIndicator(),
          SizedBox(
            width: 16,
          ),
          Text("Reinstall in progress")
        ],
      ):Text(exitCode==0?"System app reinstall successful":"Error occurred when reinstalling"),
      actions: [
        if(exitCode!=20000)
          TextButton(
            child: const Text("OK",style: TextStyle(
              color: kAccentColor
            ),),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
      ],
    );
  }
}

