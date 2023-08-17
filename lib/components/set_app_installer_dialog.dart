import 'package:adb_gui/components/page_subheading.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SetAppInstallerDialog extends StatefulWidget {
  const SetAppInstallerDialog({Key? key}) : super(key: key);

  @override
  _SetAppInstallerDialogState createState() => _SetAppInstallerDialogState();
}

class _SetAppInstallerDialogState extends State<SetAppInstallerDialog> {


  AppInstaller selectedAppInstaller = AppInstaller.googlePlayStore;

  late final TextEditingController appInstallerController;



  void setInstaller(){

  }



  @override
  void initState() {
    appInstallerController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    appInstallerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      elevation: 3,
      child: LayoutBuilder(
        builder: (context,constraints){
          return SizedBox(
            height: constraints.maxHeight*0.4,
            width: constraints.maxWidth*0.6,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const PageSubheading(subheadingName: "Select Installer"),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          InstallerAppListTile(
                            installerIcon: const Icon(FontAwesomeIcons.googlePlay),
                            installerName: "Google Play Store",
                            value: selectedAppInstaller,
                            groupValue: AppInstaller.googlePlayStore,
                            onPressed: (value){
                              setState(() {
                                selectedAppInstaller = AppInstaller.googlePlayStore;
                              });
                            },
                          ),
                          ListTile(
                            leading: Radio(
                              value: selectedAppInstaller,
                              groupValue: AppInstaller.custom,
                              onChanged: (value){
                                setState(() {
                                  selectedAppInstaller=AppInstaller.custom;
                                });
                              },
                            ),
                            title: TextField(
                              controller: appInstallerController,
                              decoration: InputDecoration(
                                enabled: selectedAppInstaller==AppInstaller.custom,
                                hintText: "com.android.vending",
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      child: const Text("OK",),
                      onPressed: () async{
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class InstallerAppListTile extends StatelessWidget {

  final Icon installerIcon;
  final String installerName;
  final AppInstaller value;
  final AppInstaller groupValue;
  final Function onPressed;

  const InstallerAppListTile({Key? key,required this.installerIcon, required this.installerName, required this.value, required this.groupValue, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Radio(
        value: value,
        groupValue: groupValue,
        onChanged: (value){
          onPressed(value);
        },
      ),
      title: Row(
        children: [
          installerIcon,
          const SizedBox(
            width: 12,
          ),
          Text(installerName,style: Theme.of(context).textTheme.headline6),
        ],
      ),
    );
  }
}

