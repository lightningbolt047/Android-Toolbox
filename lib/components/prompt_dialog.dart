import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
class PromptDialog extends StatelessWidget {
  final String title;
  final String contentText;
  final VoidCallback onConfirm;
  const PromptDialog({Key? key,required this.title,required this.contentText, required this.onConfirm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title,style: TextStyle(
        color: SystemTheme.accentColor.accent,
        fontWeight: FontWeight.w600,
      ),),
      content: Text(contentText),
      actions: [
        TextButton(
          child: Text("Cancel",style: TextStyle(color: SystemTheme.accentColor.accent),),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text("OK",style: TextStyle(color: SystemTheme.accentColor.accent),),
        ),
      ],
    );
  }
}
