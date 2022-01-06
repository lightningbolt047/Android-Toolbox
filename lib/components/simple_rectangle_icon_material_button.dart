import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SimpleRectangleIconMaterialButton extends StatelessWidget {
  final Icon buttonIcon;
  final String buttonText;
  final VoidCallback onPressed;
  const SimpleRectangleIconMaterialButton({Key? key,required this.buttonIcon,required this.buttonText, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            buttonIcon,
            Text(buttonText,style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w700,
            ),),
          ],
        ),
      ),
      onPressed: onPressed,
    );
  }
}
