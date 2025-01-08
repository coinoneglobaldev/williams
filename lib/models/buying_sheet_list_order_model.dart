// To parse this JSON data, do
//
//     final buyingSheetListModel = buyingSheetListModelFromJson(jsonString);

import 'dart:convert';

List<BuyingSheetListModel> buyingSheetListModelFromJson(String str) =>
    List<BuyingSheetListModel>.from(
        json.decode(str).map((x) => BuyingSheetListModel.fromJson(x)));

String buyingSheetListModelToJson(List<BuyingSheetListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BuyingSheetListModel {
  bool isSelected;
  String itemId;
  String itemName;
  String itemCode;
  String uom;
  String itemGroup;
  String boxQty;
  String eachQty;
  String odrBQty;
  String odrEQty;
  String boxUomId;
  String uomConVal;
  String itmCnt;

  BuyingSheetListModel({
    this.isSelected = false,
    required this.itemId,
    required this.itemName,
    required this.itemCode,
    required this.uom,
    required this.itemGroup,
    required this.boxQty,
    required this.eachQty,
    required this.odrBQty,
    required this.odrEQty,
    required this.boxUomId,
    required this.uomConVal,
    required this.itmCnt,
  });

  factory BuyingSheetListModel.fromJson(Map<String, dynamic> json) =>
      BuyingSheetListModel(
        itemId: json["ItemId"],
        itemName: json["ItemName"],
        itemCode: json["ItemCode"],
        uom: json["Uom"],
        itemGroup: json["ItemGroup"],
        boxQty: json["BoxQty"],
        eachQty: json["EachQty"],
        odrBQty: json["OdrBQty"],
        odrEQty: json["OdrEQty"],
        boxUomId: json["BoxUomId"],
        uomConVal: json["UomConVal"],
        itmCnt: json["ItmCnt"],
      );

  Map<String, dynamic> toJson() => {
        "IsSelected": isSelected,
        "ItemId": itemId,
        "ItemName": itemName,
        "ItemCode": itemCode,
        "Uom": uom,
        "ItemGroup": itemGroup,
        "BoxQty": boxQty,
        "EachQty": eachQty,
        "OdrBQty": odrBQty,
        "OdrEQty": odrEQty,
        "BoxUomId": boxUomId,
        "UomConVal": uomConVal,
        "ItmCnt": itmCnt,
      };
}
