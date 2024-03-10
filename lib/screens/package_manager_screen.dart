import 'package:adb_gui/components/apk_backup_dialog.dart';
import 'package:adb_gui/components/apk_install_dialog.dart';
import 'package:adb_gui/components/custom_list_tile.dart';
import 'package:adb_gui/components/icon_name_material_button.dart';
import 'package:adb_gui/components/material_ribbon.dart';
import 'package:adb_gui/components/reinstall_system_app_dialog.dart';
import 'package:adb_gui/layout_widgets/PackageInfo.dart';
import 'package:adb_gui/models/device.dart';
import 'package:adb_gui/services/adb_services.dart';
import 'package:adb_gui/services/android_api_checks.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:system_theme/system_theme.dart';

import '../utils/const.dart';

class PackageManagerScreen extends StatefulWidget {
  final Device device;
  const PackageManagerScreen({Key? key,required this.device}) : super(key: key);

  @override
  _PackageManagerScreenState createState() => _PackageManagerScreenState(device);
}

class _PackageManagerScreenState extends State<PackageManagerScreen> {

  final Device device;

  late ADBService adbService;

  _PackageManagerScreenState(this.device);

  AppType _appType=AppType.user;

  Map<String,dynamic> _selectedPackageInfo={};

  final TextEditingController _searchbarController=TextEditingController();
  final ScrollController _appsListScrollController=ScrollController();

  @override
  void initState() {
    adbService=ADBService(device: device);
    super.initState();
  }

  @override
  void dispose() {
    _searchbarController.dispose();
    _appsListScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        MaterialRibbon(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: IconNameMaterialButton(
                        icon: Icon(Icons.android_rounded,color: SystemTheme.accentColor.accent,size: 35,),
                        spacing: 4,
                        text: Text("Install",style: TextStyle(
                          color: SystemTheme.accentColor.accent,
                          fontSize: 20
                        ),),
                        onPressed: () async{
                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context)=>ApkInstallDialog(device: device,),
                          );
                          setState(() {
                            _appType = AppType.user;
                            _searchbarController.text="";
                          });
                        },
                      )
                    ),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        onSubmitted: (value){setState(() {});},
                        controller: _searchbarController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            hintText: "Search by package name",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search_rounded,color: SystemTheme.accentColor.accent,),
                            onPressed: (){
                              setState(() {});
                            },
                          )
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconNameMaterialButton(
                        icon: Icon(Icons.system_update_alt_rounded,color: SystemTheme.accentColor.accent,size: 30,),
                        spacing: 4,
                        text: Text("Reinstall system app",style: TextStyle(
                            color: SystemTheme.accentColor.accent,
                            fontSize: 15
                        ),),
                        onPressed: () async{
                          await showDialog(
                            context: context,
                            builder: (context)=>ReinstallSystemAppDialog(adbService: adbService,),
                          );
                          setState(() {});
                        },
                      ),
                      DropdownButton(
                        underline: Container(),
                        value: _appType,
                        borderRadius: BorderRadius.circular(18),
                        dropdownColor: Theme.of(context).brightness==Brightness.light?Colors.white:kDarkModeMenuColor,
                        items: [
                          DropdownMenuItem(
                            value: AppType.user,
                            child: CustomListTile(
                              icon: Icon(FontAwesomeIcons.user,color: SystemTheme.accentColor.accent,),
                              title: isPreIceCreamSandwichAndroid(device.androidAPILevel)?"All apps":"User apps",
                            ),
                          ),
                          DropdownMenuItem(
                            value: AppType.system,
                            child: CustomListTile(
                              icon: Icon(Icons.system_update,color: SystemTheme.accentColor.accent,),
                              title: "System apps",
                            ),
                          ),
                        ],
                        onChanged: isPreIceCreamSandwichAndroid(device.androidAPILevel)?null:(AppType? appType){
                          if(_appType!=appType!){
                            setState(() {
                              _selectedPackageInfo={};
                              _appType=appType;
                            });
                          }
                        },
                      ),
                      PopupMenuButton(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: SystemTheme.accentColor.accent,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        itemBuilder: (context)=>[
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(
                                FontAwesomeIcons.download,
                                color: Theme.of(context).brightness==Brightness.light?SystemTheme.accentColor.accent:null,
                              ),
                              dense:false,
                              title: Text(
                                "Backup APKs",
                                style: TextStyle(
                                  color: Theme.of(context).brightness==Brightness.light?SystemTheme.accentColor.accent:null,
                                ),
                              ),
                            ),
                            onTap: (){
                              Future.delayed(const Duration(seconds: 0),(){
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context)=>APKBackupDialog(adbService: adbService,),
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Card(
                  child: FutureBuilder(
                    future: adbService.getAppPackageInfo(_appType),
                    builder: (BuildContext context, AsyncSnapshot<List<Map<String,dynamic>>> snapshot) {
                      if(!snapshot.hasData){
                        return const ShimmerAppsList();
                      }
                      return ListView.builder(
                        controller: _appsListScrollController,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context,index){
                          if(snapshot.data![index]['packageName']!="" && !snapshot.data![index]['packageName']!.contains(_searchbarController.text)){
                            return Container();
                          }
                          return ListTile(
                            leading: const Icon(Icons.android,color: Colors.green,),
                            title: Text(snapshot.data![index]['packageName']!),
                            onTap: (){
                              setState(() {
                                _selectedPackageInfo=snapshot.data![index];
                              });
                            },
                          );
                        },
                      );
                    }
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: Theme.of(context).brightness==Brightness.dark?Colors.white.withOpacity(0.05):null,
                  child: PackageInfo(device: device,packageInfo: _selectedPackageInfo,adbService: adbService,onUninstallComplete: (){setState(() {_selectedPackageInfo={};});},))),
            ],
          ),
        ),
      ],
    );
  }
}

class ShimmerAppsList extends StatelessWidget {
  const ShimmerAppsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness==Brightness.light?const Color(0xFFE0E0E0):Colors.black12,
      highlightColor: Theme.of(context).brightness==Brightness.light?const Color(0xFFF5F5F5):Colors.blueGrey,
      child: ListView.builder(
          itemBuilder: (context,index){
            return ListTile(
              leading: Container(
                height: 25,
                width: 25,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black
                ),
              ),
              title: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.black,
                ),
              ),
            );
          },
      ),
    );
  }
}

