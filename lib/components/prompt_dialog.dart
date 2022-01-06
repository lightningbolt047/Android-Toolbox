import 'package:flutter/material.dart';

class PromptDialog extends StatelessWidget {
  final String title;
  final String contentText;
  final VoidCallback onConfirm;
  const PromptDialog({Key? key,required this.title,required this.contentText, required this.onConfirm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title,style: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.w600,
      ),),
      content: Text(contentText),
      actions: [
        TextButton(
          child: const Text("Cancel",style: TextStyle(color: Colors.blue),),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text("OK",style: TextStyle(color: Colors.blue),),
          onPressed: onConfirm,
        ),
      ],
    );
  }
}
