import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final Icon icon;
  const CustomListTile({Key? key,required this.title, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(
          width: 4  ,
        ),
        Text(title,style: const TextStyle(
          color: Colors.blue,
        ),)
      ],
    );
  }
}
