import 'package:adb_gui/utils/enums.dart';

class FileTransferJob {
  FileTransferType jobType;
  String itemPath, itemName;
  FileTransferJob(this.jobType, this.itemPath, this.itemName);

  bool checkSameItem(FileTransferJob fileTransferJob) {
    return itemPath == fileTransferJob.itemPath &&
        itemName == fileTransferJob.itemName;
  }
}

