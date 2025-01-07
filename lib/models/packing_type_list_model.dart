// To parse this JSON data, do
//
//     final packingTypeListModel = packingTypeListModelFromJson(jsonString);

import 'dart:convert';

List<PackingTypeListModel> packingTypeListModelFromJson(String str) =>
    List<PackingTypeListModel>.from(
        json.decode(str).map((x) => PackingTypeListModel.fromJson(x)));

String packingTypeListModelToJson(List<PackingTypeListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PackingTypeListModel {
  String id;
  String name;
  String code;

  PackingTypeListModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory PackingTypeListModel.fromJson(Map<String, dynamic> json) =>
      PackingTypeListModel(
        id: json["Id"],
        name: json["Name"],
        code: json["Code"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "Code": code,
      };
}
