import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;

  const Responsive({
    super.key,
    required this.mobile,
    required this.tablet,
  });

  /// Returns true if the device is a mobile phone.
  static bool isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 600 || (size.width < 900 && size.height < 500);
  }

  /// Returns true if the device is a tablet.
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return (size.width >= 600 && size.width < 1200 && size.height >= 500) ||
        (size.width >= 900 && size.width < 1200 && size.height < 500);
  }

  /// Returns true if the device is a desktop.
  static bool isDesktop(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 1200;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    if ((size.width >= 600 && size.height >= 500) ||
        (size.width >= 900 && size.height < 500)) {
      return tablet;
    } else {
      return mobile;
    }
  }
}
