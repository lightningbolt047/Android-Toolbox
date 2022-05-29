import 'package:adb_gui/services/adb_services.dart';
import 'package:flutter/material.dart';

class DeviceInfoListTile extends StatelessWidget {

  final String propertyName;
  final String propertyDisplayName;
  final ADBService adbService;
  final Function? transformFunction;

  const DeviceInfoListTile({Key? key,required this.propertyName,required this.propertyDisplayName,required this.adbService,this.transformFunction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(propertyDisplayName,style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16
      ),),
      subtitle: FutureBuilder(
        future: adbService.getDeviceProperty(propertyName),
        builder: (BuildContext context,AsyncSnapshot<String> snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const LinearProgressIndicator();
          }
          if(snapshot.hasError || snapshot.data==""){
            return Row(
              children: const [
                Icon(Icons.error),
                SizedBox(
                  width: 12,
                ),
                Flexible(
                  child: Text("Error fetching information. Property might not be available on your device"),
                ),
              ],
            );
          }
          return SelectableText(transformFunction==null?snapshot.data:transformFunction!(snapshot.data),);
        },
      ),
    );
  }
}
