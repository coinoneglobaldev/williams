import 'package:flutter/material.dart';

Color themeColor = Colors.black;
Color primaryColor = Colors.grey.shade900;
Color secondaryColor = Colors.grey.shade800;
Color buttonColor = Colors.blue.shade900;
Color textColor = Colors.white;

const String appVersion = '1.1.4';

String baseUrl = 'https://sysware-lasovrana.co.uk/lasov';

String webAppLogUrl = '$baseUrl/WebAppLog.asmx';
String webAppGeneralUrl = '$baseUrl/WebAppGeneral.asmx';
String transactionUrl = '$baseUrl/WebAppTRansaction.asmx';

String loginUrl = '$webAppLogUrl/FnGetUserLogIn';

// used in buying
String getItemListUrl = '$transactionUrl/FnGetItemList';
String savePoListUrl = '$transactionUrl/FnSavePoList';
String getTokenNoUrl = '$transactionUrl/FnGetTokenNo';
String getBuyingSheetListUrl = '$transactionUrl/FnGetBuyingSheetList';
String getSupplierListUrl = '$webAppGeneralUrl/FnGetSupplierList';
String getCategoryListUrl = '$webAppGeneralUrl/FnGetCategoryList';
String checkSelectionUrl = '$transactionUrl/FnChekcSelection';
String getPreviousOrderCounts = '$transactionUrl/FnGetPreviousOrderCount';

// used in Sales order
String savePackingItemUrl = '$transactionUrl/FnIsReleaseOrder';
String releaseOrderAllOrderUrl = '$transactionUrl/FnIsReleaseAllOrder';
String getSalesOrderListUrl = '$transactionUrl/FnGetSalesOrderList';

// used in buying and Sales order
String getPackingTypeListDataUrl = '$webAppGeneralUrl/FnGetPackingTypeList';
String getSalesOrderItemListUrl = '$transactionUrl/FnGetSalesOrderItemList';

//used in driver
