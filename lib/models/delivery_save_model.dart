// To parse this JSON data, do
//
//     final deliverySaveModel = deliverySaveModelFromJson(jsonString);

import 'dart:convert';

CommonResponseModel deliverySaveModelFromJson(String str) =>
    CommonResponseModel.fromJson(json.decode(str));

String deliverySaveModelToJson(CommonResponseModel data) =>
    json.encode(data.toJson());

class CommonResponseModel {
  int errorCode;
  String data;
  String message;

  CommonResponseModel({
    required this.errorCode,
    required this.data,
    required this.message,
  });

  factory CommonResponseModel.fromJson(Map<String, dynamic> json) =>
      CommonResponseModel(
        errorCode: json["ErrorCode"],
        data: json["Data"],
        message: json["Message"],
      );

  Map<String, dynamic> toJson() => {
        "ErrorCode": errorCode,
        "Data": data,
        "Message": message,
      };
}
