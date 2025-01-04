import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrientationSetup extends StatelessWidget {
  final Widget child;

  const OrientationSetup({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;

        if (isTablet) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        } else {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        }

        return child;
      },
    );
  }
}
