bool isPreMarshmallowAndroid(int apiLevel){
  return apiLevel<24;
}

bool isPreIceCreamSandwichAndroid(int apiLevel){
  return apiLevel<15;
}

bool appSuspendSupported(int apiLevel){
  return apiLevel>=29;
}

bool appCompilationSupported(int apiLevel){
  return apiLevel>=29;
}

bool newStoragePathSupported(int apiLevel){
  return apiLevel>=23;
}