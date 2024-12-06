import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:williams/routes.dart';

import 'constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  ).then(
    (value) {
      runApp(
        const ProviderScope(
          child: MyApp(),
        ),
      );
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: (routeSettings) => Routes.generateRoute(
        routeSettings,
      ),
      key: _scaffoldKey,
      theme: ThemeData(
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(10),
          thumbColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.all(Colors.grey),
          crossAxisMargin: 5,
          mainAxisMargin: 10,
          minThumbLength: 30,
          thickness: WidgetStateProperty.all(10),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.white,
          filled: true,
          prefixIconColor: themeColor,
          suffixIconColor: themeColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        primaryColor: themeColor,
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(primary: themeColor, secondary: Colors.black),
        textTheme: TextTheme(
          labelMedium: TextStyle(
            fontSize: 25,
            color: themeColor,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: TextButton.styleFrom(
            disabledBackgroundColor: Colors.grey,
            disabledForegroundColor: Colors.white,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            minimumSize: const Size(60, 55),
            padding: const EdgeInsets.symmetric(vertical: 5),
            backgroundColor: themeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          unselectedLabelStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          labelStyle: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
          indicatorSize: TabBarIndicatorSize.label,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: themeColor,
              width: 3,
            ),
          ),
        ),
      ),
    );
  }
}
