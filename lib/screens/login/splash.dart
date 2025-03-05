import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../buying_flow/buying_sheet_screen.dart';
import '../driver_flow/delivery_items_list_screen.dart';
import '../packing_flow/sales_order_list.dart';
import 'login.dart';

class ScreenSplash extends StatefulWidget {
  const ScreenSplash({super.key});

  @override
  State<ScreenSplash> createState() => _ScreenSplashState();
}

class _ScreenSplashState extends State<ScreenSplash> {
  @override
  void initState() {
    super.initState();
    fnLoginCheck();
  }

  Future<void> fnLoginCheck() async {
    if (!mounted) return;
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final String? accId = pref.getString("accId");
    final String? userType = pref.getString("userType");
    final String? userName = pref.getString("userName");
    final bool? isRememberMe = pref.getBool("isRememberMe");

    if (accId != null &&
        accId.isNotEmpty &&
        userName != null &&
        userName.isNotEmpty &&
        isRememberMe == true) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      if (userType != null) {
        switch (userType) {
          case 'BSHT':
            _fnNavigateToBuyerPage();
            break;
          case 'PACK':
            _fnNavigateToPackingPage();
            break;
          case 'DRVR':
            await _fnNavigateToDriverPage();
            break;
          default:
            _fnNavigateToLoginPage();
        }
      } else {
        _fnNavigateToLoginPage();
      }
    } else {
      if (!mounted) return;
      _fnNavigateToLoginPage();
    }
  }

  _fnNavigateToPackingPage() {
    if (!mounted) return;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => const SalesOrderList(),
      ),
    );
  }

  _fnNavigateToBuyerPage() {
    if (!mounted) return;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => const BuyingSheetScreen(),
      ),
    );
  }

  _fnNavigateToDriverPage() async {
    if (!mounted) return;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('userName')!;
    final String accId = prefs.getString('accId')!;
    String remarks = prefs.getString('remarks')!;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => DeliveryItemsListScreen(
          name: userName,
          dNo: accId,
          remark: remarks,
        ),
      ),
    );
  }

  _fnNavigateToLoginPage() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => const ScreenLogin(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'La',
                  style: TextStyle(
                    height: 0.9,
                    color: buttonColor,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'SovranaX',
                  style: TextStyle(
                    height: 0.9,
                    color: buttonColor,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Text(
            appVersion,
            style: TextStyle(
              color: buttonColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
