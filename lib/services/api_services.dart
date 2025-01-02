import 'dart:convert';
import '../constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/category_list_model.dart';
import '../models/customer_list_model.dart';
import '../models/item_list_model.dart';
import '../models/login_model.dart';
import '../models/packing_type_list_model.dart';
import '../models/sales_order_item_list_model.dart';
import '../models/sales_order_list_model.dart';
import '../models/supplier_list_model.dart';
import '../models/uom_list_model.dart';

class ApiServices {
  Future<LoginModel> getUserLogIn({
    required String prmUsername,
    required String prmPassword,
    required String prmMacAddress,
    required String prmLat,
    required String prmLong,
    required String prmAppType,
    required String prmIpAddress,
  }) async {
    try {
      var url = '$loginUrl?PrmUserName=$prmUsername&PrmPassword=$prmPassword&'
          'PrmMacAddress=$prmMacAddress&PrmIpAddress=$prmIpAddress&'
          'PrmLat=$prmLat&PrmLong=$prmLong&'
          'PrmAppType=$prmAppType';
      if (kDebugMode) {
        print(url);
      }
      var response = await http.get(Uri.parse(url)).timeout(
          const Duration(
            seconds: 15,
          ), onTimeout: () {
        throw 'timeout';
      });
      if (kDebugMode) {
        print('getUserLogIn called & response: ${response.body}');
      }
      Map<String, dynamic> mapData = json.decode(response.body);
      if (kDebugMode) {
        print("mapData: $mapData");
      }
      return LoginModel.fromJson(mapData);
    } catch (e) {
      throw Exception("Error during getUserLogIn request");
    }
  }

  Future<List<CategoryListModel>> getCategoryList({
    required String prmCompanyId,
  }) async {
    String uri = "$getCategoryListUrl?PrmCompanyId=$prmCompanyId";
    if (kDebugMode) {
      print(uri);
    }
    try {
      final response = await http.get(Uri.parse(uri)).timeout(
          const Duration(
            seconds: 15,
          ), onTimeout: () {
        throw 'timeout';
      });
      if (kDebugMode) {
        print("Response: ${response.body}");
      }
      final List<dynamic> responseList = json.decode(response.body);
      if (kDebugMode) {
        print(responseList);
      }
      return responseList
          .map((json) => CategoryListModel.fromJson(json))
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in getCategoryList: $error');
      }
      rethrow;
    }
  }

  Future<List<SupplierListModel>> getSupplierList(
      {required String prmCompanyId}) async {
    String uri = "$getSupplierListUrl?PrmCompanyId=$prmCompanyId";
    if (kDebugMode) {
      print(uri);
    }
    try {
      final response = await http.get(Uri.parse(uri)).timeout(
          const Duration(
            seconds: 15,
          ), onTimeout: () {
        throw 'timeout';
      });
      if (kDebugMode) {
        print("Response: ${response.body}");
      }
      final List<dynamic> responseList = json.decode(response.body);
      if (kDebugMode) {
        print(responseList);
      }
      return responseList
          .map((json) => SupplierListModel.fromJson(json))
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in getSupplierList: $error');
      }
      rethrow;
    }
  }

  Future<List<CustomerListModel>> getCustomerList() async {
    String uri = getCustomerListUrl;
    if (kDebugMode) {
      print(uri);
    }
    try {
      final response = await http.get(Uri.parse(uri)).timeout(
          const Duration(
            seconds: 15,
          ), onTimeout: () {
        throw 'timeout';
      });
      if (kDebugMode) {
        print("Response: ${response.body}");
      }
      final List<dynamic> responseList = json.decode(response.body);
      if (kDebugMode) {
        print(responseList);
      }
      return responseList
          .map((json) => CustomerListModel.fromJson(json))
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in getCustomerList: $error');
      }
      rethrow;
    }
  }

  Future<List<ItemListModel>> getItemList() async {
    String uri = getItemListUrl;
    if (kDebugMode) {
      print(uri);
    }
    try {
      final response = await http.get(Uri.parse(uri)).timeout(
          const Duration(
            seconds: 15,
          ), onTimeout: () {
        throw 'timeout';
      });
      if (kDebugMode) {
        print("Response: ${response.body}");
      }
      final List<dynamic> responseList = json.decode(response.body);
      if (kDebugMode) {
        print(responseList);
      }
      return responseList.map((json) => ItemListModel.fromJson(json)).toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in getItemList: $error');
      }
      rethrow;
    }
  }

  Future<List<PackingTypeListModel>> getPackingTypeList(
      {required String prmCompanyId}) async {
    String uri = "$getPackingTypeListUrl?PrmCompanyId=$prmCompanyId";
    if (kDebugMode) {
      print(uri);
    }
    try {
      final response = await http.get(Uri.parse(uri)).timeout(
          const Duration(
            seconds: 15,
          ), onTimeout: () {
        throw 'timeout';
      });
      if (kDebugMode) {
        print("Response: ${response.body}");
      }
      final List<dynamic> responseList = json.decode(response.body);
      if (kDebugMode) {
        print(responseList);
      }
      return responseList
          .map((json) => PackingTypeListModel.fromJson(json))
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in getPackingTypeList: $error');
      }
      rethrow;
    }
  }

  Future<List<UomListModel>> getUomList({required String prmCompanyId}) async {
    String uri = "$getUomListUrl?PrmCompanyId=$prmCompanyId";
    if (kDebugMode) {
      print(uri);
    }
    try {
      final response = await http.get(Uri.parse(uri)).timeout(
          const Duration(
            seconds: 15,
          ), onTimeout: () {
        throw 'timeout';
      });
      if (kDebugMode) {
        print("Response: ${response.body}");
      }
      final List<dynamic> responseList = json.decode(response.body);
      if (kDebugMode) {
        print(responseList);
      }
      return responseList.map((json) => UomListModel.fromJson(json)).toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in getUomList: $error');
      }
      rethrow;
    }
  }

  Future<List<SalesOrderListModel>> getSalesOrderList({
    required String prmFrmDate,
    required String prmToDate,
    required String prmRound,
    required String prmCmpId,
    required String prmBrId,
    required String prmFaId,
    required String prmUId,
  }) async {
    String uri = "$getSalesOrderListUrl?PrmFrmDate=$prmFrmDate&"
        "PrmToDate=$prmToDate&PrmRound=$prmRound&PrmCmpId=$prmCmpId&"
        "PrmBrId=$prmBrId&PrmFaId=$prmFaId&PrmUId=$prmUId";
    if (kDebugMode) {
      print(uri);
    }
    try {
      final response = await http.get(Uri.parse(uri)).timeout(
          const Duration(
            seconds: 15,
          ), onTimeout: () {
        throw 'timeout';
      });
      if (kDebugMode) {
        print("Response: ${response.body}");
      }
      final List<dynamic> responseList = json.decode(response.body);
      if (response.body.isEmpty) {
        throw ('No Sales Order found');
      }
      if (kDebugMode) {
        print(responseList);
      }
      return responseList
          .map((json) => SalesOrderListModel.fromJson(json))
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in getSalesOrderList: $error');
      }
      rethrow;
    }
  }

  Future<List<SalesOrderItemListModel>> getSalesOrderItemList({
    required String prmOrderId,
    required String prmCmpId,
    required String prmBrId,
    required String prmFaId,
    required String prmUId,
  }) async {
    String uri =
        "$getSalesOrderItemListUrl?PrmOrderId=$prmOrderId&PrmCmpId=$prmCmpId&"
        "PrmBrId=$prmBrId&PrmFaId=$prmFaId&PrmUId=$prmUId";
    if (kDebugMode) {
      print(uri);
    }
    try {
      final response = await http.get(Uri.parse(uri)).timeout(
          const Duration(
            seconds: 15,
          ), onTimeout: () {
        throw 'timeout';
      });
      if (kDebugMode) {
        print("Response: ${response.body}");
      }
      final List<dynamic> responseList = json.decode(response.body);
      if (kDebugMode) {
        print(responseList);
      }
      return responseList
          .map((json) => SalesOrderItemListModel.fromJson(json))
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in getSalesOrderItemList: $error');
      }
      rethrow;
    }
  }

  Future<List<UomListModel>> getPackingType(
      {required String prmCompanyId}) async {
    String uri = "$getPackingTypeListData?PrmCompanyId=$prmCompanyId";
    if (kDebugMode) {
      print(uri);
    }
    try {
      final response = await http.get(Uri.parse(uri)).timeout(
          const Duration(
            seconds: 15,
          ), onTimeout: () {
        throw 'timeout';
      });
      if (kDebugMode) {
        print("Response: ${response.body}");
      }
      final List<dynamic> responseList = json.decode(response.body);
      if (kDebugMode) {
        print(responseList);
      }
      return responseList.map((json) => UomListModel.fromJson(json)).toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in getPackingType: $error');
      }
      rethrow;
    }
  }

  Future<List<UomListModel>> releaseOrderSave({
    required String prmIsRlz,
    required String prmAutoId,
    required String prmOrderId,
    required String prmShort,
    required String prmCmpId,
    required String prmBrId,
    required String prmFaId,
    required String prmUId,
  }) async {
    String uri =
        "$releaseOrder?PrmIsRlz=$prmIsRlz&PrmAutoId=$prmAutoId&PrmOrderId=$prmOrderId&PrmShort=$prmShort&PrmCmpId=$prmCmpId&"
        "PrmBrId=$prmBrId&PrmFaId=$prmFaId&PrmUId=$prmUId&PrmFaId=$prmFaId&PrmUId=$prmUId";
    if (kDebugMode) {
      print(uri);
    }
    try {
      final response = await http.get(Uri.parse(uri)).timeout(
          const Duration(
            seconds: 15,
          ), onTimeout: () {
        throw 'timeout';
      });
      if (kDebugMode) {
        print("Response: ${response.body}");
      }
      final List<dynamic> responseList = json.decode(response.body);
      if (kDebugMode) {
        print(responseList);
      }
      return responseList.map((json) => UomListModel.fromJson(json)).toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in getPackingType: $error');
      }
      rethrow;
    }
  }
}
