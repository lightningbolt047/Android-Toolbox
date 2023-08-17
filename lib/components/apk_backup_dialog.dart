import 'dart:io';

import 'package:adb_gui/components/console_output.dart';
import 'package:adb_gui/components/page_subheading.dart';
import 'package:adb_gui/components/reinstall_system_app_dialog.dart';
import 'package:adb_gui/services/adb_services.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../services/file_services.dart';
import '../utils/const.dart';


class APKBackupDialog extends StatefulWidget {

  final ADBService adbService;

  const APKBackupDialog({Key? key,required this.adbService}) : super(key: key);

  @override
  State<APKBackupDialog> createState() => _APKBackupDialogState(adbService);
}

class _APKBackupDialogState extends State<APKBackupDialog> with SingleTickerProviderStateMixin {

  final ADBService adbService;

  _APKBackupDialogState(this.adbService);

  String? saveDirectoryPath;

  List<Map<String,dynamic>> _appPackageInfo=[];
  bool _fetchedAppPackageNamesOnce=false;
  ProcessStatus _processStatus=ProcessStatus.notStarted;
  
  String _consoleOutput="";

  final Map<String,dynamic> _backupProgress={
    'currentPackage':"",
    'success': 0,
    'fail': 0,
    'total':1,
  };


  Future<void> fetchAppPackageNamesOnce() async{
    if(!_fetchedAppPackageNamesOnce){
      _appPackageInfo=await adbService.getAppPackageInfo(AppType.user);

      for(int i=0;i<_appPackageInfo.length;i++){
        _appPackageInfo[i]['selected']=false;
      }

      setState((){
        _fetchedAppPackageNamesOnce=true;
      });
    }
  }



  void pickSaveDirectory() async{
    saveDirectoryPath=await pickFileFolderFromDesktop(fileItemType: FileItemType.directory, dialogTitle: "Select Directory to Store all APKs",);
    setState((){});
  }

  bool isAllSelected(){
    for(int i=0;i<_appPackageInfo.length;i++){
      if(!_appPackageInfo[i]['selected']){
        return false;
      }
    }
    return true;
  }

  int countSelected(){
    int count=0;
    for(int i=0;i<_appPackageInfo.length;i++){
      if(_appPackageInfo[i]['selected']){
        count++;
      }
    }
    return count;
  }

  bool checkPrerequisites(){
    String errorString="Error";
    bool error=false;
    if(saveDirectoryPath==null){
      errorString="Select a save destination before proceeding";
      error=true;
    }else if(countSelected()==0){
      errorString="Select at least 1 application to backup";
      error=true;
    }

    if(error){
      showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          title: const Text("Error"),
          content: Text(errorString),
          actions: [
            TextButton(
              child: const Text("OK",style: TextStyle(
                  color: kAccentColor
              ),),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
    return !error;
  }

  void backupAPKs() async {
    if(checkPrerequisites()){
      setState((){
        _processStatus=ProcessStatus.working;
        _backupProgress['total']=countSelected();
      });
      for(int i=0;i<_appPackageInfo.length;i++){
        if(_appPackageInfo[i]['selected']){
          setState((){
            _backupProgress['currentPackage']=_appPackageInfo[i]['packageName'];
            _consoleOutput+="Backing up ${_appPackageInfo[i]['packageName']}...";
          });
          if(await adbService.getAppPackages(_appPackageInfo[i]['packageName'], saveDirectoryPath!) != 0){
            _backupProgress['success']++;
            _consoleOutput+="success\n\n";
          }else{
            _backupProgress['fail']++;
            _consoleOutput+="fail\n\n";
          }
          if(_backupProgress['success']+_backupProgress['fail']==_backupProgress['total']){
            setState((){
              _processStatus=ProcessStatus.success;
            });
          }
        }
      }
    }
  }



  @override
  void initState() {
    fetchAppPackageNamesOnce();
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
        builder: (context,constraints){
          return SizedBox(
            height: _processStatus==ProcessStatus.notStarted?constraints.maxHeight*0.95:constraints.maxHeight*0.7,
            width: constraints.maxWidth*0.5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const PageSubheading(subheadingName: "Backup APKs"),

                  if(_processStatus==ProcessStatus.notStarted)...[
                    Expanded(
                      child: Builder(
                          builder: (context) {
                            if(!_fetchedAppPackageNamesOnce){
                              return Shimmer.fromColors(
                                  baseColor: Theme.of(context).brightness==Brightness.light?const Color(0xFFE0E0E0):Colors.black12,
                                  highlightColor: Theme.of(context).brightness==Brightness.light?const Color(0xFFF5F5F5):Colors.blueGrey,
                                  enabled: true,
                                  child: const GetEmptyListView()
                              );
                            }
                            return Column(
                              children: [
                                CheckboxListTile(
                                  value: isAllSelected(),
                                  activeColor: Colors.blue,
                                  title: Text("Select Apps to Backup (${countSelected()}/${_appPackageInfo.length})",style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),),
                                  onChanged: (value){
                                    setState((){
                                      for(int i=0;i<_appPackageInfo.length;i++){
                                        _appPackageInfo[i]['selected']=value;
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _appPackageInfo.length,
                                    itemBuilder: (context,index){
                                      return CheckboxListTile(
                                        activeColor: Colors.blue,
                                        title: Text(_appPackageInfo[index]['packageName']),
                                        value: _appPackageInfo[index]['selected'],
                                        onChanged: (value) async{
                                          setState((){
                                            _appPackageInfo[index]['selected']=value;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        color: saveDirectoryPath==null?Theme.of(context).brightness==Brightness.light?kAccentColor:Colors.blueGrey:Colors.green,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(saveDirectoryPath==null?FontAwesomeIcons.folder:Icons.check,color: Colors.white,),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(saveDirectoryPath==null?"Select folder to save backup":"Destination Selected",maxLines: 3,overflow: TextOverflow.ellipsis,style: const TextStyle(
                                  color: Colors.white
                              ),),
                            ],
                          ),
                        ),
                        onPressed: pickSaveDirectory,
                      ),
                    ),
                  ],
                  if(_processStatus!=ProcessStatus.notStarted)...[
                    Row(
                      children: [
                        const Text("Backing up: ",style: TextStyle(
                          fontSize: 18,
                        ),),
                        Flexible(
                          child: Text(_backupProgress['currentPackage'],maxLines: 3,overflow: TextOverflow.ellipsis,style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18
                          ),),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    ConsoleOutput(consoleOutput: _consoleOutput),
                    LinearProgressIndicator(
                      value: (_backupProgress['success']+_backupProgress['fail'])/_backupProgress['total'],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${(_backupProgress['success']+_backupProgress['fail'])}/${_backupProgress['total']}",style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),),
                        _processStatus==ProcessStatus.working?Text((((_backupProgress['success']+_backupProgress['fail'])/_backupProgress['total'])*100).toStringAsFixed(2)+"%",style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),):const Icon(Icons.check,color: Colors.green,),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("${_backupProgress['fail']} failed",style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),),
                    )
                  ]else
                    const SizedBox(
                      height: 8,
                    ),
                  // if(_processStatus!=ProcessStatus.notStarted)
                  //   const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                      if(_processStatus==ProcessStatus.notStarted)
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          color: kAccentColor,
                          disabledColor: Colors.grey,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                            child: Text("Proceed",style: TextStyle(color: Colors.white),),
                          ),
                          onPressed: (){
                            backupAPKs();
                          },
                        ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
