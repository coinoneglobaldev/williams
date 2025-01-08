import 'package:flutter/material.dart';

Color themeColor = Colors.black;
Color primaryColor = Colors.grey.shade900;
Color secondaryColor = Colors.grey.shade800;
Color buttonColor = Colors.blue.shade900;
Color textColor = Colors.white;

const String appVersion = '1.0.9';

String baseUrl = 'https://sysware-lasovrana.co.uk/lasov';

String webAppLogUrl = '$baseUrl/WebAppLog.asmx';
String webAppGeneralUrl = '$baseUrl/WebAppGeneral.asmx';
String transactionUrl = '$baseUrl/WebAppTRansaction.asmx';

String loginUrl = '$webAppLogUrl/FnGetUserLogIn';

String getCategoryListUrl = '$webAppGeneralUrl/FnGetCategoryList';
String getSupplierListUrl = '$webAppGeneralUrl/FnGetSupplierList';
String getUomListUrl = '$webAppGeneralUrl/FnGetUomList';

String getSalesOrderListUrl = '$transactionUrl/FnGetSalesOrderList';
String getSalesOrderItemListUrl = '$transactionUrl/FnGetSalesOrderItemList';
String getPackingTypeListData = '$webAppGeneralUrl/FnGetPackingTypeList';
String releaseOrderAllOrder = '$transactionUrl/FnIsReleaseAllOrder';
String savePackingItem = '$transactionUrl/FnIsReleaseOrder';
String getBuyingSheetListUrl = '$transactionUrl/FnGetBuyingSheetList';

//todo: currently not in use but it will be used in future
String getCustomerListUrl = '$webAppGeneralUrl/FnGetCustomerList';
String getItemListUrl = '$webAppGeneralUrl/FnGetItemList';
