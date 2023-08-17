import 'package:adb_gui/utils/enums.dart';

class Item{
  String itemName;
  Future<FileContentTypes> itemContentType;
  Item(this.itemName,this.itemContentType);
}