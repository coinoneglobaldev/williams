import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/login/login.dart';

class CustomLogoutConfirmation extends StatefulWidget {
  const CustomLogoutConfirmation({super.key});

  @override
  State<CustomLogoutConfirmation> createState() =>
      _CustomLogoutConfirmationState();
}

class _CustomLogoutConfirmationState extends State<CustomLogoutConfirmation> {
  Future<void> removePref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
    print('Logout successfully & Shared Preference removed');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(
        builder: (context) => const ScreenLogin(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.grey.shade900,
      title: const Text(
        'Exit ?',
        style: TextStyle(
          height: 0.9,
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        'Are you sure you want to Logout ?',
        style: TextStyle(
          height: 0.7,
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: <Widget>[
        SizedBox(
          height: 40,
          child: TextButton(
            onPressed: () {
              removePref();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
