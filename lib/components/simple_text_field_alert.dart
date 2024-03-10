import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';


class SimpleTextFieldAlert extends StatelessWidget {
  final String title;
  final TextEditingController textFieldController;
  final String hintText;
  final VoidCallback action;
  const SimpleTextFieldAlert({Key? key,required this.title, required this.textFieldController, required this.hintText, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title,style: TextStyle(
        color: SystemTheme.accentColor.accent
      ),),
      content: TextField(
        controller: textFieldController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          focusColor: SystemTheme.accentColor.accent,
          hintText: hintText,
        ),
      ),
      actions: [
        TextButton(onPressed: action, child: Text("OK",style: TextStyle(color: SystemTheme.accentColor.accent),))
      ],
    );
  }
}
