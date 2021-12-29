import 'package:flutter/material.dart';

class PackageManagerScreen extends StatefulWidget {
  final String deviceID;
  const PackageManagerScreen({Key? key,required this.deviceID}) : super(key: key);

  @override
  _PackageManagerScreenState createState() => _PackageManagerScreenState(this.deviceID);
}

class _PackageManagerScreenState extends State<PackageManagerScreen> {

  final String deviceID;

  _PackageManagerScreenState(this.deviceID);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
