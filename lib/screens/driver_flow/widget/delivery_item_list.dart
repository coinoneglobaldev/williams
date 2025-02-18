import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lasovrana/screens/driver_flow/widget/transport_item_list.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../custom_widgets/util_class.dart';
import '../../../models/daily_drop_list_model.dart';

class DeliveryItemList extends StatefulWidget {
  final DailyDropListModel selectedItem;
  final Function refreshCallback;

  const DeliveryItemList({
    required this.selectedItem,
    required this.refreshCallback,
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
    final Uri googleMapsUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
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
        color:
            widget.selectedItem.isDelivery == '1' ? Colors.blue : Colors.green,
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
                  widget.selectedItem.accountDr.isEmpty
                      ? 'Sorry, Account not available'
                      : widget.selectedItem.accountDr,
                  style: const TextStyle(
                    letterSpacing: 2,
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
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Item count: ${widget.selectedItem.itmCnt}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                'Amount: £ ${double.parse(widget.selectedItem.grandTotal).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.selectedItem.isChk == '0'
                        ? Colors.red
                        : Colors.blue,
                    minimumSize: const Size(100, 40),
                    elevation: 4,
                  ),
                  onPressed: widget.selectedItem.isDelivery == '1'
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => TransportItemList(
                                selectedItem: widget.selectedItem,
                              ),
                            ),
                          ).then((value) => widget.refreshCallback());
                        },
                  child: const Text(
                    'Check',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.selectedItem.refNo,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                SizedBox(height: 10),
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
          )
        ],
      ),
    );
  }
}
