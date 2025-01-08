// To parse this JSON data, do
//
//     final customerListModel = customerListModelFromJson(jsonString);

import 'dart:convert';

List<CustomerListModel> customerListModelFromJson(String str) =>
    List<CustomerListModel>.from(
        json.decode(str).map((x) => CustomerListModel.fromJson(x)));

String customerListModelToJson(List<CustomerListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustomerListModel {
  String id;
  String name;
  String code;

  CustomerListModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory CustomerListModel.fromJson(Map<String, dynamic> json) =>
      CustomerListModel(
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
