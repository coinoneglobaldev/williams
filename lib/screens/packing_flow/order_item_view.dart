import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:williams/custom_widgets/custom_scaffold.dart';

import '../../common/custom_overlay_loading.dart';
import '../../custom_widgets/custom_alert_box.dart';
import '../../models/sales_order_item_list_model.dart';
import '../../models/sales_order_list_model.dart';
import '../../models/uom_list_model.dart';
import '../../services/api_services.dart';

class OrderItemView extends StatefulWidget {
  final SalesOrderListModel selectedSalesOrderList;
  List<SalesOrderItemListModel> orderListItems;
  final List<UomAndPackListModel> packTypeList;

  OrderItemView({
    super.key,
    required this.packTypeList,
    required this.orderListItems,
    required this.selectedSalesOrderList,
  });

  @override
  State<OrderItemView> createState() => _OrderItemViewState();
}

class _OrderItemViewState extends State<OrderItemView> {
  bool isShortMode = false;
  final TextEditingController _qtyControllers = TextEditingController();
  late List<TextEditingController> notesControllers;
  final TextEditingController _shortController = TextEditingController();
  late List<FocusNode> qtyFocusNodes;
  late List<FocusNode> notesFocusNodes;
  bool isAllSelected = false;
  int selectedRowIndex = 0;
  bool isQtyFocused = true;
  bool isFirstDigitAfterFocus = true;
  late SalesOrderItemListModel selectedOrderItem;
  List<UomAndPackListModel> selectedPackList = [];

  String inputShort = '';

  _fnGetOrderList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      String prmBrId = prefs.getString('brId')!;
      String prmFaId = prefs.getString('faId')!;
      String prmUId = prefs.getString('userId')!;
      widget.orderListItems = await ApiServices()
          .getSalesOrderItemList(
        prmOrderId: widget.selectedSalesOrderList.id,
        prmCmpId: prmCmpId,
        prmBrId: prmBrId,
        prmFaId: prmFaId,
        prmUId: prmUId,
      )
          .whenComplete(() {
        setState(() {});
      });
    } catch (e) {
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

  @override
  void initState() {
    super.initState();
    selectedOrderItem = widget.orderListItems[0];
    selectedPackList = List<UomAndPackListModel>.filled(
        widget.orderListItems.length, widget.packTypeList[0]);
    for (int i = 0; i < widget.orderListItems.length; i++) {
      try {
        selectedPackList[i] = widget.packTypeList.where((element) {
          return element.id == widget.orderListItems[i].packId;
        }).first;
      } catch (e) {
        selectedPackList[i] = widget.packTypeList[0];
      }
    }
    notesControllers = widget.orderListItems
        .map((item) => TextEditingController(text: item.remarks))
        .toList();
    // Then initialize focus nodes
    qtyFocusNodes =
        List.generate(widget.orderListItems.length, (index) => FocusNode());
    notesFocusNodes =
        List.generate(widget.orderListItems.length, (index) => FocusNode());
    for (var i = 0; i < widget.orderListItems.length; i++) {
      qtyFocusNodes[i].addListener(() {
        if (qtyFocusNodes[i].hasFocus) {
          setState(() {
            selectedRowIndex = i;
            isQtyFocused = true;
          });
        }
      });

      notesFocusNodes[i].addListener(() {
        if (notesFocusNodes[i].hasFocus) {
          setState(() {
            selectedRowIndex = i;
            isQtyFocused = false;
          });
        }
      });
    }
  }

  void _selectAll() {
    setState(() {
      isAllSelected = !isAllSelected;
      int i = 0;
      for (var item in widget.orderListItems) {
        item.isChecked = isAllSelected;
        _selectAllItemSave(
            autoId: item.autoId,
            short: i,
            prmIsRlz: item.isRelease == 'False' ? '1' : '0');
        i++;
      }
      _selectAllSavePackingItem();
    });
  }

  void _handleShortButtonClick({
    required int index,
    required SalesOrderItemListModel selectedRowItem,
  }) async {
    setState(() {
      selectedRowIndex = index;
      isShortMode = true;
      isQtyFocused = false;
      // Force keyboard to show for short input
      FocusScope.of(context).requestFocus(FocusNode());
      Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {});
      });
      print('index: $index');
      selectedOrderItem = selectedRowItem;
      _updateFocus();
      notesFocusNodes[index].unfocus();
      qtyFocusNodes[index].unfocus();
    });
  }

  void _fnSwitchToQtyMode() {
    setState(() {
      isShortMode = false;
      isQtyFocused = true;
    });
  }

  void _fnSwitchToShortMode() {
    setState(() {
      isShortMode = true;
      isQtyFocused = false;
      notesFocusNodes[selectedRowIndex].unfocus();
    });
    _updateFocus();
  }

  @override
  void dispose() {
    for (var controller in notesControllers) {
      controller.dispose();
    }
    for (var node in qtyFocusNodes) {
      node.dispose();
    }
    for (var node in notesFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleKeyPress(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveUp();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _moveDown();
    } else if (event.logicalKey == LogicalKeyboardKey.tab) {
      setState(() {
        isQtyFocused = !isQtyFocused;
      });
      _updateFocus();
    }
  }

  void _moveUp() {
    if (selectedRowIndex > 0) {
      setState(() {
        selectedRowIndex--;
      });
      _updateFocus();
    }
  }

  void _moveDown() {
    if (selectedRowIndex < widget.orderListItems.length - 1) {
      setState(() {
        selectedRowIndex++;
      });
      _updateFocus();
    }
  }

  void _updateFocus() {
    if (isQtyFocused) {
      qtyFocusNodes[selectedRowIndex].requestFocus();
      isFirstDigitAfterFocus = true; // Reset the flag when focus changes
    } else {
      qtyFocusNodes[selectedRowIndex].requestFocus();
    }
  }

  Future<void> _fnSave({
    required String prmIsRlz,
    required String autoId,
    required bool clearShort,
    required String quantity,
    required String shorts,
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      String prmBrId = prefs.getString('brId')!;
      String prmFaId = prefs.getString('faId')!;
      String prmUId = prefs.getString('userId')!;
      ApiServices()
          .fnSavePackingItem(
        prmBrId: prmBrId,
        prmCmpId: prmCmpId,
        prmFaId: prmFaId,
        prmUID: prmUId,
        prmAutoID: autoId,
        orderId: widget.selectedSalesOrderList.id,
        prmShort: clearShort ? '' : shorts,
        prmQty: _qtyControllers.text,
        prmIsRlz: prmIsRlz,
      )
          .whenComplete(() {
        _fnGetOrderList().whenComplete(() {
          Navigator.pop(context);
        });
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          content: const Text('Unable to save data'),
        ),
      );
    }
  }

  Future<void> _selectAllItemSave(
      {required String autoId,
      required int short,
      required String prmIsRlz}) async {
    try {
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

      ApiServices()
          .fnSavePackingItem(
              prmBrId: prmBrId,
              prmCmpId: prmCmpId,
              prmFaId: prmFaId,
              prmUID: prmUId,
              prmAutoID: autoId,
              orderId: widget.selectedSalesOrderList.id,
              prmShort: _shortController.text,
              prmQty: _qtyControllers.text,
              prmIsRlz: prmIsRlz)
          .whenComplete(() {
        _fnGetOrderList().whenComplete(() {
          Navigator.pop(context);
        });
      });
    } catch (e) {
      debugPrint(e.toString());
      Navigator.pop(context);
    }
  }

  Future<void> _selectAllSavePackingItem() async {
    try {
      print('pref not covered');
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

      ApiServices()
          .selectAllSavePackingItem(
        prmOrderId: widget.selectedSalesOrderList.id,
        prmCmpId: prmCmpId,
        prmBrId: prmBrId,
        prmFaId: prmFaId,
        prmUId: prmUId,
      )
          .whenComplete(() {
        _fnGetOrderList().whenComplete(() {
          Navigator.pop(context);
        });
      });
    } catch (e) {
      debugPrint(e.toString());
      Navigator.pop(context);
    }
  }

  Widget _buildOrderItemTable({
    required List<SalesOrderItemListModel> data,
  }) {
    final columns = [
      'Qty',
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
          mainAxisAlignment: MainAxisAlignment.start,
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
              onPressed: _selectAll,
              child: Text(
                isAllSelected ? "Unselect All" : "Select All",
              ),
            ),
            SizedBox(width: 150),
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
                  onKeyEvent: _handleKeyPress,
                  child: DataTable(
                    border: TableBorder.symmetric(
                        inside: BorderSide(
                      color: Colors.black,
                    )),
                    columnSpacing: 5,
                    horizontalMargin: 5,
                    dataRowMaxHeight: 80,
                    dataRowMinHeight: 80,
                    dataRowColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        final int index = states.contains(WidgetState.selected)
                            ? states.contains(WidgetState.selected)
                                ? data.indexOf(data[selectedRowIndex])
                                : -1
                            : -1;
                        return index == selectedRowIndex
                            ? Colors.blue.withValues(alpha: 0.6)
                            : Colors.purple.shade100.withValues(alpha: 0.75);
                      },
                    ),
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
                          selected: rowItem == selectedOrderItem,
                          cells: [
                            DataCell(
                              onTap: () {
                                selectedRowIndex = index;
                                _updateFocus();
                                notesFocusNodes[index].unfocus();
                                _fnSwitchToQtyMode();
                                _setSelectedItem(
                                  selectedRowItem: rowItem,
                                );
                              },
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  width: 60,
                                  height: 70,
                                  decoration: BoxDecoration(
                                      color: Colors.yellow,
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
                              Center(
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
                                    value: selectedPackList[index],
                                    hint: const Text('Select Category'),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedPackList[index] = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              onTap: () {
                                setState(() {
                                  selectedRowIndex = index;
                                  _updateFocus();
                                  notesFocusNodes[index].unfocus();
                                });
                                _fnSwitchToQtyMode();
                                _setSelectedItem(
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
                                  _updateFocus();
                                  notesFocusNodes[index].unfocus();
                                });
                                _fnSwitchToQtyMode();
                                _setSelectedItem(
                                  selectedRowItem: rowItem,
                                );
                              },
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  width: 140,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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
                                    focusNode: notesFocusNodes[index],
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
                                      _setSelectedItem(
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
                                  _updateFocus();
                                  notesFocusNodes[index].unfocus();
                                });
                                _setSelectedItem(
                                  selectedRowItem: rowItem,
                                );
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
                                      _setSelectedItem(
                                        selectedRowItem: rowItem,
                                      );
                                      _fnSave(
                                        prmIsRlz: rowItem.isRelease == 'False'
                                            ? '1'
                                            : '0',
                                        clearShort: true,
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
                                    backgroundColor:
                                        rowItem.isRelease == 'False'
                                            ? Colors.orange
                                            : Colors.green,
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
                                      _updateFocus();
                                      notesFocusNodes[index].unfocus();
                                    });
                                    _fnSwitchToQtyMode();
                                    _setSelectedItem(
                                      selectedRowItem: rowItem,
                                    );
                                    _fnSave(
                                      prmIsRlz: rowItem.isRelease == 'False'
                                          ? '1'
                                          : '0',
                                      clearShort: false,
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
                                  _updateFocus();
                                  notesFocusNodes[index].unfocus();
                                });
                              },
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: rowItem.short == ''
                                        ? Colors.grey
                                        : Colors.red,
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
                                    _handleShortButtonClick(
                                      index: index,
                                      selectedRowItem: rowItem,
                                    );
                                    setState(() {
                                      selectedRowIndex = index;
                                      _fnSwitchToShortMode();
                                      _setSelectedItem(
                                        selectedRowItem: rowItem,
                                      );
                                      _updateFocus();
                                      notesFocusNodes[index].unfocus();
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
              flex: 10,
              child: _buildOrderItemTable(data: widget.orderListItems)),
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
                            data:
                                '${selectedOrderItem.itemName}, ${selectedOrderItem.printUom}',
                            fillColor: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _itemTextFields(
                            title: 'Quantity',
                            data: _qtyControllers.text,
                            onTab: _fnSwitchToQtyMode,
                            fillColor: Colors.white),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: _itemTextFields(
                          title: 'Shorts',
                          data: _shortController.text,
                          color: selectedOrderItem.short == ''
                              ? Colors.black
                              : Colors.white,
                          fillColor: selectedOrderItem.short == '' ||
                                  selectedOrderItem.short == '0'
                              ? Colors.grey
                              : Colors.red,
                          onTab: _fnSwitchToShortMode,
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
                              _fnSave(
                                  prmIsRlz:
                                      selectedOrderItem.isRelease == 'False'
                                          ? '1'
                                          : '0',
                                  clearShort: false,
                                  autoId: selectedOrderItem.autoId,
                                  quantity: _qtyControllers.text,
                                  shorts: _shortController.text);
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

  Widget _itemTextFields({
    required String title,
    required String data,
    required Color fillColor,
    Color color = Colors.black,
    GestureTapCallback? onTab,
  }) {
    final bool isShortField = title == 'Shorts';
    final controller = isShortField
        ? _shortController
        : TextEditingController(
            text: data,
          );
    return Column(
      children: [
        TextFormField(
          readOnly: true,
          enableIMEPersonalizedLearning: true,
          controller: controller,
          onTap: onTab,
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
            if (isQtyFocused && isFirstDigitAfterFocus) {
              controller.text = value;
              isFirstDigitAfterFocus =
                  false; // Reset the flag after first digit
            } else {
              controller.text = controller.text + value;
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

  void _setSelectedItem({
    required SalesOrderItemListModel selectedRowItem,
  }) {
    setState(() {
      selectedOrderItem = selectedRowItem;
    });
  }
}
