// To parse this JSON data, do
//
//     final supplierListModel = supplierListModelFromJson(jsonString);

import 'dart:convert';

List<SupplierListModel> supplierListModelFromJson(String str) =>
    List<SupplierListModel>.from(
        json.decode(str).map((x) => SupplierListModel.fromJson(x)));

String supplierListModelToJson(List<SupplierListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SupplierListModel {
  String id;
  String name;
  String code;
  String address;
  String mobNo;
  String phoneNo;
  String email;

  SupplierListModel({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.mobNo,
    required this.phoneNo,
    required this.email,
  });

  factory SupplierListModel.fromJson(Map<String, dynamic> json) =>
      SupplierListModel(
        id: json["Id"],
        name: json["Name"],
        code: json["Code"],
        address: json["Address"],
        mobNo: json["MobNo"],
        phoneNo: json["PhoneNo"],
        email: json["Email"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "Code": code,
        "Address": address,
        "MobNo": mobNo,
        "PhoneNo": phoneNo,
        "Email": email,
      };
}
