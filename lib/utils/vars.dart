
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

String adbExecutable="adb";

final windowButtonColors = WindowButtonColors(
    iconNormal: Colors.white,
    mouseOver: Colors.lightBlueAccent,
    mouseDown: Colors.blue,
    iconMouseOver: Colors.white,
    iconMouseDown: Colors.white
);

final windowCloseButtonColors = WindowButtonColors(
    mouseOver: Colors.redAccent,
    mouseDown: Colors.blue,
    iconNormal: Colors.white,
    iconMouseOver: Colors.white
);

final List<Color> clipboardChipColors=[
  Colors.pink,
  Colors.green,
  Colors.red,
  Colors.blueGrey,
  Colors.cyan
];