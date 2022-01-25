import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConsoleOutput extends StatelessWidget {

  final String consoleOutput;

  const ConsoleOutput({Key? key, required this.consoleOutput}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        color: Theme.of(context).brightness==Brightness.light?Colors.grey[200]:Colors.grey[900],
        child: SingleChildScrollView(
          reverse: true,
          scrollDirection: Axis.vertical,
          child: Text(consoleOutput,style: GoogleFonts.inconsolata(),),
        ),
      ),
    );
  }
}
