List<String> getTrimmedStringList(List<String> inputStrings){
  for(int i=0;i<inputStrings.length;i++){
    inputStrings[i]=inputStrings[i].trim();
  }
  return inputStrings;
}