import 'package:flutter/material.dart';
import 'package:williams/custom_widgets/custom_scaffold.dart';

class OrderItemView extends StatefulWidget {
  const OrderItemView({super.key});

  @override
  State<OrderItemView> createState() => _OrderItemViewState();
}

class _OrderItemViewState extends State<OrderItemView> {
  late List<OrderItem> orderItems;
  late List<TextEditingController> qtyControllers;
  late List<TextEditingController> notesControllers;

  @override
  void initState() {
    super.initState();
    orderItems = [
      OrderItem(
        packCode: 'PC001',
        description: 'Blue T-Shirt Large',
        qty: '',
        notes: 'Check quality',
      ),
      OrderItem(
        packCode: 'PC002',
        description: 'Red Polo Medium',
        qty: '',
        notes: 'Express delivery',
      ),
      OrderItem(
        packCode: 'PC003',
        description: 'Black Hoodie XL',
        qty: '',
        notes: '',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
    ];

    qtyControllers = orderItems
        .map((item) => TextEditingController(text: item.qty))
        .toList();
    notesControllers = orderItems
        .map((item) => TextEditingController(text: item.notes))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in qtyControllers) {
      controller.dispose();
    }
    for (var controller in notesControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get isValidToSave =>
      qtyControllers.every((controller) => controller.text.isNotEmpty);

  void _handleSave() {
    if (!isValidToSave) return;

    // Update items with current controller values
    for (int i = 0; i < orderItems.length; i++) {
      orderItems[i].qty = qtyControllers[i].text;
      orderItems[i].notes = notesControllers[i].text;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Saved Data'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...orderItems.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pack Code: ${item.packCode}'),
                          Text('Description: ${item.description}'),
                          Text('Quantity: ${item.qty}'),
                          Text('Notes: ${item.notes}'),
                          Text('Checked: ${item.isChecked ? 'Yes' : 'No'}'),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderItemTable({
    required List<OrderItem> data,
  }) {
    final columns = ['Qty', 'Pack Code', 'Description', 'Notes', 'Check box'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Items',
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8.0),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 30.0,
              dataRowColor: WidgetStateProperty.all(Colors.grey.shade900),
              headingRowColor: WidgetStateProperty.all(Colors.white),
              columns: columns
                  .map((column) => DataColumn(
                        label: Expanded(
                          child: Text(
                            column,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              rows: [
                ...data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: qtyControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                item.qty = value;
                              });
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          item.packCode,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          item.description,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: notesControllers[index],
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                item.notes = value;
                              });
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        Checkbox(
                          value: item.isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              item.isChecked = value ?? false;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenCustomScaffold(
      title: 'Order Item',
      bodyWidget: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildOrderItemTable(data: orderItems),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: isValidToSave ? _handleSave : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade900,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class OrderItem {
  final String packCode;
  final String description;
  String qty;
  String notes;
  bool isChecked;

  OrderItem({
    required this.packCode,
    required this.description,
    this.qty = '',
    this.notes = '',
    this.isChecked = false,
  });
}
