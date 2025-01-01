import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:williams/services/api_services.dart';
import '../../custom_widgets/custom_exit_confirmation.dart';
import '../../custom_widgets/custom_logout_button.dart';
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
  ApiServices apiServices = ApiServices();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController roundController = TextEditingController();
  final List<TableData> salesOrderData = [
    TableData(
      order: '01',
      round: "Round 1",
      orderDate: "10-Mar-2024",
      poNo: "5665",
      deliveryDate: "15-Mar-2024",
      customerName: "Raj Industries",
      address: "123 Main Street, Mumbai, Maharashtra",
    ),
    TableData(
      order: '02',
      round: "Round 2",
      orderDate: "20-Apr-2024",
      poNo: "5666",
      deliveryDate: "25-Apr-2024",
      customerName: "Kumar Enterprises",
      address: "456 Park Avenue, Delhi, New Delhi",
    ),
    TableData(
      order: '03',
      round: "Round 3",
      orderDate: "30-May-2024",
      poNo: "5667",
      deliveryDate: "05-Jun-2024",
      customerName: "Raj Industries",
      address: "789 Main Street, Mumbai, Maharashtra",
    ),
    TableData(
      order: '04',
      round: "Round 1",
      orderDate: "10-Mar-2024",
      poNo: "5665",
      deliveryDate: "15-Mar-2024",
      customerName: "Raj Industries",
      address: "123 Main Street, Mumbai, Maharashtra",
    ),
    TableData(
      order: '05',
      round: "Round 2",
      orderDate: "20-Apr-2024",
      poNo: "5666",
      deliveryDate: "25-Apr-2024",
      customerName: "Kumar Enterprises",
      address: "456 Park Avenue, Delhi, New Delhi",
    ),
    TableData(
      order: '05',
      round: "Round 2",
      orderDate: "20-Apr-2024",
      poNo: "5666",
      deliveryDate: "25-Apr-2024",
      customerName: "Kumar Enterprises",
      address: "456 Park Avenue, Delhi, New Delhi",
    ),
    TableData(
      order: '05',
      round: "Round 2",
      orderDate: "20-Apr-2024",
      poNo: "5666",
      deliveryDate: "25-Apr-2024",
      customerName: "Kumar Enterprises",
      address: "456 Park Avenue, Delhi, New Delhi",
    ),
    TableData(
      order: '05',
      round: "Round 2",
      orderDate: "20-Apr-2024",
      poNo: "5666",
      deliveryDate: "25-Apr-2024",
      customerName: "Kumar Enterprises",
      address: "456 Park Avenue, Delhi, New Delhi",
    ),
    TableData(
      order: '05',
      round: "Round 2",
      orderDate: "20-Apr-2024",
      poNo: "5666",
      deliveryDate: "25-Apr-2024",
      customerName: "Kumar Enterprises",
      address: "456 Park Avenue, Delhi, New Delhi",
    ),
    TableData(
      order: '05',
      round: "Round 2",
      orderDate: "20-Apr-2024",
      poNo: "5666",
      deliveryDate: "25-Apr-2024",
      customerName: "Kumar Enterprises",
      address: "456 Park Avenue, Delhi, New Delhi",
    ),
    TableData(
      order: '05',
      round: "Round 2",
      orderDate: "20-Apr-2024",
      poNo: "5666",
      deliveryDate: "25-Apr-2024",
      customerName: "Kumar Enterprises",
      address: "456 Park Avenue, Delhi, New Delhi",
    ),
    TableData(
      order: '05',
      round: "Round 2",
      orderDate: "20-Apr-2024",
      poNo: "5666",
      deliveryDate: "25-Apr-2024",
      customerName: "Kumar Enterprises",
      address: "456 Park Avenue, Delhi, New Delhi",
    ),
    TableData(
      order: '05',
      round: "Round 2",
      orderDate: "20-Apr-2024",
      poNo: "5666",
      deliveryDate: "25-Apr-2024",
      customerName: "Kumar Enterprises",
      address: "456 Park Avenue, Delhi, New Delhi",
    ),
    TableData(
      order: '05',
      round: "Round 2",
      orderDate: "20-Apr-2024",
      poNo: "5666",
      deliveryDate: "25-Apr-2024",
      customerName: "Kumar Enterprises",
      address: "456 Park Avenue, Delhi, New Delhi",
    ),
    TableData(
      order: '05',
      round: "Round 2",
      orderDate: "20-Apr-2024",
      poNo: "5666",
      deliveryDate: "25-Apr-2024",
      customerName: "Kumar Enterprises",
      address: "456 Park Avenue, Delhi, New Delhi",
    ),
  ];
  List<String> rounds = ['All Rounds', 'Round 1', 'Round 2', 'Round 3'];
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
      bodyWidget: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) {
            return;
          }
          showDialog(
            barrierColor: Colors.black.withValues(alpha: 0.8),
            context: context,
            builder: (context) => const ScreenCustomExitConfirmation(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sales Order',
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.calendar_today),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          label: Text('Start Date'),
                        ),
                        controller: startDateController,
                        onTap: _selectStartDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.calendar_today),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          label: Text('End Date'),
                        ),
                        controller: endDateController,
                        onTap: _selectEndDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Round',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 16),
                        ),
                        value: selectedRound,
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
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(height: 5),
                                _colorMatchingData(
                                  title: 'Hold',
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
                                SizedBox(height: 5),
                                _colorMatchingData(
                                  title: 'Zero Rate',
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
                                SizedBox(height: 5),
                                _colorMatchingData(
                                  title: 'Processing',
                                  colors: Colors.black,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              const CustomLogoutConfirmation(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSalesOrderTable(data: salesOrderData),
              ],
            ),
          ),
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

  Widget _buildSalesOrderTable({
    required List<TableData> data,
  }) {
    final tableHeadings = [
      'Order',
      'Round',
      'Order Date',
      'PO No.',
      'Delivery Date',
      'Customer',
      'Address'
    ];
    void navigateToDetail(TableData item, int index) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => const OrderItemView(),
          settings: const RouteSettings(name: '/home'),
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowMinHeight: 50,
              dataRowMaxHeight: 50,
              horizontalMargin: 30,
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade400),
              border: TableBorder.symmetric(
                inside: const BorderSide(color: Colors.black, width: 1.0),
              ),
              columns: tableHeadings
                  .map(
                    (column) => DataColumn(
                      label: Text(
                        column,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  .toList(),
              rows: data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    return index.isEven
                        ? Colors.purple.shade100
                        : Colors.purple.shade50;
                  }),
                  cells: [
                    DataCell(
                      onTap: () => navigateToDetail(item, index),
                      Text(
                        item.order,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      onTap: () => navigateToDetail(item, index),
                      Text(
                        item.round,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      onTap: () => navigateToDetail(item, index),
                      Text(
                        item.orderDate,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      onTap: () => navigateToDetail(item, index),
                      Text(
                        item.poNo,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      onTap: () => navigateToDetail(item, index),
                      Text(
                        item.deliveryDate,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      onTap: () => navigateToDetail(item, index),
                      Text(
                        item.customerName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      onTap: () => navigateToDetail(item, index),
                      Text(
                        item.address,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              }).toList(),
            )),
      ),
    );
  }
}

class TableData {
  final String order;
  final String round;
  final String orderDate;
  final String poNo;
  final String deliveryDate;
  final String customerName;
  final String address;

  TableData({
    required this.order,
    required this.round,
    required this.orderDate,
    required this.poNo,
    required this.deliveryDate,
    required this.customerName,
    required this.address,
  });
}
