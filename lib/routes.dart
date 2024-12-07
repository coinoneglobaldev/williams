import 'package:flutter/cupertino.dart';
import 'package:williams/screens/admin_side/home/home_view.dart';
import 'package:williams/screens/login/login.dart';
import 'package:williams/screens/login/splash.dart';

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
          builder: (_) => const ScreenHomeView(),
        );
      default:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => const ScreenHomeView(),
        );
    }
  }
}
