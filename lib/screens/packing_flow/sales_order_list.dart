import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:williams/services/api_services.dart';

import '../../common/custom_overlay_loading.dart';
import '../../custom_widgets/custom_alert_box.dart';
import '../../custom_widgets/custom_exit_confirmation.dart';
import '../../custom_widgets/custom_logout_button.dart';
import '../../custom_widgets/custom_scaffold.dart';
import '../../custom_widgets/custom_spinning_logo.dart';
import '../../custom_widgets/util_class.dart';
import '../../models/round_type_model.dart';
import '../../models/sales_order_item_list_model.dart';
import '../../models/sales_order_list_model.dart';
import '../../models/uom_list_model.dart';
import 'order_item_view.dart';

class SalesOrderList extends StatefulWidget {
  const SalesOrderList({super.key});

  @override
  State<SalesOrderList> createState() => _SalesOrderListState();
}

class _SalesOrderListState extends State<SalesOrderList> {
  DateTime startDate = DateTime.now();
  bool isLoading = true;
  DateTime endDate = DateTime.now();
  ApiServices apiServices = ApiServices();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController roundController = TextEditingController();

  late List<RoundTypeModel> roundTypeList;
  RoundTypeModel? selectedRound;

  @override
  void initState() {
    super.initState();
    startDateController.text = _formatDate(DateTime.now());
    endDateController.text = _formatDate(DateTime.now().add(Duration(days: 1)));
    _fnLoadRound();
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dte) {
    DateFormat date = DateFormat('dd/MMM/yyyy');
    return date.format(dte);
  }

  Future _fnLoadRound() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      roundTypeList = await apiServices.fnGetRoundList(prmCompanyId: prmCmpId);
      roundTypeList.insert(
        0,
        RoundTypeModel(
          round: '',
        ),
      );
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Exception on _fnLoadRound $e");
      roundTypeList = [];
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<SalesOrderListModel>> getSalesOrderList({
    required String prmFrmDate,
    required String prmToDate,
    required String prmRound,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      String prmBrId = prefs.getString('brId')!;
      String prmFaId = prefs.getString('faId')!;
      String prmUId = prefs.getString('userId')!;
      final response = await ApiServices().getSalesOrderList(
        prmFrmDate: prmFrmDate,
        prmToDate: prmToDate,
        prmRound: prmRound,
        prmCmpId: prmCmpId,
        prmBrId: prmBrId,
        prmFaId: prmFaId,
        prmUId: prmUId,
      );
      if (response.isNotEmpty) {
        return response;
      } else {
        throw ('No Sales Order Found');
      }
    } catch (e) {
      throw ('No Sales Order Found');
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'start_date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.now(),
          firstDate: DateTime(2021),
          lastDate: DateTime.now(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        startDateController.text = _formatDate(picked);
        endDate = DateTime.now();
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'end_date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: endDate,
          firstDate: startDate,
          lastDate: (DateTime.now().add(Duration(days: 1))),
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

  Color getTableColor(SalesOrderListModel item) {
    if (int.parse(item.isZeroRate) > 1) {
      return Colors.blue;
    } else if (item.isHold == 'True') {
      return Colors.red;
    } else if (item.isRelease == 'True') {
      return Colors.green;
    } else if (item.isPrtalRelze == 'True') {
      return Colors.orange;
    } else {
      return Colors.black;
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
        child: isLoading
            ? Center(child: CustomLogoSpinner())
            : Padding(
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
                            'Orders',
                            style: TextStyle(
                              fontSize: 35.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 4,
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
                            flex: 4,
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
                            child: DropdownButtonFormField<RoundTypeModel>(
                              decoration: const InputDecoration(
                                labelText: 'Round',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 16),
                              ),
                              value: selectedRound,
                              items: roundTypeList
                                  .map(
                                    (RoundTypeModel round) => DropdownMenuItem(
                                      value: round,
                                      child: Text(
                                        round.round == ''
                                            ? 'All Rounds'
                                            : round.round,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (RoundTypeModel? value) {
                                selectedRound = value;
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.black,
                              size: 40,
                            ),
                            onPressed: () {
                              setState(() {});
                            },
                          ),
                          const SizedBox(width: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  _colorMatchingData(
                                    title: 'Hold',
                                    colors: Colors.red.shade500,
                                  ),
                                  const SizedBox(height: 6),
                                  _colorMatchingData(
                                    title: 'Release   ',
                                    colors: Colors.green.shade500,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  _colorMatchingData(
                                    title: 'Zero Rate',
                                    colors: Colors.blue.shade500,
                                  ),
                                  const SizedBox(height: 6),
                                  _colorMatchingData(
                                    title: 'Part Release ',
                                    colors: Colors.orange.shade500,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  _colorMatchingData(
                                    title: 'Processing',
                                    colors: Colors.black,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.black,
                              size: 30,
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
                      FutureBuilder<List<dynamic>>(
                        future: Future.wait([
                          getSalesOrderList(
                            prmFrmDate: startDateController.text,
                            prmToDate: endDateController.text,
                            prmRound: selectedRound?.round ?? '',
                          ),
                        ]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CustomLogoSpinner(
                              color: Colors.black,
                            );
                          } else if (snapshot.hasError) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height / 1.5,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      snapshot.error.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ]),
                            );
                          } else {
                            return _buildSalesOrderTable(
                                orderList: snapshot.data![0]);
                          }
                        },
                      )
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
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
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
    required List<SalesOrderListModel> orderList,
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
    Future<void> navigateToDetail({
      required String prmOrderId,
    }) async {
      try {
        showDialog(
          barrierColor: Colors.black.withValues(alpha: 0.8),
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return const CustomOverlayLoading();
          },
        );
        final List<UomAndPackListModel> packingType =
            await ApiServices().getPackingType(prmCompanyId: '1');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String prmCmpId = prefs.getString('cmpId')!;
        String prmBrId = prefs.getString('brId')!;
        String prmFaId = prefs.getString('faId')!;
        String prmUId = prefs.getString('userId')!;
        List<SalesOrderItemListModel> orderListItems =
            await ApiServices().getSalesOrderItemList(
          prmOrderId: orderList
              .where((element) => element.id == prmOrderId)
              .toList()[0]
              .id,
          prmCmpId: prmCmpId,
          prmBrId: prmBrId,
          prmFaId: prmFaId,
          prmUId: prmUId,
        );

        if (orderListItems.isEmpty) {
          log('No items found');

          Navigator.pop(context);
          Util.customErrorSnackBar(context, 'No items found');
          return;
        }

        if (!mounted) return;
        Navigator.pop(context);
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => OrderItemView(
              packTypeList: packingType,
              passedOnOrderListItems: orderListItems,
              selectedSalesOrderList: orderList
                  .where((element) => element.id == prmOrderId)
                  .toList()[0],
            ),
          ),
        ).whenComplete(() {
          setState(() {});
        });
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        showDialog(
          barrierColor: Colors.black.withValues(alpha: 0.8),
          context: context,
          builder: (context) => const CustomErrorAlert(
            content: 'Something went wrong',
          ),
        );
      }
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
              rows: orderList.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                DateTime orderDate =
                    DateFormat("M/d/yyyy h:mm:ss a").parse(item.trDate);
                DateTime deliveryDate =
                    DateFormat("M/d/yyyy h:mm:ss a").parse(item.optDate);
                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    return index.isEven
                        ? Colors.purple.shade50
                        : Colors.purple.shade100;
                  }),
                  cells: [
                    DataCell(
                      onTap: () => navigateToDetail(
                        prmOrderId: item.id,
                      ),
                      Text(
                        item.refNo,
                        style: TextStyle(
                          color: getTableColor(item),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      onTap: () => navigateToDetail(
                        prmOrderId: item.id,
                      ),
                      Text(
                        item.regNo,
                        style: TextStyle(
                          color: getTableColor(item),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      onTap: () => navigateToDetail(
                        prmOrderId: item.id,
                      ),
                      Text(
                        item.trDate == ''
                            ? ''
                            : DateFormat('dd/MMM/yyyy hh:mm: a')
                                .format(orderDate),
                        style: TextStyle(
                          color: getTableColor(item),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      onTap: () => navigateToDetail(
                        prmOrderId: item.id,
                      ),
                      Text(
                        item.optRefNo,
                        style: TextStyle(
                          color: getTableColor(item),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      onTap: () => navigateToDetail(
                        prmOrderId: item.id,
                      ),
                      Text(
                        item.optDate == ''
                            ? ''
                            : DateFormat('dd/MMM/yyyy').format(deliveryDate),
                        style: TextStyle(
                          color: getTableColor(item),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      onTap: () => navigateToDetail(
                        prmOrderId: item.id,
                      ),
                      Text(
                        item.accountCr,
                        style: TextStyle(
                          color: getTableColor(item),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      onTap: () => navigateToDetail(
                        prmOrderId: item.id,
                      ),
                      Text(
                        item.address,
                        style: TextStyle(
                          color: getTableColor(item),
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
