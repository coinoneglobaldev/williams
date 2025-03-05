import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../custom_widgets/custom_logout_button.dart';

class DriverHomeAppbar extends StatelessWidget {
  final String name;
  final String dNo;
  final Uri url =
      Uri.parse('https://flowares.com/index.php/home/accountdeletion');
  DriverHomeAppbar({
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

        PopupMenuButton(
            itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const CustomLogoutConfirmation(),
                      );
                    },
                    child: Text('Logout'),
                  ),
                  PopupMenuItem(
                    onTap: () async {
                      if (!await launchUrl(url)) {
                        if (kDebugMode) {
                          print('Could not launch $url');
                        }
                      }
                    },
                    child: Text('Account Deletion'),
                  ),
                ])

        // SizedBox(
        //   width: 150,
        //   child: ExpansionTile(
        //     title: Text('Help!'),
        //     controlAffinity: ListTileControlAffinity.trailing,
        //     children: <Widget>[
        //       ListTile(
        //           onTap: () {
        //             showDialog(
        //               context: context,
        //               builder: (context) => const CustomLogoutConfirmation(),
        //             );
        //           },
        //           title: Text('Logout')),
        //       ListTile(onTap: () {}, title: Text('Account Deletion'))
        //     ],
        //   ),
        // ),
        // IconButton(
        //   icon: Icon(Icons.logout),
        //   color: Colors.black,
        //   onPressed: () {
        //     showDialog(
        //       context: context,
        //       builder: (context) => const CustomLogoutConfirmation(),
        //     );
        //   },
        // ),
      ],
    );
  }
}
