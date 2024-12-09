import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late List<FocusNode> qtyFocusNodes;
  late List<FocusNode> notesFocusNodes;
  int selectedRowIndex = 0;
  bool isQtyFocused = true;

  @override
  void initState() {
    super.initState();
    orderItems = [
      OrderItem(
        packCode: 'PC001',
        description: 'Blue T-Shirt ',
        qty: '5',
        notes: 'Check qualityfdgfdgdfgfdgfdsg',
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
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
      ),
      OrderItem(
        packCode: 'PC004',
        description: 'White Shirt Small',
        qty: '',
        notes: 'Fragile items',
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
    qtyFocusNodes = List.generate(orderItems.length, (index) => FocusNode());
    notesFocusNodes = List.generate(orderItems.length, (index) => FocusNode());

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
          ' Order Items',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8.0),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.88,
            width: MediaQuery.of(context).size.width,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.88,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ListView(
                    children: [
                      KeyboardListener(
                        focusNode: FocusNode(),
                        onKeyEvent: _handleKeyPress,
                        child: DataTable(
                          horizontalMargin: 0,
                          border: TableBorder.all(color: Colors.black),
                          dataRowMaxHeight: 50,
                          dataRowMinHeight: 50,
                          dataRowColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              final int index =
                                  states.contains(WidgetState.selected)
                                      ? states.contains(WidgetState.selected)
                                          ? data.indexOf(data[selectedRowIndex])
                                          : -1
                                      : -1;
                              return index == selectedRowIndex
                                  ? Colors.blue.withOpacity(0.6)
                                  : Colors.white;
                            },
                          ),
                          headingRowColor: WidgetStateProperty.all(Colors.grey),
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
                                selected: index == selectedRowIndex,
                                cells: [
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: TextField(
                                            readOnly: true,
                                            controller: qtyControllers[index],
                                            focusNode: qtyFocusNodes[index],
                                            keyboardType: TextInputType.number,
                                            style: const TextStyle(
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintText: 'Enter value',
                                              hintStyle: TextStyle(
                                                  color: Colors.grey.shade500),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
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
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        item.packCode,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        item.description,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 150,
                                      child: TextField(
                                        // readOnly: true,
                                        controller: notesControllers[index],
                                        focusNode: notesFocusNodes[index],
                                        style: const TextStyle(
                                            color: Colors.black),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: 'Enter value',
                                          hintStyle: TextStyle(
                                              color: Colors.grey.shade500),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
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
                                    Transform.scale(
                                      scale: 2.5,
                                      child: Checkbox(
                                        activeColor: Colors.black,
                                        checkColor: Colors.white,
                                        value: item.isChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            item.isChecked = value ?? false;
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
      bodyWidget: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildOrderItemTable(data: orderItems)),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      ' ',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        margin: const EdgeInsets.only(left: 20),
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(10),
                        height: MediaQuery.of(context).size.height * 0.88,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
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
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, top: 10, bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Keyboard",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Back',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.only(left: 10, right: 10),
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        '${orderItems[selectedRowIndex].description}, ${orderItems[selectedRowIndex].packCode}',
                                  ),
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
                                  ),
                                ),
                                Expanded(
                                  child: _itemDetails(
                                    context: context,
                                    title: 'Notes',
                                    data:
                                        notesControllers[selectedRowIndex].text,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _itemDetails(
                                    context: context,
                                    title: 'Item is Checked',
                                    data: orderItems[selectedRowIndex].isChecked
                                        ? 'Yes'
                                        : 'No',
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                    onPressed: _moveDown,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      minimumSize: const Size(100, 50),
                                    ),
                                    child: const Text('Ok'),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed:
                                        isValidToSave ? _handleSave : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isValidToSave
                                          ? Colors.blue
                                          : Colors.grey,
                                      minimumSize: const Size(100, 50),
                                    ),
                                    child: const Text('Save'),
                                  ),
                                  ElevatedButton(
                                    onPressed: _moveUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      minimumSize: const Size(100, 50),
                                    ),
                                    child: const Icon(Icons.arrow_upward),
                                  ),
                                  ElevatedButton(
                                    onPressed: _moveDown,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      minimumSize: const Size(100, 50),
                                    ),
                                    child: const Icon(Icons.arrow_downward),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Column _itemDetails({
    required BuildContext context,
    required String title,
    required String data,
    bool isReadOnly = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  readOnly: isReadOnly,
                  enableIMEPersonalizedLearning: true,
                  controller: TextEditingController(text: data),
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: title,
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          ),
        )
      ],
    );
  }

  GestureDetector _calculatorContainer({required String value}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (value == 'C') {
            final currentText = qtyControllers[selectedRowIndex].text;
            if (currentText.isNotEmpty) {
              qtyControllers[selectedRowIndex].text =
                  currentText.substring(0, currentText.length - 1);
            }
          } else if (value == '.') {
            final currentText = qtyControllers[selectedRowIndex].text;
            // Only add decimal point if there isn't one already
            if (!currentText.contains('.')) {
              qtyControllers[selectedRowIndex].text = currentText + value;
            }
          } else {
            final currentText = qtyControllers[selectedRowIndex].text;
            qtyControllers[selectedRowIndex].text = currentText + value;
          }
          orderItems[selectedRowIndex].qty =
              qtyControllers[selectedRowIndex].text;
        });
      },
      child: Transform.scale(
        scale: 1.3,
        child: Container(
          margin: const EdgeInsets.all(10),
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.yellow.shade900,
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
