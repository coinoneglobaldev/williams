// To parse this JSON data, do
//
//     final poDetailsModel = poDetailsModelFromJson(jsonString);

import 'dart:convert';

List<PoDetailsModel> poDetailsModelFromJson(String str) =>
    List<PoDetailsModel>.from(
        json.decode(str).map((x) => PoDetailsModel.fromJson(x)));

String poDetailsModelToJson(List<PoDetailsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PoDetailsModel {
  bool isSelected;
  String totalQty;
  String autoId;
  String id;
  String tokenNo;
  String invoiceId;
  String refNo;
  String trDate;
  String drId;
  String crId;
  String drDesc;
  String accountDr;
  String drCode;
  String accountCr;
  String crCode;
  String crDesc;
  String crGroupId;
  String drGroupId;
  String crAccGroup;
  String drAccGroup;
  String batchNo;
  String itemId;
  String itemName;
  String itemCode;
  String itemGroupId;
  String itemGroup;
  String packId;
  String packName;
  String gradeId;
  String gradeName;
  String uomId;
  String uomName;
  String printUom;
  String qty;
  String rate;
  String amount;
  String taxId;
  String taxName;
  String isBefore;
  String taxValue;
  String cessId;
  String cessName;
  String cessValue;
  String isTaxInclusive;
  String discount;
  String isPercentage;
  String totalAmt;
  String taxAccId;
  String taxAccName;
  String cessAccId;
  String cessAccName;
  String addCharges;
  String addChargeId;
  String remarks;
  String active;
  String companyId;
  String branchId;
  String faId;
  String commission;
  String comm;
  String slQty;
  String puQty;
  String numberofPacks;
  String price;
  String shopId;
  String shopName;
  String mrp;
  String userId;
  String updateDate;
  String tType;
  String prvQty;
  String balQty;
  String sellingPrc;
  String conVal;
  String country;
  String margin;
  String boxUomId;
  String uomSplitId;
  String itmGrpId;
  String itmGroup;
  String prvBoxQty;
  String specVal;
  String counrtry;
  String addPer;
  String puRate;
  String puTotal;
  String currencyId;
  String umoId;
  String optRefNo;
  String optDate;

  PoDetailsModel(
      {this.isSelected = true,
      this.totalQty = '0',
      required this.autoId,
      required this.id,
      required this.tokenNo,
      required this.invoiceId,
      required this.refNo,
      required this.trDate,
      required this.drId,
      required this.crId,
      required this.drDesc,
      required this.accountDr,
      required this.drCode,
      required this.accountCr,
      required this.crCode,
      required this.crDesc,
      required this.crGroupId,
      required this.drGroupId,
      required this.crAccGroup,
      required this.drAccGroup,
      required this.batchNo,
      required this.itemId,
      required this.itemName,
      required this.itemCode,
      required this.itemGroupId,
      required this.itemGroup,
      required this.packId,
      required this.packName,
      required this.gradeId,
      required this.gradeName,
      required this.uomId,
      required this.uomName,
      required this.printUom,
      required this.qty,
      required this.rate,
      required this.amount,
      required this.taxId,
      required this.taxName,
      required this.isBefore,
      required this.taxValue,
      required this.cessId,
      required this.cessName,
      required this.cessValue,
      required this.isTaxInclusive,
      required this.discount,
      required this.isPercentage,
      required this.totalAmt,
      required this.taxAccId,
      required this.taxAccName,
      required this.cessAccId,
      required this.cessAccName,
      required this.addCharges,
      required this.addChargeId,
      required this.remarks,
      required this.active,
      required this.companyId,
      required this.branchId,
      required this.faId,
      required this.commission,
      required this.comm,
      required this.slQty,
      required this.puQty,
      required this.numberofPacks,
      required this.price,
      required this.shopId,
      required this.shopName,
      required this.mrp,
      required this.userId,
      required this.updateDate,
      required this.tType,
      required this.prvQty,
      required this.balQty,
      required this.sellingPrc,
      required this.conVal,
      required this.country,
      required this.margin,
      required this.boxUomId,
      required this.uomSplitId,
      required this.itmGrpId,
      required this.itmGroup,
      required this.prvBoxQty,
      required this.specVal,
      required this.counrtry,
      required this.addPer,
      required this.puRate,
      required this.puTotal,
      this.umoId = '0',
      required this.currencyId,
      required this.optRefNo,
      required this.optDate});

  factory PoDetailsModel.fromJson(Map<String, dynamic> json) => PoDetailsModel(
        autoId: json["AutoId"],
        id: json["ID"],
        tokenNo: json["TokenNo"],
        invoiceId: json["InvoiceId"],
        refNo: json["RefNo"],
        trDate: json["TrDate"],
        drId: json["DrId"],
        crId: json["CrId"],
        drDesc: json["DrDesc"],
        accountDr: json["AccountDr"],
        drCode: json["DrCode"],
        accountCr: json["AccountCr"],
        crCode: json["CrCode"],
        crDesc: json["CrDesc"],
        crGroupId: json["CrGroupId"],
        drGroupId: json["DrGroupId"],
        crAccGroup: json["CrAccGroup"],
        drAccGroup: json["DrAccGroup"],
        batchNo: json["BatchNo"],
        itemId: json["ItemId"],
        itemName: json["ItemName"],
        itemCode: json["ItemCode"],
        itemGroupId: json["ItemGroupId"],
        itemGroup: json["ItemGroup"],
        packId: json["PackId"],
        packName: json["PackName"],
        gradeId: json["GradeId"],
        gradeName: json["GradeName"],
        uomId: json["UomId"],
        uomName: json["UomName"],
        printUom: json["PrintUom"],
        qty: json["Qty"],
        rate: json["Rate"],
        amount: json["Amount"],
        taxId: json["TaxId"],
        taxName: json["TaxName"],
        isBefore: json["IsBefore"],
        taxValue: json["TaxValue"],
        cessId: json["CessId"],
        cessName: json["CessName"],
        cessValue: json["CessValue"],
        isTaxInclusive: json["IsTaxInclusive"],
        discount: json["Discount"],
        isPercentage: json["IsPercentage"],
        totalAmt: json["TotalAmt"],
        taxAccId: json["TaxAccId"],
        taxAccName: json["TaxAccName"],
        cessAccId: json["CessAccId"],
        cessAccName: json["CessAccName"],
        addCharges: json["AddCharges"],
        addChargeId: json["AddChargeId"],
        remarks: json["Remarks"],
        active: json["Active"],
        companyId: json["CompanyId"],
        branchId: json["BranchId"],
        faId: json["FaId"],
        commission: json["Commission"],
        comm: json["Comm"],
        slQty: json["SlQty"],
        puQty: json["PuQty"],
        numberofPacks: json["NumberofPacks"],
        price: json["Price"],
        shopId: json["ShopId"],
        shopName: json["ShopName"],
        mrp: json["MRP"],
        userId: json["UserId"],
        updateDate: json["UpdateDate"],
        tType: json["TType"],
        prvQty: json["PrvQty"],
        balQty: json["BalQty"],
        sellingPrc: json["SellingPrc"],
        conVal: json["ConVal"],
        country: json["Country"],
        margin: json["Margin"],
        boxUomId: json["BoxUomId"],
        uomSplitId: json["UomSplitId"],
        itmGrpId: json["ItmGrpId"],
        itmGroup: json["ItmGroup"],
        prvBoxQty: json["PrvBoxQty"],
        specVal: json["SpecVal"],
        counrtry: json["Counrtry"],
        addPer: json["AddPer"],
        puRate: json["PuRate"],
        puTotal: json["PuTotal"],
        currencyId: json["CurrencyId"],
        optRefNo: json["OptRefNo"],
        optDate: json["OptDate"],
      );

  Map<String, dynamic> toJson() => {
        "AutoId": autoId,
        "ID": id,
        "TokenNo": tokenNo,
        "InvoiceId": invoiceId,
        "RefNo": refNo,
        "TrDate": trDate,
        "DrId": drId,
        "CrId": crId,
        "DrDesc": drDesc,
        "AccountDr": accountDr,
        "DrCode": drCode,
        "AccountCr": accountCr,
        "CrCode": crCode,
        "CrDesc": crDesc,
        "CrGroupId": crGroupId,
        "DrGroupId": drGroupId,
        "CrAccGroup": crAccGroup,
        "DrAccGroup": drAccGroup,
        "BatchNo": batchNo,
        "ItemId": itemId,
        "ItemName": itemName,
        "ItemCode": itemCode,
        "ItemGroupId": itemGroupId,
        "ItemGroup": itemGroup,
        "PackId": packId,
        "PackName": packName,
        "GradeId": gradeId,
        "GradeName": gradeName,
        "UomId": uomId,
        "UomName": uomName,
        "PrintUom": printUom,
        "Qty": qty,
        "Rate": rate,
        "Amount": amount,
        "TaxId": taxId,
        "TaxName": taxName,
        "IsBefore": isBefore,
        "TaxValue": taxValue,
        "CessId": cessId,
        "CessName": cessName,
        "CessValue": cessValue,
        "IsTaxInclusive": isTaxInclusive,
        "Discount": discount,
        "IsPercentage": isPercentage,
        "TotalAmt": totalAmt,
        "TaxAccId": taxAccId,
        "TaxAccName": taxAccName,
        "CessAccId": cessAccId,
        "CessAccName": cessAccName,
        "AddCharges": addCharges,
        "AddChargeId": addChargeId,
        "Remarks": remarks,
        "Active": active,
        "CompanyId": companyId,
        "BranchId": branchId,
        "FaId": faId,
        "Commission": commission,
        "Comm": comm,
        "SlQty": slQty,
        "PuQty": puQty,
        "NumberofPacks": numberofPacks,
        "Price": price,
        "ShopId": shopId,
        "ShopName": shopName,
        "MRP": mrp,
        "UserId": userId,
        "UpdateDate": updateDate,
        "TType": tType,
        "PrvQty": prvQty,
        "BalQty": balQty,
        "SellingPrc": sellingPrc,
        "ConVal": conVal,
        "Country": country,
        "Margin": margin,
        "BoxUomId": boxUomId,
        "UomSplitId": uomSplitId,
        "ItmGrpId": itmGrpId,
        "ItmGroup": itmGroup,
        "PrvBoxQty": prvBoxQty,
        "SpecVal": specVal,
        "Counrtry": counrtry,
        "AddPer": addPer,
        "PuRate": puRate,
        "PuTotal": puTotal,
        "CurrencyId": currencyId,
        "OptRefNo": optRefNo,
        "OptDate": optDate
      };
}
