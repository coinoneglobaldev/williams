// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  int errorCode;
  List<Datum> data;
  String message;

  LoginModel({
    required this.errorCode,
    required this.data,
    required this.message,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    errorCode: json["ErrorCode"],
    data: List<Datum>.from(json["Data"].map((x) => Datum.fromJson(x))),
    message: json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "ErrorCode": errorCode,
    "Data": List<dynamic>.from(data.map((x) => x.toJson())),
    "Message": message,
  };
}

class Datum {
  String id;
  String userName;
  String grpid;
  String usrImage;
  String cmpId;
  String brid;
  String faid;
  String appPageName;
  String staffId;
  String isAdmin;
  String desgId;
  String userType;
  String isValiMacAdd;

  Datum({
    required this.id,
    required this.userName,
    required this.grpid,
    required this.usrImage,
    required this.cmpId,
    required this.brid,
    required this.faid,
    required this.appPageName,
    required this.staffId,
    required this.isAdmin,
    required this.desgId,
    required this.userType,
    required this.isValiMacAdd,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["ID"],
    userName: json["UserName"],
    grpid: json["GRPID"],
    usrImage: json["UsrImage"],
    cmpId: json["CmpId"],
    brid: json["BRID"],
    faid: json["FAID"],
    appPageName: json["AppPageName"],
    staffId: json["StaffId"],
    isAdmin: json["IsAdmin"],
    desgId: json["DesgId"],
    userType: json["UserType"],
    isValiMacAdd: json["IsValiMacAdd"],
  );

  Map<String, dynamic> toJson() => {
    "ID": id,
    "UserName": userName,
    "GRPID": grpid,
    "UsrImage": usrImage,
    "CmpId": cmpId,
    "BRID": brid,
    "FAID": faid,
    "AppPageName": appPageName,
    "StaffId": staffId,
    "IsAdmin": isAdmin,
    "DesgId": desgId,
    "UserType": userType,
    "IsValiMacAdd": isValiMacAdd,
  };
}
