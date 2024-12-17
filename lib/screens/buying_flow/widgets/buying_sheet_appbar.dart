import 'package:flutter/material.dart';
import '../../../custom_widgets/custom_logout_button.dart';

class BuyingSheetAppbar extends StatelessWidget {
  const BuyingSheetAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Buying Sheet',
          style: TextStyle(
            fontSize: 50.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.black,
          ),
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