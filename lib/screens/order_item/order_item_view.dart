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
        description: 'Blue T-Shirt Large',
        qty: '',
        notes: 'Check quality',
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: _handleKeyPress,
              child: DataTable(
                columnSpacing: 30.0,
                dataRowColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    final int index = states.contains(WidgetState.selected)
                        ? states.contains(WidgetState.selected)
                            ? data.indexOf(data[selectedRowIndex])
                            : -1
                        : -1;
                    return index == selectedRowIndex
                        ? Colors.green.withOpacity(0.6)
                        : Colors.grey.shade900;
                  },
                ),
                headingRowColor: WidgetStateProperty.all(Colors.black),
                columns: columns
                    .map((column) => DataColumn(
                          label: Expanded(
                            child: Text(
                              column,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    hintText: 'Enter value',
                                    hintStyle:
                                        TextStyle(color: Colors.grey.shade500),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
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
                          Text(
                            item.packCode,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        DataCell(
                          Text(
                            item.description,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 120,
                            child: TextField(
                              // readOnly: true,
                              controller: notesControllers[index],
                              focusNode: notesFocusNodes[index],
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                isDense: true,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                hintText: 'Enter value',
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                border: InputBorder.none,
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
                        ),
                        DataCell(
                          Checkbox(
                            fillColor: WidgetStateProperty.all(Colors.white),
                            checkColor: Colors.black,
                            value: item.isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                item.isChecked = value ?? false;
                              });
                            },
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderItemTable(data: orderItems),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  color: Colors.grey.shade900,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10, top: 10, bottom: 8),
                        child: Text(
                          "Keyboard",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        width: MediaQuery.of(context).size.width * 0.3,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                _calculatorContainer(
                                  value: '1',
                                ),
                                _calculatorContainer(
                                  value: '2',
                                ),
                                _calculatorContainer(
                                  value: '3',
                                ),
                                _calculatorContainer(
                                  value: '.',
                                )
                              ],
                            ),
                            Row(
                              children: [
                                _calculatorContainer(
                                  value: '4',
                                ),
                                _calculatorContainer(
                                  value: '5',
                                ),
                                _calculatorContainer(
                                  value: '6',
                                ),
                                _calculatorContainer(
                                  value: 'C',
                                )
                              ],
                            ),
                            Row(
                              children: [
                                _calculatorContainer(
                                  value: '7',
                                ),
                                _calculatorContainer(
                                  value: '8',
                                ),
                                _calculatorContainer(
                                  value: '9',
                                ),
                                _calculatorContainer(
                                  value: '0',
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _itemDetails(
                                    context: context,
                                    title: 'Item Description',
                                    data: orderItems[selectedRowIndex]
                                        .description,
                                  ),
                                ),
                                Expanded(
                                  child: _itemDetails(
                                    context: context,
                                    title: 'Pack Code',
                                    data: orderItems[selectedRowIndex].packCode,
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
                            Expanded(
                              child: _itemDetails(
                                context: context,
                                title: 'Item is Checked',
                                data: orderItems[selectedRowIndex].isChecked
                                    ? 'Yes'
                                    : 'No',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: _moveDown,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: const Size(100, 50),
                            ),
                            child: const Text('Ok'),
                          ),
                          ElevatedButton(
                            onPressed: isValidToSave ? _handleSave : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isValidToSave ? Colors.black : Colors.grey,
                              minimumSize: const Size(100, 50),
                            ),
                            child: const Text('Save'),
                          ),
                          ElevatedButton(
                            onPressed: _moveUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: const Size(100, 50),
                            ),
                            child: const Icon(Icons.arrow_upward),
                          ),
                          ElevatedButton(
                            onPressed: _moveDown,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: const Size(100, 50),
                            ),
                            child: const Icon(Icons.arrow_downward),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  ),
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
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(text: data),
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    isDense: true,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
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
            // If the value is 'C', remove the last character
            final currentText = qtyControllers[selectedRowIndex].text;
            if (currentText.isNotEmpty) {
              qtyControllers[selectedRowIndex].text =
                  currentText.substring(0, currentText.length - 1);
            }
          } else {
            // For all other values, append to existing text
            final currentText = qtyControllers[selectedRowIndex].text;
            qtyControllers[selectedRowIndex].text = currentText + value;
          }
          // Update the order item qty as well
          orderItems[selectedRowIndex].qty =
              qtyControllers[selectedRowIndex].text;
        });
      },
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
