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