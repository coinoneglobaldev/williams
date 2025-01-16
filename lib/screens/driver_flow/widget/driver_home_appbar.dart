import 'package:flutter/material.dart';

import '../../../custom_widgets/custom_logout_button.dart';

class DriverHomeAppbar extends StatelessWidget {
  final String name;
  final String dNo;

  const DriverHomeAppbar({
    super.key,
    required this.name,
    required this.dNo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome,',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Text(
              'D No: $dNo',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
        // const Spacer(),
        // GestureDetector(
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       CupertinoPageRoute(
        //         builder: (context) => const RouteMapScreen(),
        //       ),
        //     );
        //   },
        //   child: const Image(
        //     image: AssetImage('assets/icons/appbar_map.png'),
        //     height: 30,
        //   ),
        // ),
        // SizedBox(width: 10),
        IconButton(
          icon: Icon(Icons.logout),
          color: Colors.black,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const CustomLogoutConfirmation(),
            );
          },
        ),
      ],
    );
  }
}
