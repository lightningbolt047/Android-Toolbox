import 'package:adb_gui/services/shared_prefs.dart';
import 'package:flutter/material.dart';


class PreferenceToggle extends StatefulWidget {

  final String titleText;
  final String subtitleText;
  final Function getPreference;
  final Function onChanged;

  const PreferenceToggle({Key? key, required this.titleText, required this.subtitleText, required this.getPreference, required this.onChanged}) : super(key: key);

  @override
  _PreferenceToggleState createState() => _PreferenceToggleState(titleText,subtitleText,getPreference,onChanged);
}

class _PreferenceToggleState extends State<PreferenceToggle> {

  final String titleText;
  final String subtitleText;
  final Function getPreference;
  final Function onChanged;

  _PreferenceToggleState(this.titleText,this.subtitleText,this.getPreference,this.onChanged);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getPreference(),
      builder: (BuildContext context,AsyncSnapshot<bool?> snapshot){
        if(!snapshot.hasData){
          return const LinearProgressIndicator();
        }
        return SwitchListTile(
          title: Text(titleText,style: const TextStyle(
            fontSize: 20,
          ),),
          dense: true,
          subtitle: Text(subtitleText),
          value: snapshot.data!,
          onChanged: (value) async {
            await onChanged(value);
            setState(() {});
          },
        );
      },
    );
  }
}
