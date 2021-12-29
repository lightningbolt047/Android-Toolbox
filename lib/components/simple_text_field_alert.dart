import 'package:flutter/material.dart';

class SimpleTextFieldAlert extends StatelessWidget {
  final String title;
  final TextEditingController textFieldController;
  final String hintText;
  final VoidCallback action;
  const SimpleTextFieldAlert({Key? key,required this.title, required this.textFieldController, required this.hintText, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title,style: const TextStyle(
        color: Colors.blue
      ),),
      content: TextField(
        controller: textFieldController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          focusColor: Colors.blue,
          hintText: hintText,
        ),
      ),
      actions: [
        TextButton(onPressed: action, child: const Text("OK",style: TextStyle(color: Colors.blue),))
      ],
    );
  }
}
