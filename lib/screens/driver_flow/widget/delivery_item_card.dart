import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../custom_widgets/util_class.dart';
import '../../../models/daily_drop_list_model.dart';
import 'transport_item_list.dart';

class DeliveryItemCard extends StatefulWidget {
  final DailyDropListModel selectedItem;
  final Function refreshCallback;
  final String remark;

  const DeliveryItemCard({
    required this.selectedItem,
    required this.refreshCallback,
    required this.remark,
    super.key,
  });

  @override
  State<DeliveryItemCard> createState() => _DeliveryItemCardState();
}

class _DeliveryItemCardState extends State<DeliveryItemCard> {
  String hideChk = '';

  Future<void> _launchGoogleMaps() async {
    final item = widget.selectedItem;
    if ([item.latitude, item.longitude, item.firstLineAdd]
        .every((x) => x.isEmpty)) {
      _handleError('Address or location not available');
      return;
    }
    final String query = item.latitude.isNotEmpty && item.longitude.isNotEmpty
        ? '${item.latitude},${item.longitude}'
        : '${item.zipCode},${item.firstLineAdd}';
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

  @override
  void initState() {
    super.initState();
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
      padding: const EdgeInsets.all(10),
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
                    letterSpacing: 1,
                    fontSize: 15,
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Item count: ${widget.selectedItem.itmCnt}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              Text(
                'Amount: £ ${double.parse(widget.selectedItem.grandTotal).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                widget.remark == ''
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.selectedItem.isChk == '0'
                              ? Colors.blue
                              : widget.selectedItem.isChk == '1'
                                  ? Colors.orange
                                  : Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 10,
                          shadowColor: Colors.black,
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.selectedItem.refNo,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
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
