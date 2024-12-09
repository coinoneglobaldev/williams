import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
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
    _fnCheckIfSignedIn();
  }

  void _fnCheckIfSignedIn() async {
    await Future.delayed(const Duration(seconds: 2));
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
                  'Williams',
                  style: TextStyle(
                    height: 0.9,
                    color: buttonColor,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'of London',
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
