import 'package:flutter/material.dart';
import '../../custom_widgets/custom_scaffold.dart';

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
    TableData(itemName: "Shirt", rate: "250.00", qty: "2"),
    TableData(itemName: "Pants", rate: "350.00", qty: "3"),
    TableData(itemName: "Dress", rate: "500.00", qty: "1"),
    TableData(itemName: "Blouse", rate: "300.00", qty: "2"),
  ];

  double calculateTotal(List<TableData> data) {
    return data.fold(0, (sum, item) => sum + item.total);
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
      title: 'Packing',
      bodyWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 10),
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
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      controller: endDateController,
                      onTap: _selectEndDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          if (startDate != null && endDate != null) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Duration: ${endDate!.difference(startDate!).inDays + 1} days',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
          _buildStitchingEstimateTable(data: stitchingData),
        ],
      ),
    );
  }

  Widget _buildStitchingEstimateTable({
    required List<TableData> data,
  }) {
    final columns = ['No', 'Name', 'Rate', 'Qty', 'Total'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stitching Estimate Details',
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8.0),
        ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
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
                        Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          item.itemName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          "₹ ${double.parse(item.rate).toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          double.parse(item.qty).toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          "₹ ${item.total.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.end,
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
}

class TableData {
  final String itemName;
  final String rate;
  final String qty;

  TableData({
    required this.itemName,
    required this.rate,
    required this.qty,
  });

  double get total => double.parse(rate) * double.parse(qty);
}
