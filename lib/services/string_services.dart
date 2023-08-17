import 'package:adb_gui/utils/enums.dart';

List<String> getTrimmedStringList(List<String> inputString){
  for(int i=0;i<inputString.length;i++){
    inputString[i]=inputString[i].trim();
  }
  return inputString;
}

String getStringFromStringList(List<String> inputString){
  String outputString = "";
  for(int i=0;i<inputString.length;i++){
    outputString+=inputString[i]+"\n";
  }
  return outputString;
}

String getCompilationModeAsString(CompilationMode compilationMode){
  switch(compilationMode){
    case CompilationMode.quicken: return "quicken";
    case CompilationMode.everything: return "everything";
    case CompilationMode.spaceProfile: return "space-profile";
    case CompilationMode.speed: return "speed";
    case CompilationMode.speedProfile: return "speed-profile";
    default: return "space";
  }
}

String getFileSizeWithUnits(double size){
  List<String> units=["B","KB","MB","GB","TB","PB"];
  int selectedUnitIndex=0;
  while(size > 1023 && selectedUnitIndex < units.length){
    size/=1024;
    selectedUnitIndex++;
  }
  return "${size.toStringAsFixed(2)} ${units[selectedUnitIndex]}";
}