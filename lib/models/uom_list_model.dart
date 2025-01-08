// To parse this JSON data, do
//
//     final uomListModel = uomListModelFromJson(jsonString);

import 'dart:convert';

List<UomAndPackListModel> uomListModelFromJson(String str) =>
    List<UomAndPackListModel>.from(
        json.decode(str).map((x) => UomAndPackListModel.fromJson(x)));

String uomListModelToJson(List<UomAndPackListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UomAndPackListModel {
  String id;
  String name;
  String code;

  UomAndPackListModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory UomAndPackListModel.fromJson(Map<String, dynamic> json) =>
      UomAndPackListModel(
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
