import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:williams/screens/driver_side/widget/delivery_item_list.dart';

import '../../custom_widgets/custom_exit_confirmation.dart';
import 'delivery_upload_screen.dart';

class DeliveryItemsListScreen extends StatefulWidget {
  const DeliveryItemsListScreen({super.key});

  @override
  State<DeliveryItemsListScreen> createState() =>
      _DeliveryItemsListScreenState();
}

class _DeliveryItemsListScreenState extends State<DeliveryItemsListScreen> {
  // List of delivery items
  final List<Map<String, String>> deliveryItems = [
    {
      'name': 'Samuel',
      'poNo': '3344',
      'address': 'Thodupuzha, opposite private stand'
    },
    {
      'name': 'Jackson',
      'poNo': '3455',
      'address': 'Kottayam, opposite private stand'
    },
    {
      'name': 'Emmanuel',
      'poNo': '7865',
      'address': 'Thrissur, opposite private stand'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Delivery Items',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () {
              // Add logout functionality here
              showDialog(
                context: context,
                builder: (context) => const ScreenCustomExitConfirmation(),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: deliveryItems.length,
        itemBuilder: (context, index) {
          final item = deliveryItems[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => DeliveryUploadScreen(),
                ),
              );
            },
            child: DeliveryItemList(
              name: item['name']!,
              poNo: item['poNo']!,
              address: item['address']!,
            ),
          );
        },
      ),
    );
  }
}
