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
  String? userName;
  String? passWord;
  String? prmCmpId;
  String? prmBrId;

  @override
  void initState() {
    super.initState();
    fnLoginCheck();
  }

  fnLoginCheck() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? accId = pref.getString("accId");
    String? userType = pref.getString("userType");
    String? userName = pref.getString("userName");
    String? password = pref.getString("password");
    if (accId != '' && userName != '' && password != '') {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) {
            if (userType == 'BSHT') {
              return _fnNavigateToBuyerPage();
            } else if (userType == 'PACK') {
              return _fnNavigateToPackingPage();
            } else if (userType == 'DRVR') {
              return _fnNavigateToDriverPage();
            } else {
              return _fnNavigateToLoginPage();
            }
          },
        ),
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => _fnNavigateToLoginPage(),
        ),
      );
    }
  }

  _fnNavigateToPackingPage() {
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('userName')!;
    final String accId = prefs.getString('accId')!;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => DeliveryItemsListScreen(
          name: userName,
          dNo: accId,
        ),
      ),
    );
  }

  _fnNavigateToLoginPage() {
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
                  'Sovrana',
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
