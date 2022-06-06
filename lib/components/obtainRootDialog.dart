import 'package:adb_gui/utils/const.dart';
import 'package:flutter/material.dart';

class ObtainRootDialog extends StatefulWidget {

  final Function obtainRoot;
  final Function onCompleted;

  const ObtainRootDialog({Key? key,required this.obtainRoot,required this.onCompleted}) : super(key: key);

  @override
  State<ObtainRootDialog> createState() => _ObtainRootDialogState(obtainRoot,onCompleted);
}

class _ObtainRootDialogState extends State<ObtainRootDialog> {

  Function obtainRoot;
  Function onCompleted;

  _ObtainRootDialogState(this.obtainRoot,this.onCompleted);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: obtainRoot(),
      builder: (BuildContext context,AsyncSnapshot<bool> snapshot){
        if(snapshot.connectionState==ConnectionState.waiting){
          return AlertDialog(
            title: const Text("Obtaining Root",style: TextStyle(
              color: kAccentColor,
              fontWeight: FontWeight.w600,
            ),),
            content: Row(
              children: const [
                CircularProgressIndicator(),
                SizedBox(
                  width: 12,
                ),
                Text("Obtaining Root. Grant permission from the Android device if asked.")
              ],
            ),
          );
        }
        return AlertDialog(
          title: Text(snapshot.data!?"Obtained root successfully":"Failed to obtain root",style: const TextStyle(
            color: kAccentColor,
            fontWeight: FontWeight.w600,
          ),),
          content: Text(snapshot.data!?"You are root. Act responsibly!":"Your device may not have access to root, you may not have enabled rooted debugging or you may not have granted the appropriate permissions"),
          actions: [
            TextButton(
              child: const Text("OK",style: TextStyle(color: kAccentColor),),
              onPressed: (){
                Navigator.pop(context);
                onCompleted();
              },
            ),
          ],
        );

      },
    );
  }
}
