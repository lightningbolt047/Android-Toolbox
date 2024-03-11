import 'date_time_service.dart';

class TransformFunctions{

  String securityPatchTransform(String value){
    DateTime dateTime=DateTime.parse(value);
    String patchLevelInfo = "";
    if (dateTime.day == 1) {
      patchLevelInfo = "Android Framework patch only";
    } else if(dateTime.day == 5) {
      patchLevelInfo = "Android Framework & Vendor/Kernel patches included";
    }
    return "${DateTimeService.getMonthStringFromInt(dateTime.month)} ${dateTime.year} ($patchLevelInfo)";
  }

  String mobileNetworkOperatorsTransform(String value){
    if(!value.contains(",")){
      return value;
    }
    List<String> splitString=value.split(",");
    return "SIM 1: ${splitString[0]}    SIM 2: ${splitString[1]}";
  }

  String boolStringTransform(String value){
    if(value.isEmpty){
      return "Unknown";
    }
    return value=="true"?"Supported":"Not Supported";
  }

  String addCommaSeparation(String value){
    return value.replaceAll(",", ", ");
  }

}