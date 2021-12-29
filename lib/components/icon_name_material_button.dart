import 'package:flutter/material.dart';


class IconNameMaterialButton extends StatelessWidget {

  final Icon icon;
  final Text text;
  final VoidCallback onPressed;

  const IconNameMaterialButton({Key? key, required this.icon, required this.text, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          icon,
          text
        ],
      ),
      onPressed: onPressed,
    );
  }
}
