import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:adb_gui/vars.dart';

class CustomMinimizeWindowButton extends MinimizeWindowButton{
  CustomMinimizeWindowButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialButton(
        shape: const CircleBorder(),
        color: Colors.blue,
        elevation: 0,
        minWidth: 8,
        hoverColor: Colors.lightBlue,
        height: 150,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.minimize,color: Colors.white,),
        ),
        onPressed: () async{
          super.onPressed!();
        },
    );
  }


}

class CustomMaximizeWindowButton extends MaximizeWindowButton{
  CustomMaximizeWindowButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialButton(
      shape: const CircleBorder(),
      color: Colors.blue,
      elevation: 0,
      minWidth: 8,
      hoverColor: Colors.lightBlue,
      height: 150,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.check_box_outline_blank,color: Colors.white,),
      ),
      onPressed: onPressed,
    );
  }
}

class CustomCloseWindowButton extends CloseWindowButton{
  CustomCloseWindowButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialButton(
      shape: const CircleBorder(),
      color: Colors.blue,
      elevation: 0,
      minWidth: 8,
      hoverColor: Colors.redAccent,
      height: 150,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.close,color: Colors.white,),
      ),
      onPressed: () async{
        await Process.run(adbExecutable, ["kill-server"]);
        super.onPressed!();
      },
    );
  }
}