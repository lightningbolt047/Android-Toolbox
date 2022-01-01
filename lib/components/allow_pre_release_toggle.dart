import 'package:adb_gui/services/shared_prefs.dart';
import 'package:flutter/material.dart';


class AllowPreReleaseToggle extends StatefulWidget {
  const AllowPreReleaseToggle({Key? key}) : super(key: key);

  @override
  _AllowPreReleaseToggleState createState() => _AllowPreReleaseToggleState();
}

class _AllowPreReleaseToggleState extends State<AllowPreReleaseToggle> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAllowPreReleasePreference(),
      builder: (BuildContext context,AsyncSnapshot<bool?> snapshot){
        if(!snapshot.hasData){
          return const LinearProgressIndicator();
        }
        return SwitchListTile(
          title: const Text("Allow pre-release updates",style: TextStyle(
            fontSize: 20,
          ),),
          subtitle: const Text("Pre-Release builds may be unstable and are not for the faint of hearts. Pre-Release builds may even break updates forcing you to install some upcoming builds manually"),
          value: snapshot.data!,
          onChanged: (value) async {
            await setAllowPreReleasePreference(value);
            setState(() { });
          },
        );
      },
    );
  }
}
