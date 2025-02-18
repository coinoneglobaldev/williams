// To parse this JSON data, do
//
//     final dailyDropListModel = dailyDropListModelFromJson(jsonString);

import 'dart:convert';

List<DailyDropListModel> dailyDropListModelFromJson(String str) =>
    List<DailyDropListModel>.from(
        json.decode(str).map((x) => DailyDropListModel.fromJson(x)));

String dailyDropListModelToJson(List<DailyDropListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DailyDropListModel {
  String autoId;
  String tokenNo;
  String refNo;
  String trDate;
  String poNo;
  String optRefNo;
  String optDate;
  String drId;
  String crId;
  String address;
  String taxTotal;
  String cessTotal;
  String grandTotal;
  String approval;
  String shipment;
  String destination;
  String zipCode;
  String latitude;
  String longitude;
  String accountDr;
  String drCode;
  String accountCr;
  String crCode;
  String regNo;
  String driverId;
  String driverName;
  String itmCnt;
  String roundId;
  String roundName;
  String imageUrl;
  String imageUrl2;
  String imageUrl3;
  String id;
  String tType;
  String remarks;
  String active;
  String isDelete;
  String companyId;
  String branchId;
  String faId;
  String userId;
  String updateDate;
  String days;
  String isHold;
  String isDelivery;
  String deliveryDateTime;
  String isChk;

  DailyDropListModel({
    required this.autoId,
    required this.tokenNo,
    required this.refNo,
    required this.trDate,
    required this.poNo,
    required this.optRefNo,
    required this.optDate,
    required this.drId,
    required this.crId,
    required this.address,
    required this.taxTotal,
    required this.cessTotal,
    required this.grandTotal,
    required this.approval,
    required this.shipment,
    required this.destination,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    required this.accountDr,
    required this.drCode,
    required this.accountCr,
    required this.crCode,
    required this.regNo,
    required this.driverId,
    required this.driverName,
    required this.itmCnt,
    required this.roundId,
    required this.roundName,
    required this.imageUrl,
    required this.imageUrl2,
    required this.imageUrl3,
    required this.id,
    required this.tType,
    required this.remarks,
    required this.active,
    required this.isDelete,
    required this.companyId,
    required this.branchId,
    required this.faId,
    required this.userId,
    required this.updateDate,
    required this.days,
    required this.isHold,
    required this.isDelivery,
    required this.deliveryDateTime,
    required this.isChk,
  });

  factory DailyDropListModel.fromJson(Map<String, dynamic> json) =>
      DailyDropListModel(
        autoId: json["AutoId"],
        tokenNo: json["TokenNo"],
        refNo: json["RefNo"],
        trDate: json["TrDate"],
        poNo: json["PoNo"],
        optRefNo: json["OptRefNo"],
        optDate: json["OptDate"],
        drId: json["DrId"],
        crId: json["CrId"],
        address: json["Address"],
        taxTotal: json["TaxTotal"],
        cessTotal: json["CessTotal"],
        grandTotal: json["GrandTotal"],
        approval: json["Approval"],
        shipment: json["Shipment"],
        destination: json["Destination"],
        zipCode: json["ZipCode"],
        latitude: json["Latitude"],
        longitude: json["Longitude"],
        accountDr: json["AccountDr"],
        drCode: json["DrCode"],
        accountCr: json["AccountCr"],
        crCode: json["CrCode"],
        regNo: json["RegNo"],
        driverId: json["DriverId"],
        driverName: json["DriverName"],
        itmCnt: json["ItmCnt"],
        roundId: json["RoundId"],
        roundName: json["RoundName"],
        imageUrl: json["ImageUrl"],
        imageUrl2: json["ImageUrl2"],
        imageUrl3: json["ImageUrl3"],
        id: json["Id"],
        tType: json["TType"],
        remarks: json["Remarks"],
        active: json["Active"],
        isDelete: json["IsDelete"],
        companyId: json["CompanyId"],
        branchId: json["BranchId"],
        faId: json["FaId"],
        userId: json["UserId"],
        updateDate: json["UpdateDate"],
        days: json["Days"],
        isHold: json["IsHold"],
        isDelivery: json["IsDelivery"],
        deliveryDateTime: json["DeliveryDateTime"],
        isChk: json["IsChk"],
      );

  Map<String, dynamic> toJson() => {
        "AutoId": autoId,
        "TokenNo": tokenNo,
        "RefNo": refNo,
        "TrDate": trDate,
        "PoNo": poNo,
        "OptRefNo": optRefNo,
        "OptDate": optDate,
        "DrId": drId,
        "CrId": crId,
        "Address": address,
        "TaxTotal": taxTotal,
        "CessTotal": cessTotal,
        "GrandTotal": grandTotal,
        "Approval": approval,
        "Shipment": shipment,
        "Destination": destination,
        "ZipCode": zipCode,
        "Latitude": latitude,
        "Longitude": longitude,
        "AccountDr": accountDr,
        "DrCode": drCode,
        "AccountCr": accountCr,
        "CrCode": crCode,
        "RegNo": regNo,
        "DriverId": driverId,
        "DriverName": driverName,
        "ItmCnt": itmCnt,
        "RoundId": roundId,
        "RoundName": roundName,
        "ImageUrl": imageUrl,
        "ImageUrl2": imageUrl2,
        "ImageUrl3": imageUrl3,
        "Id": id,
        "TType": tType,
        "Remarks": remarks,
        "Active": active,
        "IsDelete": isDelete,
        "CompanyId": companyId,
        "BranchId": branchId,
        "FaId": faId,
        "UserId": userId,
        "UpdateDate": updateDate,
        "Days": days,
        "IsHold": isHold,
        "IsDelivery": isDelivery,
        "DeliveryDateTime": deliveryDateTime,
        "IsChk": isChk,
      };
}
