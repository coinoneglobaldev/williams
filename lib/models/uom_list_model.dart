// To parse this JSON data, do
//
//     final uomListModel = uomListModelFromJson(jsonString);

import 'dart:convert';

List<UomListModel> uomListModelFromJson(String str) => List<UomListModel>.from(json.decode(str).map((x) => UomListModel.fromJson(x)));

String uomListModelToJson(List<UomListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UomListModel {
  String id;
  String name;
  String code;

  UomListModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory UomListModel.fromJson(Map<String, dynamic> json) => UomListModel(
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
