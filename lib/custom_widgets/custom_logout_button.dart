import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/login/login.dart';

class CustomLogoutConfirmation extends StatefulWidget {
  const CustomLogoutConfirmation({super.key});

  @override
  State<CustomLogoutConfirmation> createState() =>
      _CustomLogoutConfirmationState();
}

class _CustomLogoutConfirmationState extends State<CustomLogoutConfirmation> {
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
          height: 35,
          child: TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(
                  builder: (context) => const ScreenLogin(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
        SizedBox(
          height: 35,
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
