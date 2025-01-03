// To parse this JSON data, do
//
//     final buyingSheetListModel = buyingSheetListModelFromJson(jsonString);

import 'dart:convert';

List<BuyingSheetListModel> buyingSheetListModelFromJson(String str) => List<BuyingSheetListModel>.from(json.decode(str).map((x) => BuyingSheetListModel.fromJson(x)));

String buyingSheetListModelToJson(List<BuyingSheetListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BuyingSheetListModel {
  String itemId;
  String itemName;
  String itemCode;
  Uom uom;
  String itemGroup;
  String boxQty;
  String eachQty;
  String odrBQty;
  String odrEQty;
  String boxUomId;
  String uomConVal;
  String itmCnt;

  BuyingSheetListModel({
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

  factory BuyingSheetListModel.fromJson(Map<String, dynamic> json) => BuyingSheetListModel(
    itemId: json["ItemId"],
    itemName: json["ItemName"],
    itemCode: json["ItemCode"],
    uom: uomValues.map[json["Uom"]]!,
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
    "ItemId": itemId,
    "ItemName": itemName,
    "ItemCode": itemCode,
    "Uom": uomValues.reverse[uom],
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

enum Uom {
  BOX,
  KG
}

final uomValues = EnumValues({
  "BOX": Uom.BOX,
  "KG": Uom.KG
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
