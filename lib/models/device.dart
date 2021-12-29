import 'package:flutter/material.dart';

class Device{
  String id;
  late String model;
  late String manufacturer;
  late String androidVersion;
  late String status;
  late int selectedDeviceIndex;
  late Function updateSelectionStatus;
  late int androidAPILevel;
  late int index;

  Device(this.index,this.id,this.status,this.selectedDeviceIndex,this.updateSelectionStatus);
  Device.wsaCons(this.id);

  void setOtherDeviceAttributes(String model,String manufacturer,String androidVersion,int androidAPILevel){
    this.model=model;
    this.manufacturer=manufacturer;
    this.androidVersion=androidVersion;
    this.androidAPILevel=androidAPILevel;
  }

  DataRow getDeviceInfoAsDataRow(){
    return DataRow(
        cells: [
          DataCell(
              Radio(
                value: index,
                onChanged: (value){
                  updateSelectionStatus(index);
                },
                groupValue: selectedDeviceIndex,
              )
          ),
          DataCell(Text(id,maxLines: 3)),
          DataCell(Text(model,maxLines: 3)),
          DataCell(Text(manufacturer,maxLines: 3)),
          DataCell(Text(androidVersion,maxLines: 3)),
          DataCell(Text(status,maxLines: 3)),
        ]
    );
  }


}