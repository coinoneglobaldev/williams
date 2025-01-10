// To parse this JSON data, do
//
//     final itemListModel = itemListModelFromJson(jsonString);

import 'dart:convert';

List<ItemListModel> itemListModelFromJson(String str) =>
    List<ItemListModel>.from(
        json.decode(str).map((x) => ItemListModel.fromJson(x)));

String itemListModelToJson(List<ItemListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ItemListModel {
  String id;
  String name;
  String code;
  String itemGroup;
  String bulkRate;
  String splitRate;
  String uom;
  String conVal;
  String groupId;
  String taxId;
  String eStockQty;
  String rate;

  @override
  String toString() {
    return code;
  }

  ItemListModel({
    required this.id,
    required this.name,
    required this.code,
    required this.itemGroup,
    required this.bulkRate,
    required this.splitRate,
    required this.uom,
    required this.conVal,
    required this.groupId,
    required this.taxId,
    required this.eStockQty,
    required this.rate,
  });

  factory ItemListModel.fromJson(Map<String, dynamic> json) => ItemListModel(
        id: json["Id"],
        name: json["Name"],
        code: json["Code"],
        itemGroup: json["ItemGroup"]!,
        bulkRate: json["BulkRate"],
        splitRate: json["SplitRate"],
        uom: json["Uom"],
        conVal: json["ConVal"],
        groupId: json["GroupId"],
        taxId: json["TaxId"],
        eStockQty: json["EStockQty"],
        rate: json["Rate"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "Code": code,
        "ItemGroup": itemGroup,
        "BulkRate": bulkRate,
        "SplitRate": splitRate,
        "Uom": uom,
        "ConVal": conVal,
        "GroupId": groupId,
        "TaxId": taxId,
        "EStockQty": eStockQty,
        "Rate": rate,
      };
}
