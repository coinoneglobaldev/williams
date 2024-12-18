import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../custom_widgets/util_class.dart';

class DeliveryItemList extends StatelessWidget {
  final String name;
  final String itemCount;
  final String address;
  final String orderId;
  final String latitude;
  final String longitude;

  const DeliveryItemList({
    required this.name,
    required this.itemCount,
    required this.address,
    required this.orderId,
    required this.latitude,
    required this.longitude,
    super.key,
  });

  void _launchGoogleMaps() async {
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      if (kDebugMode) {
        print('Could not launch Google Maps');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Util.titleAndSubtitleWidget(title: 'Name:', subTitle: name),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(orderId),
                ),
              ),
            ],
          ),
          Util.titleAndSubtitleWidget(
              title: 'Item Count:', subTitle: itemCount),
          Util.titleAndSubtitleWidget(title: 'Address:', subTitle: address),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: _launchGoogleMaps,
              child: const Image(
                image: AssetImage('assets/icons/map.png'),
                height: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
