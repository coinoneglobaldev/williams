import 'package:flutter/material.dart';

import '../../../custom_widgets/custom_logout_button.dart';

class DriverHomeAppbar extends StatelessWidget {
  final String name;

  const DriverHomeAppbar({
    super.key,
    required this.name,
  });

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
              'D.No: A123',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const Spacer(),
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
