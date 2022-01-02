import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:adb_gui/utils/vars.dart';

class CustomMinimizeWindowButton extends MinimizeWindowButton{
  CustomMinimizeWindowButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){

    return WindowMaterialButton(
      buttonColor: Colors.blue,
      buttonIcon: const Icon(Icons.minimize,color: Colors.white,),
      onPressed: super.onPressed!,
    );
  }


}

class CustomMaximizeWindowButton extends MaximizeWindowButton{
  CustomMaximizeWindowButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return WindowMaterialButton(
      buttonColor: Colors.blue,
      buttonIcon: const Icon(Icons.check_box_outline_blank,color: Colors.white,),
      onPressed: super.onPressed!,
    );
  }
}

class CustomCloseWindowButton extends CloseWindowButton{
  CustomCloseWindowButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return WindowMaterialButton(
      buttonColor: Colors.blue,
      hoverColor: Colors.redAccent,
      buttonIcon: const Icon(Icons.close,color: Colors.white,),
      onPressed: () async{
        await Process.run(adbExecutable, ["kill-server"]);
        super.onPressed!();
      },
    );
  }
}


class WindowMaterialButton extends StatelessWidget {

  final Color? buttonColor;
  final Color? hoverColor;
  final Icon buttonIcon;
  final VoidCallback onPressed;

  const WindowMaterialButton({Key? key,this.buttonColor=Colors.blue,this.hoverColor=Colors.lightBlue,required this.buttonIcon,required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: const CircleBorder(),
      color: buttonColor,
      elevation: 0,
      minWidth: 8,
      hoverColor: hoverColor,
      height: 150,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: buttonIcon,
      ),
      onPressed: onPressed,
    );
  }
}
