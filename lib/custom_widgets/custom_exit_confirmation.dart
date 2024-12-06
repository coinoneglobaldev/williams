import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

class ScreenCustomExitConfirmation extends StatefulWidget {
  const ScreenCustomExitConfirmation({super.key});

  @override
  State<ScreenCustomExitConfirmation> createState() =>
      _ScreenCustomExitConfirmationState();
}

class _ScreenCustomExitConfirmationState
    extends State<ScreenCustomExitConfirmation> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: secondaryColor,
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
        'Are you sure you want to exit ?',
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
              SystemNavigator.pop();
            },
            child: const Text(
              'EXIT',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
        SizedBox(
          height: 35,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
