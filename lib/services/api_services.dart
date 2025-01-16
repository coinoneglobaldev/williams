import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../constants.dart';
import '../models/PreviousOrderCountModel.dart';
import '../models/buying_sheet_list_order_model.dart';
import '../models/category_list_model.dart';
import '../models/daily_drop_list_model.dart';
import '../models/delivery_save_model.dart';
import '../models/item_list_model.dart';
import '../models/login_model.dart';
import '../models/round_type_model.dart';
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

  Future<List<ItemListModel>> getItemList(
      {required String prmFrmDate,
      required String prmToDate,
      required String prmCmpId,
      required String prmBrId,
      required String prmFaId}) async {
    String uri = "$getItemListUrl?PrmFrmDate=$prmFrmDate&PrmToDate=$prmToDate&"
        "PrmCmpId=$prmCmpId&PrmBrId=$prmBrId&"
        "PrmFaId=$prmFaId";
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

  Future<List<UomAndPackListModel>> getPackingType(
      {required String prmCompanyId}) async {
    String uri = "$getPackingTypeListDataUrl?PrmCompanyId=$prmCompanyId";
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
          .map((json) => UomAndPackListModel.fromJson(json))
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in getPackingType: $error');
      }
      rethrow;
    }
  }

  Future<CommonResponseModel> fnSavePackingItem({
    required String prmAutoID,
    required String orderId,
    required String prmShort,
    required String prmCmpId,
    required String prmBrId,
    required String prmFaId,
    required String prmUID,
    required String prmQty,
    required String prmIsRlz,
  }) async {
    String uri = "$savePackingItemUrl?PrmIsRlz=$prmIsRlz&PrmAutoId=$prmAutoID&"
        "PrmOrderId=$orderId&PrmShort=$prmShort&PrmCmpId=$prmCmpId&"
        "PrmBrId=$prmBrId&PrmFaId=$prmFaId&PrmUId=$prmUID&PrmQty=$prmQty";
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
      Map<String, dynamic> mapData = json.decode(response.body);
      if (kDebugMode) {
        print("mapData: $mapData");
      }
      return CommonResponseModel.fromJson(mapData);
    } catch (error) {
      if (kDebugMode) {
        print('Exception in fnSavePackingItem: $error');
      }
      rethrow;
    }
  }

  //!Eldho
  Future<CommonResponseModel> selectAllSavePackingItem({
    required String prmOrderId,
    required String prmCmpId,
    required String prmBrId,
    required String prmFaId,
    required String prmUId,
    required String isSelectAll,
  }) async {
    String uri =
        "$releaseOrderAllOrderUrl?PrmOrderId=$prmOrderId&PrmCmpId=$prmCmpId&"
        "PrmBrId=$prmBrId&PrmFaId=$prmFaId&PrmUId=$prmUId&PrmIsSelectAll=$isSelectAll";
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
      Map<String, dynamic> mapData = json.decode(response.body);
      if (kDebugMode) {
        print("mapData: $mapData");
      }
      return CommonResponseModel.fromJson(mapData);
    } catch (error) {
      if (kDebugMode) {
        print('Exception in fnSavePackingItem: $error');
      }
      rethrow;
    }
  }

  Future<List<BuyingSheetListModel>> fnGetBuyingSheetList({
    required String prmFrmDate,
    required String prmToDate,
    required String prmItmGrpId,
    required String prmCmpId,
    required String prmBrId,
    required String prmFaId,
    required String prmUId,
    required String prmAccId,
    required String prmPrvOrderCount,
  }) async {
    String uri =
        "$getBuyingSheetListUrl?PrmFrmDate=$prmFrmDate&PrmToDate=$prmToDate&"
        "PrmItmGrpId=$prmItmGrpId&PrmCmpId=$prmCmpId&PrmBrId=$prmBrId&"
        "PrmFaId=$prmFaId&PrmUId=$prmUId&PrmAccId=$prmAccId&"
        "PrmPrvOrderCount=$prmPrvOrderCount";
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
          .map((json) => BuyingSheetListModel.fromJson(json))
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in fnGetBuyingSheetList: $error');
      }
      rethrow;
    }
  }

  Future<String> fnGetTokenNoUrl({
    required String prmCmpId,
    required String prmBrId,
    required String prmFaId,
  }) async {
    String uri = "$getTokenNoUrl?PrmCmpId=$prmCmpId&PrmBrId=$prmBrId&"
        "PrmFaId=$prmFaId";
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

      final Map<String, dynamic> responseMap = json.decode(response.body);
      if (responseMap['ErrorCode'] == 0) {
        final String tokenNo = responseMap['Data'].toString();
        return tokenNo;
      } else {
        throw ('No Token found: ${responseMap['Message']}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Exception in fnGetBuyingSheetList: $error');
      }
      rethrow;
    }
  }

  Future<String> fnSavePoList({
    required String prmTokenNo,
    required String prmDatePrmToCnt,
    required String prmCurntCnt,
    required String PrmToCnt,
    required String prmAccId,
    required String prmItemId,
    required String prmUomId,
    required String prmTaxId,
    required String prmPackId,
    required String prmNoPacks,
    required String prmConVal,
    required String prmCmpId,
    required String prmBrId,
    required String prmFaId,
    required String prmUId,
    required String prmRate,
    required String prmBillNo,
  }) async {
    String uri =
        "$savePoListUrl?PrmTokenNo=$prmTokenNo&PrmDate=$prmDatePrmToCnt&"
        "PrmCurntCnt=$prmCurntCnt&PrmToCnt=$PrmToCnt&PrmAccId=$prmAccId&"
        "PrmItemId=$prmItemId&PrmUomId=$prmUomId&PrmTaxId=$prmTaxId&"
        "PrmPackId=$prmPackId&PrmNoPacks=$prmNoPacks&PrmConVal=$prmConVal&"
        "PrmCmpId=$prmCmpId&PrmBrId=$prmBrId&PrmFaId=$prmFaId&PrmUId=$prmUId&"
        "PrmRate=$prmRate&PrmBillNo=$prmBillNo";
    if (kDebugMode) {
      print(uri);
    }
    try {
      final response = await http.get(Uri.parse(uri));
      if (kDebugMode) {
        print("Response: ${response.body}");
      }

      final Map<String, dynamic> responseMap = json.decode(response.body);

      return responseMap['ErrorCode'].toString();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in fnSavePackingItem: $error');
      }
      rethrow;
    }
  }

  Future<List<PreviousOrderCountModel>> getPreviousOrderCount() async {
    String uri = getPreviousOrderCounts;
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
          .map((json) => PreviousOrderCountModel.fromJson(json))
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in getPreviousOrderCount: $error');
      }
      rethrow;
    }
  }

  Future<List<RoundTypeModel>> fnGetRoundList({
    required String prmCompanyId,
  }) async {
    String uri = "$fnGetRoundListUrl?PrmCompanyId=$prmCompanyId";
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
      return responseList.map((json) => RoundTypeModel.fromJson(json)).toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in fnGetRoundList: $error');
      }
      rethrow;
    }
  }

  Future<List<DailyDropListModel>> fnGetVehicleTransportList({
    required String prmDate,
    required String prmCmpId,
    required String prmBrId,
    required String prmFaId,
    required String prmUId,
  }) async {
    String uri = "$fnGetVehicleTransportListUrl?PrmDate=$prmDate&"
        "PrmCmpId=$prmCmpId&PrmBrId=$prmBrId&PrmFaId=$prmFaId&PrmUId=$prmUId";
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
          .map((json) => DailyDropListModel.fromJson(json))
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('Exception in fnGetVehicleTransportList: $error');
      }
      rethrow;
    }
  }

  Future<CommonResponseModel> fnSaveDeliveryDetails({
    required String prmAutoId,
    required String prmId,
    required String prmImage1,
    required String prmImage2,
    required String prmImage3,
    required String prmDeliveryRemarks,
    required String prmCmpId,
    required String prmBrId,
    required String prmFaId,
    required String prmUId,
  }) async {
    String uri = "$fnSaveDeliveryDetailsUrl?PrmAutoId=$prmAutoId&PrmId=$prmId&"
        "PrmImage1=$prmImage1&PrmImage2=$prmImage2&PrmImage3=$prmImage3&"
        "PrmDeliveryRemarks=$prmDeliveryRemarks&PrmCmpId=$prmCmpId&"
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
      final Map<String, dynamic> responseJson = json.decode(response.body);
      return CommonResponseModel.fromJson(responseJson);
    } catch (error) {
      if (kDebugMode) {
        print('Exception in fnSaveDeliveryDetails: $error');
      }
      rethrow;
    }
  }

  Future<CommonResponseModel> fnUpdateCustomerLocation({
    required String prmAccId,
    required String prmLatitude,
    required String prmLongitude,
    required String prmAutoId,
  }) async {
    String uri = "$fnUpdateCustomerLocationUrl?PrmAccId=$prmAccId&"
        "PrmLatitude=$prmLatitude&PrmLongitude=$prmLongitude&PrmAutoId=$prmAutoId";
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
      final Map<String, dynamic> responseJson = json.decode(response.body);
      return CommonResponseModel.fromJson(responseJson);
    } catch (error) {
      if (kDebugMode) {
        print('Exception in fnSaveDeliveryDetails: $error');
      }
      rethrow;
    }
  }

  Future fnUploadFiles({
    XFile? image,
    XFile? sketch,
    XFile? video,
    required String imageNameWithType,
    required String sketchNameWithType,
    required String videoNameWithType,
  }) async {
    try {
      ByteData byteData = await rootBundle.load('assets/images/warning.png');
      Uint8List bytes = byteData.buffer.asUint8List();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File tempFile = File('$tempPath/warning.png');
      await tempFile.writeAsBytes(bytes);
      XFile nullImage = XFile(tempFile.path);
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(fileUploadUrl));
      request.fields.addAll({
        'ImageName': image != null ? imageNameWithType : 'none.png',
        'SketchName': sketch != null ? sketchNameWithType : 'none.png',
        'VideoName': video != null ? videoNameWithType : 'none.png',
      });
      if (kDebugMode) {
        print(
          'ImageName: $imageNameWithType SketchName: $sketchNameWithType VideoName: $videoNameWithType',
        );
      }
      if (kDebugMode) {
        image != null
            ? print('image path: ${image.path}')
            : print('image path is null');
      }
      if (kDebugMode) {
        sketch != null
            ? print('sketch path: ${sketch.path}')
            : print('sketch path is null');
      }
      if (kDebugMode) {
        video != null
            ? print('video path: ${video.path}')
            : print('video path is null');
      }
      image != null
          ? request.files
              .add(await http.MultipartFile.fromPath('Image', image.path))
          : request.files
              .add(await http.MultipartFile.fromPath('Image', nullImage.path));
      sketch != null
          ? request.files
              .add(await http.MultipartFile.fromPath('Sketch', sketch.path))
          : request.files
              .add(await http.MultipartFile.fromPath('Sketch', nullImage.path));
      video != null
          ? request.files
              .add(await http.MultipartFile.fromPath('Video', video.path))
          : request.files
              .add(await http.MultipartFile.fromPath('Video', nullImage.path));
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('request: $request');
          print('files uploaded successfully');
          print(await response.stream.bytesToString());
        }
      } else {
        if (kDebugMode) {
          print('Failed to upload files');
          print(response.reasonPhrase);
          throw 'Failed to upload files';
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('fnUploadFiles called and failed $e');
      }
      throw e.toString();
    }
  }
}
