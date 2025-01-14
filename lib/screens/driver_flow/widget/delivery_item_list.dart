import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:williams/models/daily_drop_list_model.dart';

import '../../../custom_widgets/util_class.dart';

class DeliveryItemList extends StatefulWidget {
  final DailyDropListModel selectedItem;

  const DeliveryItemList({
    required this.selectedItem,
    super.key,
  });

  @override
  State<DeliveryItemList> createState() => _DeliveryItemListState();
}

class _DeliveryItemListState extends State<DeliveryItemList> {

  Future<void> _launchGoogleMaps() async {
    final item = widget.selectedItem;
    if ([item.latitude, item.longitude, item.address].every((x) => x.isEmpty)) {
      _handleError('Address or location not available');
      return;
    }
    final String query = item.latitude.isNotEmpty && item.longitude.isNotEmpty
        ? '${item.latitude},${item.longitude}'
        : item.address;
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$query'
    );
    try {
      if (!await canLaunchUrl(googleMapsUrl)) {
        throw Exception('Could not launch Google Maps');
      }
      await launchUrl(googleMapsUrl);
    } catch (e) {
      _handleError('Could not launch Google Maps');
    }
  }
  void _handleError(String message) {
    if (kDebugMode) {
      print(message);
      Util.customErrorSnackBar(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.selectedItem.isDelivery == '1'
            ? Colors.blue
            : Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Text(
                  widget.selectedItem.accountCr.isEmpty
                      ? 'Sorry, Account not available'
                      : widget.selectedItem.accountCr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Text(
                  widget.selectedItem.address.isEmpty
                      ? 'Sorry, Address not available'
                      : widget.selectedItem.address,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                widget.selectedItem.refNo.isEmpty
                    ? 'Sorry, Item count not available'
                    : widget.selectedItem.refNo,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.selectedItem.id),
                ),
              ),
              GestureDetector(
                onTap: _launchGoogleMaps,
                child: Container(
                  color: Colors.green,
                  child: const Image(
                    image: AssetImage('assets/icons/map.png'),
                    height: 60,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
