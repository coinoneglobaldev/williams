import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../custom_widgets/custom_scaffold.dart';
import '../order_item/order_item_view.dart';

class PackingView extends StatefulWidget {
  const PackingView({super.key});

  @override
  State<PackingView> createState() => _PackingViewState();
}

class _PackingViewState extends State<PackingView> {
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final List<TableData> stitchingData = [
    TableData(
      round: "First Round",
      date: "2024-02-15",
      poNo: "PO-789",
      address: "123 Main Street, Mumbai, Maharashtra",
      customerName: "Raj Industries",
    ),
    TableData(
      round: "Second Round",
      date: "2024-02-20",
      poNo: "PO-790",
      address: "456 Park Avenue, Delhi, New Delhi",
      customerName: "Kumar Enterprises",
    ),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startDateController.text = _formatDate(DateTime.now());
    endDateController.text = _formatDate(DateTime.now());
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'start_date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: startDate ?? DateTime.now(),
          firstDate: DateTime(2021),
          lastDate: DateTime(2025),
        );
      },
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        startDateController.text = _formatDate(picked);

        if (endDate != null && picked.isAfter(endDate!)) {
          endDate = null;
          endDateController.text = '';
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'end_date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: endDate ?? startDate ?? DateTime.now(),
          firstDate: startDate!,
          lastDate: DateTime(2025),
        );
      },
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
        endDateController.text = _formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenCustomScaffold(
      scaffoldColor: Colors.white,
      title: 'Packing',
      bodyWidget: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(' Start Date',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      TextField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.calendar_today),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        controller: startDateController,
                        onTap: _selectStartDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(' End Date',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      TextField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.calendar_today),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        controller: endDateController,
                        onTap: _selectEndDate,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildStitchingEstimateTable(data: stitchingData),
          ],
        ),
      ),
    );
  }

  Widget _buildStitchingEstimateTable({
    required List<TableData> data,
  }) {
    final columns = ['Order', 'Round', 'Date', 'PO No.', 'Customer', 'Address'];

    void navigateToDetail(TableData item, int index) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => const OrderItemView(),
          settings: const RouteSettings(name: '/home'),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(100.0),
          columnWidths: const {
            0: FixedColumnWidth(80),
            1: FixedColumnWidth(80),
            2: FixedColumnWidth(100),
            3: FixedColumnWidth(80),
            4: FixedColumnWidth(100),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              children: columns
                  .map(
                    (column) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        column,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            ...data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                ),
                children: [
                  for (var i = 0; i < columns.length; i++)
                    TableRowInkWell(
                      onTap: () => navigateToDetail(item, index),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          i == 0
                              ? '${index + 1}'
                              : i == 1
                                  ? item.round
                                  : i == 2
                                      ? item.date
                                      : i == 3
                                          ? item.poNo
                                          : i == 4
                                              ? item.customerName
                                              : item.address,
                          style: const TextStyle(color: Colors.white),
                          textAlign: i == 4 ? TextAlign.end : TextAlign.start,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class TableData {
  final String round;
  final String date;
  final String poNo;
  final String address;
  final String customerName; // You might want to add this

  TableData({
    required this.round,
    required this.date,
    required this.poNo,
    required this.address,
    required this.customerName,
  });
}
