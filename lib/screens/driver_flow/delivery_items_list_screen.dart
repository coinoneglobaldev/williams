import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:williams/screens/driver_flow/widget/delivery_item_list.dart';
import 'package:williams/screens/driver_flow/widget/driver_home_appbar.dart';
import 'delivery_upload_screen.dart';

class DeliveryItemsListScreen extends StatefulWidget {
  const DeliveryItemsListScreen({super.key});

  @override
  State<DeliveryItemsListScreen> createState() =>
      _DeliveryItemsListScreenState();
}

class _DeliveryItemsListScreenState extends State<DeliveryItemsListScreen> {
  final List<Map<String, String>> deliveryItems = [
    {
      'name': 'Samuel',
      'itemCount': '4',
      'address': 'Thodupuzha, opposite private stand',
      'orderId': 'TRK001',
    },
    {
      'name': 'Jackson',
      'itemCount': '3',
      'address': 'Kottayam, opposite private stand',
      'orderId': 'TRK002',
    },
    {
      'name': 'Emmanuel',
      'itemCount': '7',
      'address': 'Thrissur, opposite private stand',
      'orderId': 'TRK003',
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              DriverHomeAppbar(name: 'Ramesh U P'),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
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
                        itemCount: item['itemCount']!,
                        address: item['address']!,
                        orderId: item['orderId']!,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
