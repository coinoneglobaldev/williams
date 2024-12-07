import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      MaterialPageRoute(
        builder: (context) => const ScreenLogin(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    .animate()
                    .slideY(
                      duration: 400.milliseconds,
                      delay: 200.milliseconds,
                      curve: Curves.easeInOut,
                      begin: 0.1,
                      end: 0.0,
                    )
                    .fadeIn(),
                Text(
                  'of London',
                  style: TextStyle(
                    height: 0.9,
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    .animate()
                    .slideY(
                      duration: 400.milliseconds,
                      delay: 400.milliseconds,
                      curve: Curves.easeInOut,
                      begin: 0.1,
                      end: 0.0,
                    )
                    .fadeIn(),
              ],
            ),
          ),
          Spacer(),
          Text(
            appVersion,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          )
              .animate()
              .slideY(
                duration: 400.milliseconds,
                delay: 600.milliseconds,
                curve: Curves.easeInOut,
                begin: 0.1,
                end: 0.0,
              )
              .fadeIn(),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
