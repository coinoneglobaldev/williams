import 'package:flutter/material.dart';

import '../custom_widgets/custom_exit_confirmation.dart';

class ScreenCustomNetworkError extends StatefulWidget {
  const ScreenCustomNetworkError({super.key});

  @override
  State<ScreenCustomNetworkError> createState() =>
      _ScreenCustomNetworkErrorState();
}

class _ScreenCustomNetworkErrorState extends State<ScreenCustomNetworkError> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          showDialog(
            barrierColor: Colors.black.withOpacity(0.8),
            context: context,
            builder: (context) => const ScreenCustomExitConfirmation(),
          );
        },
        child: Column(
          children: [
            Expanded(
                child: Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Colors.white,
                      size: 50,
                    ),
                    Text(
                      'Network error',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Please check your internet connection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
