import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:williams/custom_widgets/custom_scaffold.dart';

import '../../models/sales_order_item_list_model.dart';
import '../../models/uom_list_model.dart';

class OrderItemView extends StatefulWidget {
  final List<SalesOrderItemListModel> salesOrderListModel;
  final List<UomListModel> packList;
  const OrderItemView(
      {super.key, required this.salesOrderListModel, required this.packList});

  @override
  State<OrderItemView> createState() => _OrderItemViewState();
}

class _OrderItemViewState extends State<OrderItemView> {
  bool isShortMode = false;
  late List<TextEditingController> qtyControllers;
  late List<TextEditingController> notesControllers;
  late List<TextEditingController> shortControllers;
  late List<FocusNode> qtyFocusNodes;
  late List<FocusNode> notesFocusNodes;
  bool isAllSelected = false;
  int selectedRowIndex = 0;
  bool isQtyFocused = true;
  bool isFirstDigitAfterFocus = true;

  List<String> packs = ['retail', 'unit sale'];
  List<String?> selectedPack = [];

  @override
  void initState() {
    super.initState();
    selectedPack = List<String?>.filled(
        widget.salesOrderListModel.length, widget.packList[0].name);

    qtyControllers = widget.salesOrderListModel
        .map((item) => TextEditingController(text: item.qty))
        .toList();
    notesControllers = widget.salesOrderListModel
        .map((item) => TextEditingController(text: item.remarks))
        .toList();
    shortControllers = List.generate(
        widget.salesOrderListModel.length, (index) => TextEditingController());

    // Then initialize focus nodes
    qtyFocusNodes = List.generate(
        widget.salesOrderListModel.length, (index) => FocusNode());
    notesFocusNodes = List.generate(
        widget.salesOrderListModel.length, (index) => FocusNode());

    // Now add listeners after all controllers are initialized
    for (var controller in shortControllers) {
      controller.addListener(() {
        setState(() {});
      });
    }

    // Add focus listeners
    for (var i = 0; i < widget.salesOrderListModel.length; i++) {
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

      for (var item in widget.salesOrderListModel) {
        item.isChecked = isAllSelected;
      }
    });
  }

  void _handleShortButtonClick(int index) {
    setState(() {
      selectedRowIndex = index;
      isShortMode = true;
      isQtyFocused = false;

      // Force keyboard to show for short input
      FocusScope.of(context).requestFocus(FocusNode());
      Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {});
      });

      _updateFocus();
      notesFocusNodes[index].unfocus();
      qtyFocusNodes[index].unfocus();
    });
  }

  void _switchToQtyMode() {
    setState(() {
      isShortMode = false;
      isQtyFocused = true;
    });
  }

  void _switchToShortMode() {
    setState(() {
      isShortMode = true;
      isQtyFocused = false;
      notesFocusNodes[selectedRowIndex].unfocus();
    });
    _updateFocus();
  }

  @override
  void dispose() {
    for (var controller in qtyControllers) {
      controller.dispose();
    }
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
    if (selectedRowIndex < widget.salesOrderListModel.length - 1) {
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

  void _incrementQty() {
    final currentQty = int.tryParse(qtyControllers[selectedRowIndex].text) ?? 0;
    qtyControllers[selectedRowIndex].text = (currentQty + 1).toString();
    setState(() {
      widget.salesOrderListModel[selectedRowIndex].qty =
          qtyControllers[selectedRowIndex].text;
    });
  }

  void _decrementQty() {
    final currentQty = int.tryParse(qtyControllers[selectedRowIndex].text) ?? 0;
    if (currentQty > 0) {
      qtyControllers[selectedRowIndex].text = (currentQty - 1).toString();
      setState(() {
        widget.salesOrderListModel[selectedRowIndex].qty =
            qtyControllers[selectedRowIndex].text;
      });
    }
  }

  bool get isValidToSave =>
      qtyControllers.every((controller) => controller.text.isNotEmpty);

  void _handleSave() {
    if (!isValidToSave) return;

    for (int i = 0; i < widget.salesOrderListModel.length; i++) {
      widget.salesOrderListModel[i].qty = qtyControllers[i].text;
      widget.salesOrderListModel[i].remarks = notesControllers[i].text;
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
                ...widget.salesOrderListModel.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pack: ${item.printUom}'),
                          Text('Code: ${item.itemCode}'),
                          Text('Description: ${item.itemName}'),
                          Text('Quantity: ${item.qty}'),
                          Text('Notes: ${item.remarks}'),
                          Text('Checked: ${item.isChecked! ? 'Yes' : 'No'}'),
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
            const Text(
              ' Order Items',
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(150, 50),
              ),
              onPressed: _selectAll,
              child: Text(isAllSelected ? "Unselect All" : "Select All"),
            ),
            const Spacer(),
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
                        final item = entry.value;
                        return DataRow(
                          selected: index == selectedRowIndex,
                          cells: [
                            DataCell(
                              onTap: () {
                                setState(() {
                                  selectedRowIndex = index;
                                  _updateFocus();
                                  notesFocusNodes[index].unfocus();
                                });
                                _switchToQtyMode();
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
                                      item.qty,
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
                                  child: DropdownButton<String>(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    value: selectedPack[index],
                                    items: widget.packList
                                        .map((UomListModel pack) {
                                      return DropdownMenuItem<String>(
                                        value: pack.name,
                                        child: Text(pack.name),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedPack[index] = newValue;
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
                                _switchToQtyMode();
                              },
                              Center(
                                child: Text(
                                  item.itemCode,
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
                                _switchToQtyMode();
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
                                          color: Colors.black
                                              .withValues(alpha: 0.3),
                                          blurRadius: 15,
                                        ),
                                      ]),
                                  child: Center(
                                    child: Text(
                                      item.itemName,
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
                                        //TODO : update notes
                                        // item.notes = value;
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
                              },
                              Center(
                                child: Transform.scale(
                                  scale: 2.5,
                                  child: Checkbox(
                                    activeColor: Colors.black,
                                    checkColor: Colors.black,
                                    fillColor:
                                        WidgetStateProperty.all(Colors.white),
                                    value: item.isChecked,
                                    side: BorderSide(
                                        color: Colors.black, width: 1),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        item.isChecked = value ?? false;
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
                                _switchToQtyMode();
                              },
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
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
                                    backgroundColor:
                                        item.short == '' || item.short == '0'
                                            ? Colors.grey
                                            : Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    minimumSize: const Size(80, 70),
                                  ),
                                  child: Text(
                                    item.short == '' ? 'Short' : item.short,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          item.short == '' || item.short == '0'
                                              ? Colors.black
                                              : Colors.white,
                                    ),
                                  ),
                                  onPressed: () =>
                                      _handleShortButtonClick(index),
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

      // floatingActionButton: Container(
      //   margin: const EdgeInsets.only(left: 30),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     children: [
      //       FloatingActionButton(
      //         heroTag: 'btn1',
      //         onPressed: _moveUp,
      //         mini: true,
      //         backgroundColor: Colors.grey.shade900,
      //         child: const Icon(Icons.arrow_upward, color: Colors.white),
      //       ),
      //       const SizedBox(height: 10),
      //       FloatingActionButton(
      //         heroTag: 'btn2',
      //         onPressed: _moveDown,
      //         mini: true,
      //         backgroundColor: Colors.grey.shade900,
      //         child: const Icon(Icons.arrow_downward, color: Colors.white),
      //       ),
      //     ],
      //   ),
      // ),
      bodyWidget: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 10,
              child: _buildOrderItemTable(data: widget.salesOrderListModel)),
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.only(
                left: 10,
                top: 40,
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
                        child: _itemDetails(
                            context: context,
                            title: 'Item Details',
                            data:
                                '${widget.salesOrderListModel[selectedRowIndex].itemName}, ${widget.salesOrderListModel[selectedRowIndex].printUom}',
                            fillColor: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _itemDetails(
                            context: context,
                            title: 'Quantity',
                            data: qtyControllers[selectedRowIndex].text,
                            onTab: _switchToQtyMode,
                            fillColor: Colors.white),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: _itemDetails(
                          context: context,
                          title: 'Shorts',
                          data: shortControllers[selectedRowIndex].text,
                          color: widget.salesOrderListModel[selectedRowIndex]
                                      .short ==
                                  ''
                              ? Colors.black
                              : Colors.white,
                          fillColor: widget
                                      .salesOrderListModel[selectedRowIndex]
                                      .short ==
                                  ''
                              ? Colors.grey
                              : Colors.red,
                          onTab: _switchToShortMode,
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       flex: 3,
                  //       child: _itemDetails(
                  //         context: context,
                  //         title: 'Item is Checked',
                  //         data: orderItems[selectedRowIndex].isChecked
                  //             ? 'Yes'
                  //             : 'No',
                  //       ),
                  //     ),
                  //     Expanded(
                  //       flex: 1,
                  //       child: ElevatedButton(
                  //         onPressed: _moveDown,
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: Colors.blueAccent,
                  //           minimumSize: const Size(100, 50),
                  //         ),
                  //         child: const Text('Ok'),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            // onPressed: isValidToSave ? _handleSave : null,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              // backgroundColor: isValidToSave
                              //     ? Colors.blue
                              //     : Colors.grey,
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
                            // onPressed: isValidToSave ? _handleSave : null,
                            onPressed: () {
                              // _handleSave();
                              widget.salesOrderListModel[selectedRowIndex]
                                      .short =
                                  shortControllers[selectedRowIndex].text;

                              _updateFocus();
                              notesFocusNodes[selectedRowIndex].unfocus();

                              _moveDown();
                            },
                            style: ElevatedButton.styleFrom(
                              // backgroundColor: isValidToSave
                              //     ? Colors.blue
                              //     : Colors.grey,
                              backgroundColor: Colors.green,
                              minimumSize: const Size(100, 50),
                            ),
                            child: const Text('SAVE'),
                          ),
                        ),
                      ),
                      // ElevatedButton(
                      //   onPressed: _moveUp,
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.green,
                      //     minimumSize: const Size(100, 50),
                      //   ),
                      //   child: const Icon(Icons.arrow_upward),
                      // ),
                      // ElevatedButton(
                      //   onPressed: _moveDown,
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.red,
                      //     minimumSize: const Size(100, 50),
                      //   ),
                      //   child: const Icon(Icons.arrow_downward),
                      // ),
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

  Widget _itemDetails({
    required BuildContext context,
    required String title,
    required String data,
    required Color fillColor,
    bool isReadOnly = true,
    Color color = Colors.black,
    GestureTapCallback? onTab,
  }) {
    final bool isShortField = title == 'Shorts';
    final controller = isShortField
        ? shortControllers[selectedRowIndex]
        : TextEditingController(text: data);
    return Column(
      children: [
        TextFormField(
          readOnly: isReadOnly,
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

  GestureDetector _calculatorContainer({required String value}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          final controller = isShortMode
              ? shortControllers[selectedRowIndex]
              : qtyControllers[selectedRowIndex];

          if (value == 'C') {
            final currentText = controller.text;
            if (currentText.isNotEmpty) {
              controller.text =
                  currentText.substring(0, currentText.length - 1);
            }
          } else if (value == '.') {
            final currentText = controller.text;
            // Only add decimal point if there isn't one already
            if (!currentText.contains('.')) {
              controller.text = currentText + value;
            }
          } else {
            // Only clear if it's the first digit after focus
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
}
