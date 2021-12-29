import 'package:adb_gui/screens/connection_initiation_screen.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'vars.dart';
import 'dart:io';

void main() {

  if(kDebugMode){
    adbExecutable="adb";
  }else{
    if(Platform.isWindows){
      adbExecutable="data/flutter_assets/assets/adb.exe";
    }else if(Platform.isLinux){
      adbExecutable="assets/adb";
    }
  }

  runApp(const MaterialApp(
    home: ConnectionInitiationScreen(),
  ));

  doWhenWindowReady(() {
    const initialSize = Size(1000, 625);
    appWindow.minSize = const Size(850, 525);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title="ADB GUI";
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String cmdResult="No result";

  void _executeCommand() async {
    setState(() {
      cmdResult="Running command";
    });
    // ProcessResult streamResult=Process.start(executable, arguments)
    // Process process=await Process.start("adb",["shell","ls","/sdcard/"],runInShell: true);
    Process process=await Process.start("adb",["push","C:\\Users\\sasha\\Desktop\\Movies\\The.Matrix.Revolutions.2003.4K.HDR.2160p.BDRip Ita Eng x265-NAHOM\\","/sdcard/Movies/"],runInShell: true);
    cmdResult="";
      // Stream<String> resultString = event.outLines;
    // stdout.addStream(process.stdout);
      process.stdout.listen((event) {
        print(String.fromCharCodes(event));
        setState(() {
          cmdResult+=String.fromCharCodes(event);
        });
      });
      // resultString.listen((event) {
      //   setState(() {
      //     // for(int i=0;i<.length;i++){
      //       cmdResult+=event+"\n";
      //     // }
      //   });
      // });
      // setState(() {
      //   // cmdResult="";
      // });
    // print(result.outText);
    // var result = await Shell().run("flutter doctor");
    // setState(() {
    //   List<String> resultString=result.outLines.toList();
    //   cmdResult="";
    //   for(int i=0;i<resultString.length;i++){
    //     cmdResult+=resultString[i]+"\n";
    //   }
    //   // cmdResult+=result.outLines.toList().toString();
    // });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Command output console',
            ),
            Text(
              cmdResult,
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _executeCommand,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
