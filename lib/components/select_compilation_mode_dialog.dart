import 'package:adb_gui/services/adb_services.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:flutter/material.dart';

import '../utils/const.dart';

class SelectCompilationModeDialog extends StatefulWidget {
  final String packageName;
  final ADBService adbService;
  const SelectCompilationModeDialog({Key? key, required this.packageName, required this.adbService}) : super(key: key);

  @override
  _SelectCompilationModeDialogState createState() => _SelectCompilationModeDialogState(packageName,adbService);
}

class _SelectCompilationModeDialogState extends State<SelectCompilationModeDialog> {

  final String packageName;
  final ADBService adbService;

  _SelectCompilationModeDialogState(this.packageName,this.adbService);

  CompilationMode selectedCompilationMode = CompilationMode.speed;
  ProcessStatus processStatus = ProcessStatus.notStarted;


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(processStatus==ProcessStatus.working?"Compiling":"Select Compilation Mode"),
          const SizedBox(
            width: 20,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded,color: kAccentColor,),
            onPressed: (){
              showDialog(
                context: context,
                builder: (context)=>AlertDialog(
                  title: const Text("Info"),
                  content: const Text("The JIT (Just In Time) compiler compiles an app on launch. This can save space but since it does compilation on launch, some apps may take more time to launch. On the other hand, you can also choose to compile an app beforehand thus improving launch times but this will require more space on your storage. You may choose a compilation mode which suits your needs."),
                  actions: [
                    TextButton(
                      child: const Text("Close"),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      content: Builder(
        builder: (context) {
          if(processStatus==ProcessStatus.working){
            return Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(
                  width: 12,
                ),
                Text("Compiling $packageName")
              ],
            );
          }
          if(processStatus==ProcessStatus.success){
            return Text("$packageName compiled successfully");
          }
          if(processStatus==ProcessStatus.fail){
            return Text("Failed to compile $packageName");
          }
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CompilationModeOption(
                  value: selectedCompilationMode,
                  groupValue: CompilationMode.speed,
                  label: "Speed",
                  toolTipMessage: "Run DEX code verification and AOT-compile all methods",
                  onClick: (value){
                    setState(() {
                      selectedCompilationMode=CompilationMode.speed;
                    });
                  },
                ),
                CompilationModeOption(
                  value: selectedCompilationMode,
                  groupValue: CompilationMode.speedProfile,
                  label: "Speed-Profile",
                  toolTipMessage: "Run DEX code verification and AOT-compile methods listed in a profile file",
                  onClick: (value){
                    setState(() {
                      selectedCompilationMode=CompilationMode.speedProfile;
                    });
                  },
                ),
                CompilationModeOption(
                  value: selectedCompilationMode,
                  groupValue: CompilationMode.quicken,
                  label: "Quicken",
                  toolTipMessage: "Runs DEX code verification and optimizes some DEX instructions to get better interpreter performance",
                  onClick: (value){
                    setState(() {
                      selectedCompilationMode=CompilationMode.quicken;
                    });
                  },
                ),
                CompilationModeOption(
                  value: selectedCompilationMode,
                  groupValue: CompilationMode.space,
                  label: "Space",
                  toolTipMessage: "Reduces space usage but requires compilation on start",
                  onClick: (value){
                    setState(() {
                      selectedCompilationMode=CompilationMode.space;
                    });
                  },
                ),
                CompilationModeOption(
                  value: selectedCompilationMode,
                  groupValue: CompilationMode.spaceProfile,
                  label: "Space-Profile",
                  toolTipMessage: "Reduces space usage but requires compilation on start",
                  onClick: (value){
                    setState(() {
                      selectedCompilationMode=CompilationMode.spaceProfile;
                    });
                  },
                ),
                CompilationModeOption(
                  value: selectedCompilationMode,
                  groupValue: CompilationMode.everything,
                  label: "Everything",
                  toolTipMessage: "Compile everything",
                  onClick: (value){
                    setState(() {
                      selectedCompilationMode=CompilationMode.everything;
                    });
                  },
                ),
              ],
            ),
          );
        }
      ),
      actions: [
        if(processStatus==ProcessStatus.notStarted)
          TextButton(
            child: const Text("Cancel"),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        if(processStatus!=ProcessStatus.working)
          TextButton(
            child: const Text("OK"),
            onPressed: () async{
              if(processStatus==ProcessStatus.notStarted){
                setState(() {
                  processStatus=ProcessStatus.working;
                });
                if((await adbService.compileApp(packageName, selectedCompilationMode))==0){
                  setState(() {
                    processStatus=ProcessStatus.success;
                  });
                }else{
                  setState(() {
                    processStatus=ProcessStatus.fail;
                  });
                }
              }else{
                Navigator.pop(context);
              }
            },
          ),
      ],
    );
  }
}


class CompilationModeOption extends StatelessWidget {

  final CompilationMode value;
  final CompilationMode groupValue;
  final String label;
  final String toolTipMessage;
  final Function onClick;

  const CompilationModeOption({Key? key, required this.value, required this.groupValue, required this.label, required this.toolTipMessage, required this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: (){
        onClick(groupValue);
      },
      child: Tooltip(
        message: toolTipMessage,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Radio(
                value: value,
                groupValue: groupValue,
                onChanged: (value){
                  onClick(value);
                },
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
