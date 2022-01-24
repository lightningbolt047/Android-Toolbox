List<String> getTrimmedStringList(List<String> inputString){
  for(int i=0;i<inputString.length;i++){
    inputString[i]=inputString[i].trim();
  }
  return inputString;
}