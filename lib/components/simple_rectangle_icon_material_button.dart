import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

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
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            buttonIcon,
            Text(buttonText,style: TextStyle(
              color: SystemTheme.accentColor.accent,
              fontWeight: FontWeight.w700,
            ),),
          ],
        ),
      ),
    );
  }
}
