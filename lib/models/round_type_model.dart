// To parse this JSON data, do
//
//     final roundTypeModel = roundTypeModelFromJson(jsonString);

import 'dart:convert';

List<RoundTypeModel> roundTypeModelFromJson(String str) =>
    List<RoundTypeModel>.from(
        json.decode(str).map((x) => RoundTypeModel.fromJson(x)));

String roundTypeModelToJson(List<RoundTypeModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RoundTypeModel {
  String round;

  RoundTypeModel({
    required this.round,
  });

  factory RoundTypeModel.fromJson(Map<String, dynamic> json) => RoundTypeModel(
        round: json["Round"],
      );

  Map<String, dynamic> toJson() => {
        "Round": round,
      };
}
