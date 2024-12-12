import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../custom_widgets/custom_scaffold.dart';
import 'order_item_view.dart';

class SalesOrderList extends StatefulWidget {
  const SalesOrderList({super.key});

  @override
  State<SalesOrderList> createState() => _SalesOrderListState();
}

class _SalesOrderListState extends State<SalesOrderList> {
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController roundController = TextEditingController();
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
  List<String> rounds = ['Round 1', 'Round 2', 'Round 3'];
  String? selectedRound;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startDateController.text = _formatDate(DateTime.now());
    endDateController.text = _formatDate(DateTime.now());
    selectedRound = rounds[0];
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
      resizeToAvoidBottomInset: false,
      title: 'Packing',
      bodyWidget: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Order List',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        ' ',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Round',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        value: selectedRound, // Ensure this variable holds the initial selected value or is null
                        items: rounds.map((String round) {
                          return DropdownMenuItem<String>(
                            value: round,
                            child: Text(round),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRound = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                Spacer(),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(height: 16),
                            _colorMatchingData(
                              title: 'Hold\t\t\t\t',
                              colors: Colors.red.shade500,
                            ),
                            const SizedBox(height: 6),
                            _colorMatchingData(
                              title: 'Release',
                              colors: Colors.green.shade500,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(height: 16),
                            _colorMatchingData(
                              title: 'Zero Rate\t\t\t\t\t',
                              colors: Colors.blue.shade500,
                            ),
                            const SizedBox(height: 6),
                            _colorMatchingData(
                              title: 'Part Release',
                              colors: Colors.orange.shade500,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(height: 16),
                            _colorMatchingData(
                              title: 'Processing',
                              colors: Colors.yellow.shade500,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            _buildStitchingEstimateTable(data: stitchingData),
          ],
        ),
      ),
    );
  }

  Row _colorMatchingData({
    required String title,
    required Color colors,
  }) {
    return Row(
      children: [
        Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: colors,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStitchingEstimateTable({
    required List<TableData> data,
  }) {
    final columns = ['Order', 'Round', 'Date', 'PO No.', 'Customer', 'Address'];

    final kWidth = MediaQuery.of(context).size.width;

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
          border: TableBorder.all(color: Colors.black),
          defaultColumnWidth: FixedColumnWidth(kWidth / 2),
          columnWidths: const {
            0: FixedColumnWidth(180),
            1: FixedColumnWidth(180),
            2: FixedColumnWidth(180),
            3: FixedColumnWidth(150),
            4: FixedColumnWidth(160),
            5: FixedColumnWidth(400),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(
                color: Colors.grey,
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
                  color: Colors.white,
                ),
                children: [
                  for (var i = 0; i < columns.length; i++)
                    TableRowInkWell(
                      onTap: () => navigateToDetail(item, index),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: i == 0
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: () {
                                  navigateToDetail(item, index);
                                },
                                child: Text(
                                  item.round,
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : Text(
                                i == 1
                                    ? item.round
                                    : i == 2
                                        ? item.date
                                        : i == 3
                                            ? item.poNo
                                            : i == 4
                                                ? item.customerName
                                                : item.address,
                                style: const TextStyle(color: Colors.black),
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
