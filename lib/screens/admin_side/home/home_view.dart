import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:williams/screens/admin_side/home/page_cards.dart';

import '../../../custom_widgets/custom_exit_confirmation.dart';
import '../buying_sheet/buying_sheet_screen.dart';
import '../packing/packing_view.dart';
import 'home_appbar.dart';

class ScreenHomeView extends ConsumerStatefulWidget {
  const ScreenHomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScreenHomePageState();
}

class _ScreenHomePageState extends ConsumerState<ScreenHomeView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) {
            if (didPop) {
              return;
            }
            showDialog(
              barrierColor: Colors.black.withOpacity(0.8),
              context: context,
              builder: (context) => const ScreenCustomExitConfirmation(),
            );
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  HomeAppBar(),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HomeCards(
                        cardName: 'PACKING',
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const PackingView(),
                              settings: const RouteSettings(name: '/home'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      HomeCards(
                        cardName: 'BUYING SHEET',
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => const BuyingSheetScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
