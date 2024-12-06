import 'package:flutter/cupertino.dart';
import 'package:williams/screens/homepage.dart';

import 'login/login.dart';
import 'login/splash.dart';

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
      case '/home': // ScreenHomePage
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => const ScreenHomePage(),
        );
      default:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => const ScreenHomePage(),
        );
    }
  }
}
