import 'package:flutter/material.dart';

class MaterialRibbon extends StatelessWidget {
  final Widget child;
  const MaterialRibbon({Key? key,required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints) {
        return Container(
          color: Colors.transparent,
          width: constraints.maxWidth,
          height: 45,
          child: child,
        );
      }
    );
  }
}
