import 'package:adb_gui/utils/enums.dart';
import 'package:flutter/material.dart';

class SelectCompilationModeDialog extends StatefulWidget {
  const SelectCompilationModeDialog({Key? key}) : super(key: key);

  @override
  _SelectCompilationModeDialogState createState() => _SelectCompilationModeDialogState();
}

class _SelectCompilationModeDialogState extends State<SelectCompilationModeDialog> {

  CompilationMode selectedCompilationMode = CompilationMode.speed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Compilation Mode"),
      content: Column(
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
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text("OK"),
          onPressed: (){
            Navigator.pop(context);
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
