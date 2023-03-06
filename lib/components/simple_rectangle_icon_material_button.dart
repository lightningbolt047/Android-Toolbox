import 'package:flutter/material.dart';

import '../utils/const.dart';

class SimpleRectangleIconMaterialButton extends StatelessWidget {
  final Icon buttonIcon;
  final String buttonText;
  final VoidCallback onPressed;
  const SimpleRectangleIconMaterialButton({Key? key,required this.buttonIcon,required this.buttonText, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18)
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            buttonIcon,
            Text(buttonText,style: const TextStyle(
              color: kAccentColor,
              fontWeight: FontWeight.w700,
            ),),
          ],
        ),
      ),
      onPressed: onPressed,
    );
  }
}
