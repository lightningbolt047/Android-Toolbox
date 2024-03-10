import 'package:adb_gui/components/device_info_list_tile.dart';
import 'package:adb_gui/components/page_subheading.dart';
import 'package:adb_gui/services/adb_services.dart';
import 'package:adb_gui/services/transform_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/device.dart';

class DeviceInfoScreen extends StatefulWidget {
  final Device device;
  const DeviceInfoScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState(device);
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {

  final Device device;
  late final ADBService _adbService;
  late final TransformFunctions _transformFunctions;

  _DeviceInfoScreenState(this.device);


  @override
  void initState() {
    _adbService=ADBService(device: device);
    _transformFunctions=TransformFunctions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StaggeredGrid.count(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: [
          Card(
            color: Theme.of(context).brightness==Brightness.dark?Colors.white.withOpacity(0.05):null,
            child: Column(
              children: [
                const PageSubheading(subheadingName: "Android System"),
                DeviceInfoListTile(
                  propertyDisplayName: "Android Version",
                  propertyName: "ro.system.build.version.release",
                  adbService: _adbService,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Android API Level",
                  propertyName: "ro.system.build.version.sdk",
                  adbService: _adbService,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Launch API Level",
                  propertyName: "ro.product.first_api_level",
                  adbService: _adbService,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "System Build Fingerprint",
                  propertyName: "ro.system.build.fingerprint",
                  adbService: _adbService,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Vendor Build Fingerprint",
                  propertyName: "ro.vendor.build.fingerprint",
                  adbService: _adbService,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Android Security Patch",
                  propertyName: "ro.build.version.security_patch",
                  adbService: _adbService,
                  transformFunction: _transformFunctions.securityPatchTransform,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Vendor Security Patch Level",
                  propertyName: "ro.vendor.build.security_patch",
                  adbService: _adbService,
                  transformFunction: _transformFunctions.securityPatchTransform,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Build Date",
                  propertyName: "ro.system.build.date",
                  adbService: _adbService,
                ),
              ],
            ),
          ),
          Card(
            color: Theme.of(context).brightness==Brightness.dark?Colors.white.withOpacity(0.05):null,
            child: Column(
              children: [
                const PageSubheading(subheadingName: "Hardware"),
                DeviceInfoListTile(
                  propertyDisplayName: "Board",
                  propertyName: "ro.product.board",
                  adbService: _adbService,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Device Model",
                  propertyName: "ro.product.model",
                  adbService: _adbService,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Supported CPU ABIs",
                  propertyName: "ro.product.cpu.abilist",
                  adbService: _adbService,
                  transformFunction: _transformFunctions.addCommaSeparation,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Vulkan Device",
                  propertyName: "ro.hardware.vulkan",
                  adbService: _adbService,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Serial No.",
                  propertyName: "ro.boot.serialno",
                  adbService: _adbService,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Screen HDR support",
                  propertyName: "ro.surface_flinger.has_HDR_display",
                  adbService: _adbService,
                  transformFunction: _transformFunctions.boolStringTransform,
                ),
              ],
            ),
          ),
          Card(
            color: Theme.of(context).brightness==Brightness.dark?Colors.white.withOpacity(0.05):null,
            child: Column(
              children: [
                const PageSubheading(subheadingName: "Network Status"),
                DeviceInfoListTile(
                  propertyDisplayName: "WiFi Interface",
                  propertyName: "wifi.interface",
                  adbService: _adbService,
                  transformFunction: _transformFunctions.addCommaSeparation,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Network Type",
                  propertyName: "gsm.network.type",
                  adbService: _adbService,
                  transformFunction: _transformFunctions.mobileNetworkOperatorsTransform,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Connected Mobile Networks",
                  propertyName: "gsm.operator.alpha",
                  adbService: _adbService,
                  transformFunction: _transformFunctions.mobileNetworkOperatorsTransform,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Connected Mobile Network Country",
                  propertyName: "gsm.operator.iso-country",
                  adbService: _adbService,
                  transformFunction: _transformFunctions.mobileNetworkOperatorsTransform,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "SIM Operator",
                  propertyName: "gsm.sim.operator.alpha",
                  adbService: _adbService,
                  transformFunction: _transformFunctions.mobileNetworkOperatorsTransform,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "SIM Operator Country",
                  propertyName: "gsm.sim.operator.iso-country",
                  adbService: _adbService,
                  transformFunction: _transformFunctions.mobileNetworkOperatorsTransform,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "SIM Operator numeric code",
                  propertyName: "gsm.sim.operator.numeric",
                  adbService: _adbService,
                  transformFunction: _transformFunctions.mobileNetworkOperatorsTransform,
                ),
                DeviceInfoListTile(
                  propertyDisplayName: "Baseband Version",
                  propertyName: "gsm.version.baseband",
                  adbService: _adbService,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
