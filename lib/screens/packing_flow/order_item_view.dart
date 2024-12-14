import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:williams/custom_widgets/custom_scaffold.dart';

class OrderItemView extends StatefulWidget {
  const OrderItemView({super.key});

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

  List<String> packs = ['retail', 'unit sale'];
  List<String?> selectedPack = [];

  List<OrderItem> orderItems = [
    OrderItem(
      pack: 'PC001',
      code: 'Code 12',
      short: '',
      description: 'Blue T-Shirt ',
      qty: '5',
      notes: 'Check quality',
    ),
    OrderItem(
      pack: 'PC002',
      code: 'Code 13',
      description: 'Red Polo Medium',
      short: '',
      qty: '4',
      notes: 'Express delivery',
    ),
    OrderItem(
      pack: 'PC003',
      code: 'Code 14',
      description: 'Black Hoodie XL',
      short: '2',
      qty: '5',
      notes: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedPack = List<String?>.filled(orderItems.length, 'retail');

    qtyControllers = orderItems.map((item) => TextEditingController()).toList();
    notesControllers = orderItems
        .map((item) => TextEditingController(text: item.notes))
        .toList();
    shortControllers =
        List.generate(orderItems.length, (index) => TextEditingController());

    // Then initialize focus nodes
    qtyFocusNodes = List.generate(orderItems.length, (index) => FocusNode());
    notesFocusNodes = List.generate(orderItems.length, (index) => FocusNode());

    // Now add listeners after all controllers are initialized
    for (var controller in shortControllers) {
      controller.addListener(() {
        setState(() {});
      });
    }

    // Add focus listeners
    for (var i = 0; i < orderItems.length; i++) {
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

      for (var item in orderItems) {
        item.isChecked = isAllSelected;
      }
    });
  }

  void _handleShortButtonClick(int index) {
    setState(() {
      selectedRowIndex = index;
      isShortMode = true;
      isQtyFocused = false;
      // Clear focus from other fields
      qtyFocusNodes[index].unfocus();
      notesFocusNodes[index].unfocus();

      // Force keyboard to show for short input
      FocusScope.of(context).requestFocus(FocusNode());
      Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {});
      });
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
    });
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
    if (selectedRowIndex < orderItems.length - 1) {
      setState(() {
        selectedRowIndex++;
      });
      _updateFocus();
    }
  }

  void _updateFocus() {
    if (isQtyFocused) {
      qtyFocusNodes[selectedRowIndex].requestFocus();
    } else {
      notesFocusNodes[selectedRowIndex].requestFocus();
    }
  }

  void _incrementQty() {
    final currentQty = int.tryParse(qtyControllers[selectedRowIndex].text) ?? 0;
    qtyControllers[selectedRowIndex].text = (currentQty + 1).toString();
    setState(() {
      orderItems[selectedRowIndex].qty = qtyControllers[selectedRowIndex].text;
    });
  }

  void _decrementQty() {
    final currentQty = int.tryParse(qtyControllers[selectedRowIndex].text) ?? 0;
    if (currentQty > 0) {
      qtyControllers[selectedRowIndex].text = (currentQty - 1).toString();
      setState(() {
        orderItems[selectedRowIndex].qty =
            qtyControllers[selectedRowIndex].text;
      });
    }
  }

  bool get isValidToSave =>
      qtyControllers.every((controller) => controller.text.isNotEmpty);

  void _handleSave() {
    if (!isValidToSave) return;

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
                          Text('Pack: ${item.pack}'),
                          Text('Code: ${item.code}'),
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
    final columns = [
      'Qty',
      'Pack',
      'Code',
      'Description',
      'Notes',
      'Check box',
      'Done',
      'Short'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              ' Order Items',
              style: TextStyle(
                fontSize: 50.0,
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
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: _handleKeyPress,
                    child: DataTable(
                      border: TableBorder.symmetric(
                          inside: BorderSide(
                        color: Colors.black,
                      )),
                      horizontalMargin: 30,
                      dataRowMaxHeight: 80,
                      dataRowMinHeight: 80,
                      dataRowColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          final int index =
                              states.contains(WidgetState.selected)
                                  ? states.contains(WidgetState.selected)
                                      ? data.indexOf(data[selectedRowIndex])
                                      : -1
                                  : -1;
                          return index == selectedRowIndex
                              ? Colors.blue.withValues(alpha: 0.6)
                              : Colors.white;
                        },
                      ),
                      headingRowColor:
                          WidgetStateProperty.all(Colors.grey.shade400),
                      columns: columns
                          .map((column) => DataColumn(
                                label: Text(
                                  column,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
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
                                Text(
                                  item.qty,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              DataCell(
                                ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      hintText: 'Pack Type',
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 16),
                                    ),
                                    value: selectedPack[index],
                                    items: packs.map((String pack) {
                                      return DropdownMenuItem<String>(
                                        value: pack,
                                        child: Text(pack),
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
                              DataCell(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex = index;
                                    _updateFocus();
                                    notesFocusNodes[index].unfocus();
                                  });
                                  _switchToQtyMode();
                                },
                                Text(
                                  item.code,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
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
                                Text(
                                  item.description,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              DataCell(
                                TextField(
                                  controller: notesControllers[index],
                                  focusNode: notesFocusNodes[index],
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Enter value',
                                    hintStyle:
                                        TextStyle(color: Colors.grey.shade500),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
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
                              DataCell(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex = index;
                                    _updateFocus();
                                    notesFocusNodes[index].unfocus();
                                  });
                                },
                                Transform.scale(
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
                              DataCell(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex = index;
                                    _updateFocus();
                                    notesFocusNodes[index].unfocus();
                                  });
                                  _switchToQtyMode();
                                },
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: index == 1
                                        ? Colors.green
                                        : Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    minimumSize: const Size(100, 70),
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
                              DataCell(
                                onTap: () {
                                  setState(() {
                                    selectedRowIndex = index;
                                    _updateFocus();
                                    notesFocusNodes[index].unfocus();
                                  });
                                },
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        item.short == '' || item.short == '0'
                                            ? Colors.grey
                                            : Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    minimumSize: const Size(100, 70),
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenCustomScaffold(
      resizeToAvoidBottomInset: false,
      title: 'Order Item',
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
          Expanded(flex: 7, child: _buildOrderItemTable(data: orderItems)),
          Expanded(
            flex: 3,
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
                        Row(
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
                            Expanded(
                              child: _calculatorContainer(
                                value: '.',
                              ),
                            )
                          ],
                        ),
                        Row(
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
                            Expanded(
                              child: _calculatorContainer(
                                value: 'C',
                              ),
                            )
                          ],
                        ),
                        Row(
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
                            Expanded(
                              child: _calculatorContainer(
                                value: '0',
                              ),
                            )
                          ],
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
                                '${orderItems[selectedRowIndex].description}, ${orderItems[selectedRowIndex].pack}',
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
                          color: orderItems[selectedRowIndex].short == '' ? Colors.black : Colors.white,
                          fillColor: orderItems[selectedRowIndex].short == '' ? Colors.grey : Colors.red,
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
                              FocusScope.of(context).unfocus();
                              // _handleSave();
                              orderItems[selectedRowIndex].short =
                                  shortControllers[selectedRowIndex].text;
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
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color, width: 2.0),
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
            final currentText = controller.text;
            controller.text = currentText + value;
          }
          // orderItems[selectedRowIndex].qty = controller.text;
        });
      },
      child: Transform.scale(
        scale: 1.3,
        child: Container(
          margin: const EdgeInsets.all(10),
          height: 60,
          width: 60,
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
      ),
    );
  }
}

class OrderItem {
  final String pack;
  final String code;
  final String description;
  String short;
  String qty;
  String notes;
  bool isChecked;

  OrderItem({
    required this.pack,
    required this.code,
    required this.description,
    required this.short,
    this.qty = '',
    this.notes = '',
    this.isChecked = false,
  });
}
