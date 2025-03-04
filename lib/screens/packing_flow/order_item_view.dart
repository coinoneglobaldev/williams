import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/custom_overlay_loading.dart';
import '../../custom_widgets/custom_scaffold.dart';
import '../../custom_widgets/util_class.dart';
import '../../models/delivery_save_model.dart';
import '../../models/sales_order_item_list_model.dart';
import '../../models/sales_order_list_model.dart';
import '../../models/uom_list_model.dart';
import '../../services/api_services.dart';

class OrderItemView extends StatefulWidget {
  final SalesOrderListModel selectedSalesOrderList;
  final List<SalesOrderItemListModel> passedOnOrderListItems;
  final List<UomAndPackListModel> packTypeList;

  const OrderItemView({
    super.key,
    required this.packTypeList,
    required this.passedOnOrderListItems,
    required this.selectedSalesOrderList,
  });

  @override
  State<OrderItemView> createState() => _OrderItemViewState();
}

class _OrderItemViewState extends State<OrderItemView> {
  final FocusNode _orderQtyFocus = FocusNode();
  final FocusNode _shortFocus = FocusNode();
  bool isShortMode = false;
  late List<TextEditingController> notesControllers;
  final TextEditingController _qtyControllers = TextEditingController();
  final TextEditingController _itemDetailsController = TextEditingController();
  final TextEditingController _shortController = TextEditingController();
  int selectedRowIndex = 0;
  int selectedCheck = 0;
  late List<SalesOrderItemListModel> orderListItems;
  late SalesOrderItemListModel selectedOrderItem;
  List<UomAndPackListModel> selectedPackList = [];

  @override
  void initState() {
    super.initState();
    orderListItems = [];
    List<SalesOrderItemListModel> _orderTempListItems =
        widget.passedOnOrderListItems;

    List<int> _filteredItemGroupId = _orderTempListItems
        .map((e) => int.parse(e.itemGroupId))
        .toSet()
        .toList();
    _filteredItemGroupId.sort((a, b) => a.compareTo(b));

    List<String> _filteredItemGroupIdString =
        _filteredItemGroupId.map((e) => e.toString()).toSet().toList();

    for (int i = 0; i < _filteredItemGroupIdString.length; i++) {
      for (int j = 0; j < _orderTempListItems.length; j++) {
        if (_filteredItemGroupIdString[i] ==
            _orderTempListItems[j].itemGroupId) {
          orderListItems.add(_orderTempListItems[j]);
        }
      }
    }

    _fnSetSelectedItem(selectedRowItem: orderListItems[0]);
    selectedPackList = List<UomAndPackListModel>.filled(
        orderListItems.length, widget.packTypeList[0]);
    for (int i = 0; i < orderListItems.length; i++) {
      try {
        selectedPackList[i] = widget.packTypeList.where((element) {
          return element.id == orderListItems[i].packId;
        }).first;
      } catch (e) {
        selectedPackList[i] = widget.packTypeList[0];
      }
    }
    notesControllers = orderListItems
        .map((item) => TextEditingController(text: item.remarks))
        .toList();
  }

  void _fnSwitchToQtyMode() {
    setState(() {
      isShortMode = false;
    });
  }

  void _fnSwitchToShortMode() {
    setState(() {
      isShortMode = true;
    });
  }

  void textSelection(TextEditingController controller) {
    setState(() {
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      );
    });
  }

  Widget _buildOrderItemTable({
    required List<SalesOrderItemListModel> data,
  }) {
    final columns = [
      'Qty',
      'Unit \n/Box',
      'Pack',
      'Code',
      'Description',
      'Notes',
      'Check',
      'Done',
      'Short'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 500,
              height: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.selectedSalesOrderList.accountCr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(130, 35),
              ),
              onPressed: null,
              // onPressed: orderListItems.any((element) => element.short != "")
              //     ? null
              //     : () {
              //         _selectAllSavePackingItem(
              //           isSelectAll: orderListItems
              //                   .any((element) => element.isRelease == "False")
              //               ? "1"
              //               : "-1",
              //         );
              //       },
              child: Text(
                orderListItems.any((element) => element.isRelease == "False")
                    ? "Select All"
                    : "Deselect All",
              ),
            ),
            const SizedBox(
              width: 135,
            ),
          ],
        ),
        Expanded(
          child: Container(
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
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  child: DataTable(
                    border: TableBorder.symmetric(
                        inside: BorderSide(
                      color: Colors.black,
                    )),
                    columnSpacing: 5,
                    horizontalMargin: 2,
                    dataRowMaxHeight: 80,
                    dataRowMinHeight: 80,
                    headingRowColor:
                        WidgetStateProperty.all(Colors.grey.shade400),
                    columns: columns
                        .map((column) => DataColumn(
                              headingRowAlignment: MainAxisAlignment.center,
                              label: Center(
                                child: Text(
                                  column,
                                  style: const TextStyle(
                                    fontSize: 16,
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
                        SalesOrderItemListModel rowItem = entry.value;
                        return DataRow(
                          color: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              final int index1 =
                                  states.contains(WidgetState.selected)
                                      ? states.contains(WidgetState.selected)
                                          ? data.indexOf(data[selectedRowIndex])
                                          : -1
                                      : -1;
                              return index1 == selectedRowIndex
                                  ? Colors.blue.withValues(alpha: 0.6)
                                  : selectedPackList[index].id == '19'
                                      ? Colors.yellow
                                      : Colors.green.shade200;
                            },
                          ),
                          selected: rowItem == selectedOrderItem,
                          cells: [
                            DataCell(
                              onTap: () {
                                _orderQtyFocus.requestFocus();
                                selectedRowIndex = index;
                                _fnSwitchToQtyMode();
                                _fnSetSelectedItem(
                                  selectedRowItem: rowItem,
                                );
                                textSelection(_qtyControllers);
                              },
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  height: 70,
                                  decoration: BoxDecoration(
                                      color: selectedPackList[index].id == '19'
                                          ? Colors.yellow
                                          : Colors.green.shade200,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.3),
                                          blurRadius: 15,
                                        ),
                                      ]),
                                  child: Center(
                                    child: Text(
                                      rowItem.qty,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              onTap: () {
                                setState(() {
                                  selectedRowIndex = index;
                                });
                                _fnSwitchToQtyMode();
                                _fnSetSelectedItem(
                                  selectedRowItem: rowItem,
                                );
                              },
                              Center(
                                child: Text(
                                  double.parse(rowItem.conVal)
                                      .toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ),
                            DataCell(
                              IgnorePointer(
                                child: SizedBox(
                                  width: 130,
                                  child: Center(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton(
                                        borderRadius: BorderRadius.circular(10),
                                        isDense: true,
                                        dropdownColor: Colors.white,
                                        items: widget.packTypeList
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e.name),
                                              ),
                                            )
                                            .toList(),
                                        icon: SizedBox(),
                                        value: selectedPackList[index],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedPackList[index] = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              onTap: () {
                                setState(() {
                                  selectedRowIndex = index;
                                });
                                _fnSwitchToQtyMode();
                                _fnSetSelectedItem(
                                  selectedRowItem: rowItem,
                                );
                              },
                              Center(
                                child: Text(
                                  rowItem.itemCode,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ),
                            DataCell(
                              onTap: () {
                                setState(() {
                                  selectedRowIndex = index;
                                });
                                _fnSwitchToQtyMode();
                                _fnSetSelectedItem(
                                  selectedRowItem: rowItem,
                                );
                              },
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: selectedPackList[index].id == '19'
                                        ? Colors.yellow
                                        : Colors.green.shade200,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      rowItem.itemName,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                height: 70,
                                color: Colors.white,
                                child: Center(
                                  child: TextField(
                                    controller: notesControllers[index],
                                    style: const TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Enter value',
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade500),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        notesControllers[index].text = value;
                                      });
                                      _fnSetSelectedItem(
                                        selectedRowItem: rowItem,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              onTap: () {
                                setState(() {
                                  selectedRowIndex = index;
                                });
                                _fnSetSelectedItem(
                                  selectedRowItem: rowItem,
                                );
                                selectedCheck = index;
                              },
                              Center(
                                child: Transform.scale(
                                  scale: 2.5,
                                  child: Checkbox(
                                    activeColor: Colors.black,
                                    checkColor: Colors.black,
                                    fillColor:
                                        WidgetStateProperty.all(Colors.white),
                                    value: rowItem.isRelease == 'False'
                                        ? rowItem.isChecked
                                        : true,
                                    side: BorderSide(
                                        color: Colors.black, width: 1),
                                    onChanged: (bool? value) {
                                      rowItem.isChecked = value ?? false;
                                      _fnSetSelectedItem(
                                        selectedRowItem: rowItem,
                                      );
                                      setState(() {
                                        selectedRowIndex = index;
                                      });
                                      _fnSetSelectedItem(
                                        selectedRowItem: rowItem,
                                      );
                                      selectedCheck = index;
                                      _fnSave(
                                        prmIsRlz: rowItem.isRelease == 'False'
                                            ? '1'
                                            : '0',
                                        autoId: rowItem.autoId,
                                        quantity: rowItem.qty,
                                        shorts: rowItem.short,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: rowItem.isRelease == 'True'
                                        ? Colors.green
                                        : Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    minimumSize: const Size(80, 70),
                                  ),
                                  child: const Text(
                                    'Done',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedRowIndex = index;
                                    });
                                    _fnSwitchToQtyMode();
                                    _fnSetSelectedItem(
                                      selectedRowItem: rowItem,
                                    );
                                    _fnSave(
                                      prmIsRlz: rowItem.isRelease == 'False'
                                          ? '1'
                                          : '0',
                                      autoId: rowItem.autoId,
                                      quantity: rowItem.qty,
                                      shorts: rowItem.short,
                                    );
                                  },
                                ),
                              ),
                            ),
                            DataCell(
                              onTap: () {
                                setState(() {
                                  selectedRowIndex = index;
                                });
                                _shortFocus.requestFocus();
                              },
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (rowItem.short == '' &&
                                                rowItem.isRelease == 'False') ||
                                            (rowItem.short == '' &&
                                                rowItem.isRelease == 'True')
                                        ? Colors.grey
                                        : (rowItem.short != '' &&
                                                rowItem.isRelease == 'False')
                                            ? Colors.red
                                            : Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    minimumSize: const Size(80, 70),
                                  ),
                                  child: Text(
                                    rowItem.short == ''
                                        ? 'Short'
                                        : rowItem.short,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: rowItem.short == '' ||
                                              rowItem.short == '0'
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedRowIndex = index;
                                      _fnSwitchToShortMode();
                                      _fnSetSelectedItem(
                                        selectedRowItem: rowItem,
                                      );
                                      textSelection(_shortController);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenCustomScaffold(
      resizeToAvoidBottomInset: false,
      bodyWidget: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 12,
            child: _buildOrderItemTable(
              data: orderListItems,
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.only(
                left: 10,
                top: 50,
                bottom: 10,
              ),
              padding: const EdgeInsets.all(10),
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                border: Border.all(color: Colors.black),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _calculatorContainer(
                                  value: '1',
                                ),
                              ),
                              Expanded(
                                child: _calculatorContainer(
                                  value: '2',
                                ),
                              ),
                              Expanded(
                                child: _calculatorContainer(
                                  value: '3',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _calculatorContainer(
                                  value: '4',
                                ),
                              ),
                              Expanded(
                                child: _calculatorContainer(
                                  value: '5',
                                ),
                              ),
                              Expanded(
                                child: _calculatorContainer(
                                  value: '6',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _calculatorContainer(
                                  value: '7',
                                ),
                              ),
                              Expanded(
                                child: _calculatorContainer(
                                  value: '8',
                                ),
                              ),
                              Expanded(
                                child: _calculatorContainer(
                                  value: '9',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _calculatorContainer(
                                  value: '.',
                                ),
                              ),
                              Expanded(
                                child: _calculatorContainer(
                                  value: '0',
                                ),
                              ),
                              Expanded(
                                child: _calculatorContainer(
                                  value: 'C',
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _itemTextFields(
                          title: 'Item Details',
                          controller: _itemDetailsController,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _itemTextFields(
                            title: 'Quantity',
                            controller: _qtyControllers,
                            focusNode: _orderQtyFocus,
                            onTab: () {
                              _fnSwitchToQtyMode();
                              textSelection(_qtyControllers);
                            },
                            fillColor: Colors.white),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: _itemTextFields(
                          title: 'Shorts',
                          controller: _shortController,
                          color: selectedOrderItem.short == ''
                              ? Colors.black
                              : Colors.white,
                          fillColor: selectedOrderItem.short == '' ||
                                  selectedOrderItem.short == '0'
                              ? Colors.grey
                              : Colors.red,
                          focusNode: _shortFocus,
                          onTab: () {
                            _fnSwitchToShortMode();
                            textSelection(_shortController);
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              minimumSize: const Size(100, 50),
                            ),
                            child: const Text('BACK'),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              if (double.parse(_qtyControllers.text) <
                                  double.parse(selectedOrderItem.ordQty)) {
                                _showQuantityWarning();
                              } else {
                                _fnSave(
                                    prmIsRlz: selectedOrderItem.isRelease ==
                                                'False' &&
                                            _shortController.text == ''
                                        ? '1'
                                        : '0',
                                    autoId: selectedOrderItem.autoId,
                                    quantity: _qtyControllers.text,
                                    shorts: _shortController.text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(100, 50),
                            ),
                            child: const Text('SAVE'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _fnSave({
    required String prmIsRlz,
    required String autoId,
    required String quantity,
    required String shorts,
  }) async {
    try {
      FocusScope.of(context).unfocus();
      showDialog(
        barrierColor: Colors.black.withValues(alpha: 0.8),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const CustomOverlayLoading();
        },
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      String prmBrId = prefs.getString('brId')!;
      String prmFaId = prefs.getString('faId')!;
      String prmUId = prefs.getString('userId')!;
      await ApiServices()
          .fnSavePackingItem(
        prmBrId: prmBrId,
        prmCmpId: prmCmpId,
        prmFaId: prmFaId,
        prmUID: prmUId,
        prmAutoID: autoId,
        orderId: widget.selectedSalesOrderList.id,
        prmShort: shorts == '' || shorts == '0' ? '' : shorts,
        prmQty: _qtyControllers.text,
        prmIsRlz: prmIsRlz,
      )
          .then((value) async {
        if (value.errorCode == 0) {
          await ApiServices()
              .selectAllSavePackingItem(
            prmOrderId: widget.selectedSalesOrderList.id,
            prmCmpId: prmCmpId,
            prmBrId: prmBrId,
            prmFaId: prmFaId,
            prmUId: prmUId,
            isSelectAll: "0",
          )
              .then((value) {
            if (value.errorCode == 0) {
              _fnGetOrderList().whenComplete(() {
                Navigator.pop(context);
              });
            } else {
              throw Exception(value.message);
            }
            return value;
          });
        } else {
          throw Exception(value.message);
        }
        return value;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      Navigator.pop(context);
      Util.customErrorSnackBar(context, 'Unable to save data');
    }
  }

  Future<void> _selectAllSavePackingItem({required String isSelectAll}) async {
    try {
      FocusScope.of(context).unfocus();
      showDialog(
        barrierColor: Colors.black.withValues(alpha: 0.8),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const CustomOverlayLoading();
        },
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      String prmBrId = prefs.getString('brId')!;
      String prmFaId = prefs.getString('faId')!;
      String prmUId = prefs.getString('userId')!;
      CommonResponseModel response =
          await ApiServices().selectAllSavePackingItem(
        prmOrderId: widget.selectedSalesOrderList.id,
        prmCmpId: prmCmpId,
        prmBrId: prmBrId,
        prmFaId: prmFaId,
        prmUId: prmUId,
        isSelectAll: isSelectAll,
      );
      if (response.errorCode == 0) {
        _fnGetOrderList().whenComplete(() {
          _fnClearTextFields();
          Navigator.pop(context);
        });
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      Navigator.pop(context);
      Util.customErrorSnackBar(context, 'Unable to save data');
    }
  }

  Future<void> _fnGetOrderList() async {
    try {
      String currentSelectedAutoId = '';
      if (orderListItems.isNotEmpty &&
          selectedRowIndex < orderListItems.length) {
        currentSelectedAutoId = orderListItems[selectedRowIndex].autoId;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      String prmBrId = prefs.getString('brId')!;
      String prmFaId = prefs.getString('faId')!;
      String prmUId = prefs.getString('userId')!;

      orderListItems.clear();

      List<SalesOrderItemListModel> _orderTempListItems =
          await ApiServices().getSalesOrderItemList(
        prmOrderId: widget.selectedSalesOrderList.id,
        prmCmpId: prmCmpId,
        prmBrId: prmBrId,
        prmFaId: prmFaId,
        prmUId: prmUId,
      );
      if (_orderTempListItems.isEmpty) {
        log('No items found');

        Navigator.pop(context);
        Util.customErrorSnackBar(context, 'No items found');
        return;
      }
      List<int> _filteredItemGroupId = _orderTempListItems
          .map((e) => int.parse(e.itemGroupId))
          .toSet()
          .toList();
      _filteredItemGroupId.sort((a, b) => a.compareTo(b));

      // Convert back to string format
      List<String> _filteredItemGroupIdString =
          _filteredItemGroupId.map((e) => e.toString()).toSet().toList();

      // Reorder items based on sorted group IDs
      for (int i = 0; i < _filteredItemGroupIdString.length; i++) {
        for (int j = 0; j < _orderTempListItems.length; j++) {
          if (_filteredItemGroupIdString[i] ==
              _orderTempListItems[j].itemGroupId) {
            orderListItems.add(_orderTempListItems[j]);
          }
        }
      }

      setState(() {
        if (currentSelectedAutoId.isNotEmpty) {
          int newIndex = orderListItems
              .indexWhere((item) => item.autoId == currentSelectedAutoId);
          if (newIndex != -1) {
            selectedRowIndex = newIndex;
            log(_orderTempListItems.length != newIndex
                ? (newIndex + 1).toString()
                : newIndex.toString());
            _fnSetSelectedItem(
                selectedRowItem: orderListItems[
                    _orderTempListItems.length - 1 > newIndex
                        ? newIndex + 1
                        : newIndex]);
          } else {
            // If the previously selected item is not found, select the first item
            selectedRowIndex = 0;
            if (orderListItems.isNotEmpty) {
              _fnSetSelectedItem(selectedRowItem: orderListItems[0]);
            }
          }
        } else if (orderListItems.isNotEmpty) {
          selectedRowIndex = 0;
          _fnSetSelectedItem(selectedRowItem: orderListItems[0]);
        }
        selectedPackList = List<UomAndPackListModel>.filled(
            orderListItems.length, widget.packTypeList[0]);

        for (int i = 0; i < orderListItems.length; i++) {
          try {
            selectedPackList[i] = widget.packTypeList.where((element) {
              return element.id == orderListItems[i].packId;
            }).first;
          } catch (e) {
            selectedPackList[i] = widget.packTypeList[0];
          }
        }

        notesControllers = orderListItems
            .map((item) => TextEditingController(text: item.remarks))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      Util.customErrorSnackBar(context, 'Unable to fetch data');
    }
  }

  Widget _itemTextFields({
    required String title,
    required Color fillColor,
    required TextEditingController controller,
    Color color = Colors.black,
    GestureTapCallback? onTab,
    FocusNode? focusNode,
  }) {
    return Column(
      children: [
        TextFormField(
          readOnly: true,
          enableIMEPersonalizedLearning: true,
          controller: controller,
          onTap: onTab,
          focusNode: focusNode,
          style: TextStyle(color: color, fontSize: 20),
          decoration: InputDecoration(
            fillColor: fillColor,
            filled: true,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            label: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  GestureDetector _calculatorContainer({
    required String value,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          final controller = isShortMode ? _shortController : _qtyControllers;
          if (value == 'C') {
            final currentText = controller.text;
            if (currentText.isNotEmpty) {
              controller.text =
                  currentText.substring(0, currentText.length - 1);
            }
          } else if (value == '.') {
            final currentText = controller.text;
            if (!currentText.contains('.')) {
              controller.text = currentText + value;
            }
          } else {
            if (controller.selection.baseOffset ==
                controller.selection.extentOffset) {
              controller.text = controller.text + value;
            } else {
              controller.text = value;
            }
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.blue.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // use it to show if qty lesser than selected qty is typed
  void _showQuantityWarning() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invalid Quantity'),
          content: Text(
              'Please enter a number greater than ${selectedOrderItem.ordQty}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _fnSetSelectedItem({
    required SalesOrderItemListModel selectedRowItem,
  }) {
    if (selectedRowItem == orderListItems.last) {
      setState(() {
        selectedOrderItem = orderListItems.last;
        _itemDetailsController.text =
            '${selectedOrderItem.itemName}, ${selectedOrderItem.printUom}';
        _qtyControllers.text = selectedOrderItem.qty;
        _shortController.text = selectedOrderItem.short;
      });
    } else {
      setState(() {
        selectedOrderItem = selectedRowItem;
        _itemDetailsController.text =
            '${selectedOrderItem.itemName}, ${selectedOrderItem.printUom}';
        _qtyControllers.text = selectedOrderItem.qty;
        _shortController.text = selectedOrderItem.short;
      });
    }
  }

  void _fnClearTextFields() {
    setState(() {
      _qtyControllers.clear();
      _shortController.clear();
      _itemDetailsController.clear();
    });
  }

  @override
  void dispose() {
    for (var controller in notesControllers) {
      controller.dispose();
    }
    _qtyControllers.dispose();
    _shortController.dispose();
    _itemDetailsController.dispose();
    super.dispose();
  }
}
