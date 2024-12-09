import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../login/login.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
            ),
            Text(
              'Samuel L Jackson',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Text(
              'Admin',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
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
                            builder: (context) => const ScreenLogin(),
                          ),
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
        ),
      ],
    );
  }
}
