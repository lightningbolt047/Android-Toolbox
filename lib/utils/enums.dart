enum Screens{
  fileManager,
  packageManager,
  powerControls,
  other
}

enum FileItemType{
  file,
  directory
}

enum FileContentTypes{
  file,
  directory,
  pdf,
  wordDocument,
  powerpoint,
  excel,
  image,
  audio,
  video,
  archive,
  apk,
  torrent,
  securityCertificate,
}

enum FileTransferType{
  move,
  copy,
  pcToPhone,
  phoneToPC
}

enum AppType{
  system,
  user
}

enum AppInstallType{
  single,
  multiApks,
  batch,
}

enum ProcessStatus{
  notStarted,
  working,
  success,
  fail,
}

enum AppInstaller{
  googlePlayStore,
  custom
}

enum CompilationMode{
  quicken,
  space,
  spaceProfile,
  speed,
  speedProfile,
  everything,
}