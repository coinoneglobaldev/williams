import 'package:flutter/cupertino.dart';

import 'screens/login/login.dart';
import 'screens/login/splash.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => const ScreenSplash(),
        );
      case '/login': // ScreenLogin
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => const ScreenLogin(),
        );
      default:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => const ScreenLogin(),
        );
    }
  }
}
