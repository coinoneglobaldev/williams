import 'package:flutter/material.dart';

class DeliveryItemList extends StatelessWidget {
  final String name;
  final String poNo;
  final String address;

  const DeliveryItemList({
    required this.name,
    required this.poNo,
    required this.address,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Row
          Row(
            children: [
              Icon(Icons.person, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // PoNo Row
          Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Po No: $poNo',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Address Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}