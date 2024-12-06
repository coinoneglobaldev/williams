import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:williams/screens/home/page_cards.dart';

import '../../custom_widgets/custom_exit_confirmation.dart';
import '../../custom_widgets/custom_scaffold.dart';
import 'appbar.dart';

class ScreenHomeView extends ConsumerStatefulWidget {
  const ScreenHomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScreenHomePageState();
}

class _ScreenHomePageState extends ConsumerState<ScreenHomeView> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return ScreenCustomScaffold(
      homeWidget: SafeArea(
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
                onTap: (){},
                cardName: 'PACKING',
                imagePath: 'assets/images/login_bg.jpg',
              ),
              const SizedBox(
                height: 15,
              ),
              HomeCards(
                onTap: (){},
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
