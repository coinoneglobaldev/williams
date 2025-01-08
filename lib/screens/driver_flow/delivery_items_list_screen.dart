import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:williams/screens/driver_flow/widget/delivery_item_list.dart';
import 'package:williams/screens/driver_flow/widget/driver_home_appbar.dart';

import '../../custom_widgets/custom_exit_confirmation.dart';
import 'delivery_upload_screen.dart';

class DeliveryItemsListScreen extends StatefulWidget {
  const DeliveryItemsListScreen({super.key});

  @override
  State<DeliveryItemsListScreen> createState() =>
      _DeliveryItemsListScreenState();
}

class _DeliveryItemsListScreenState extends State<DeliveryItemsListScreen> {
  String? postalCode;
  bool isLoading = true;
  late List<Map<String, String>> deliveryItems;

  Future<void> getCoordinates(int index, Map<String, String> item) async {
    try {
      List<Location> locations = await locationFromAddress(item['address']!);

      if (locations.isNotEmpty) {
        final location = locations.first;

        setState(() {
          deliveryItems[index] = {
            ...item,
            'latitude': location.latitude.toString(),
            'longitude': location.longitude.toString(),
          };
        });

        print(
            'Coordinates for ${item['id']}: ${location.latitude}, ${location.longitude}');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Geocoding failed: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> initializeDeliveryItems() async {
    // Initialize the delivery items
    deliveryItems = [
      {
        'id': '1',
        'name': 'Samuel',
        'itemCount': '4',
        'address': '40 RichFord Road E15 3PQ',
        'orderId': 'PO-123',
        'latitude': '',
        'longitude': '',
      },
      {
        'id': '2',
        'name': 'Jackson',
        'itemCount': '3',
        'address': '114 Oval Road CR0 6BL',
        'orderId': 'PO-124',
        'latitude': '',
        'longitude': '',
      },
      {
        'id': '3',
        'name': 'Emmanuel',
        'itemCount': '7',
        'address': '114 Oval Road CR0 6BL',
        'orderId': 'PO-125',
        'latitude': '',
        'longitude': '',
      },
    ];

    // Fetch coordinates for items with empty coordinates
    for (int i = 0; i < deliveryItems.length; i++) {
      if ((deliveryItems[i]['latitude'] == '' ||
              deliveryItems[i]['latitude'] == '0.0') &&
          (deliveryItems[i]['longitude'] == '' ||
              deliveryItems[i]['longitude'] == '0.0')) {
        await getCoordinates(i, deliveryItems[i]);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDeliveryItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) {
            return;
          }
          showDialog(
            barrierColor: Colors.black.withValues(alpha: 0.8),
            context: context,
            builder: (context) => const ScreenCustomExitConfirmation(),
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const DriverHomeAppbar(name: 'Ramesh U P'),
                const SizedBox(height: 10),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: deliveryItems.length,
                          itemBuilder: (context, index) {
                            final item = deliveryItems[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        const DeliveryUploadScreen(),
                                  ),
                                );
                              },
                              child: DeliveryItemList(
                                name: item['name']!,
                                itemCount: item['itemCount']!,
                                address: item['address']!,
                                orderId: item['orderId']!,
                                latitude: item['latitude']!,
                                longitude: item['longitude']!,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
