import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:williams/screens/admin_side/home/page_cards.dart';

import '../../../custom_widgets/custom_exit_confirmation.dart';
import '../buying_sheet/buying_sheet_screen.dart';
import '../packing/packing_view.dart';
import 'appbar.dart';

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
    // Reset to default (all orientations) when leaving the screen
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
      backgroundColor: Colors.black,
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
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            children: [
              HomeAppBar(),
              const SizedBox(
                height: 25,
              ),
              HomeCards(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const PackingView(),
                      settings: const RouteSettings(name: '/home'),
                    ),
                  );
                },
                cardName: 'PACKING',
                imagePath: 'assets/images/login_bg.jpg',
              ),
              const SizedBox(
                height: 15,
              ),
              HomeCards(
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const BuyingSheetScreen(),
                    ),
                  );
                },
                cardName: 'BUYING SHEET',
                imagePath: 'assets/images/login_bg.jpg',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
