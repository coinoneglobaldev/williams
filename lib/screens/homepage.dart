import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants.dart';
import '../custom_widgets/custom_exit_confirmation.dart';
import '../custom_widgets/custom_scaffold.dart';
import '../login/login.dart';

class ScreenHomePage extends ConsumerStatefulWidget {
  const ScreenHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScreenHomePageState();
}

class _ScreenHomePageState extends ConsumerState<ScreenHomePage> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return ScreenCustomScaffold(
      isPremium: false,
      homeWidget: PopScope(
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(
                            'assets/images/user.png',
                          ),
                        )
                            .animate()
                            .slideY(
                              duration: 400.milliseconds,
                              delay: 200.milliseconds,
                              curve: Curves.easeInOut,
                              begin: 0.1,
                              end: 0.0,
                            )
                            .fadeIn(),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome,',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            )
                                .animate()
                                .slideY(
                                  duration: 400.milliseconds,
                                  delay: 400.milliseconds,
                                  curve: Curves.easeInOut,
                                  begin: 0.1,
                                  end: 0.0,
                                )
                                .fadeIn(),
                            Text(
                              'Samuel L Jackson',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            )
                                .animate()
                                .slideY(
                                  duration: 400.milliseconds,
                                  delay: 600.milliseconds,
                                  curve: Curves.easeInOut,
                                  begin: 0.1,
                                  end: 0.0,
                                )
                                .fadeIn(),
                            Text(
                              'Admin',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            )
                                .animate()
                                .slideY(
                                  duration: 400.milliseconds,
                                  delay: 800.milliseconds,
                                  curve: Curves.easeInOut,
                                  begin: 0.1,
                                  end: 0.0,
                                )
                                .fadeIn(),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            showMenu(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: themeColor,
                              surfaceTintColor: Colors.transparent,
                              context: context,
                              items: [
                                PopupMenuItem(
                                  value: 2,
                                  child: InkWell(
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Logout',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ScreenLogin()),
                                          (route) => false);
                                    },
                                  ),
                                ),
                              ],
                              elevation: 8,
                              position: const RelativeRect.fromLTRB(
                                100,
                                1,
                                0,
                                0,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.more_horiz_rounded,
                            color: Colors.white,
                          ),
                        )
                            .animate()
                            .slideY(
                              duration: 400.milliseconds,
                              delay: 1000.milliseconds,
                              curve: Curves.easeInOut,
                              begin: 0.1,
                              end: 0.0,
                            )
                            .fadeIn(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);

  final int year;
  final int sales;
}
