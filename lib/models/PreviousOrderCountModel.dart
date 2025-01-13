// To parse this JSON data, do
//
//     final previousOrderCountModel = previousOrderCountModelFromJson(jsonString);

import 'dart:convert';

List<PreviousOrderCountModel> previousOrderCountModelFromJson(String str) =>
    List<PreviousOrderCountModel>.from(
        json.decode(str).map((x) => PreviousOrderCountModel.fromJson(x)));

String previousOrderCountModelToJson(List<PreviousOrderCountModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PreviousOrderCountModel {
  String id;
  String name;

  PreviousOrderCountModel({
    required this.id,
    required this.name,
  });

  factory PreviousOrderCountModel.fromJson(Map<String, dynamic> json) =>
      PreviousOrderCountModel(
        id: json["ID"],
        name: json["Name"],
      );

  Map<String, dynamic> toJson() => {
        "ID": id,
        "Name": name,
      };
}
