import 'package:flutter/material.dart';

import '../../../custom_widgets/custom_snackbar.dart';

class DeliveryItemList extends StatelessWidget {
  final String name;
  final String itemCount;
  final String address;
  final String orderId;

  const DeliveryItemList({
    required this.name,
    required this.itemCount,
    required this.address,
    required this.orderId,
    super.key,
  });

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
                  padding: EdgeInsets.all(8.0),
                  child: Text(orderId),
                ),
              )
            ],
          ),
          Util.titleAndSubtitleWidget(
              title: 'Item Count:', subTitle: itemCount),
          Util.titleAndSubtitleWidget(title: 'Address:', subTitle: address),
        ],
      ),
    );
  }
}
