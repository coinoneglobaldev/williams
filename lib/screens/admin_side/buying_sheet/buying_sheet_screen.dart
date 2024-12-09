import 'package:flutter/material.dart';
import 'package:williams/constants.dart';
import 'package:williams/custom_widgets/custom_scaffold.dart';

import '../../../custom_widgets/custom_snackbar.dart';

class BuyingSheetScreen extends StatefulWidget {
  const BuyingSheetScreen({super.key});

  @override
  State<BuyingSheetScreen> createState() => _BuyingSheetScreenState();
}

class _BuyingSheetScreenState extends State<BuyingSheetScreen> {
  String? _selectedCategory;
  String? _selectedSubcategory;
  final List<String> _categories = [
    'Category 1',
    'Category 2',
    'Category 3',
  ];
  final List<String> _subcategories = [
    'Subcategory A',
    'Subcategory B',
    'Subcategory C',
  ];

  final List<Map<String, dynamic>> _dummyTableData = [
    {
      'code': 'P001',
      'name': 'Product A',
      'uom': 'Pcs',
      'corYal': '10',
      'stockBulk': '500',
      'stockSplit': '100',
      'orderBulk': TextEditingController(),
      'orderSplit': TextEditingController(),
    },
    {
      'code': 'P002',
      'name': 'Product B',
      'uom': 'Kg',
      'corYal': '15',
      'stockBulk': '250',
      'stockSplit': '50',
      'orderBulk': TextEditingController(),
      'orderSplit': TextEditingController(),
    },
    {
      'code': 'P003',
      'name': 'Product C',
      'uom': 'Mtr',
      'corYal': '5',
      'stockBulk': '750',
      'stockSplit': '200',
      'orderBulk': TextEditingController(),
      'orderSplit': TextEditingController(),
    },
  ];

  @override
  void dispose() {
    for (var item in _dummyTableData) {
      (item['orderBulk'] as TextEditingController).dispose();
      (item['orderSplit'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenCustomScaffold(
      title: 'Buying Sheet',
      bodyWidget: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: _selectedCategory,
                    items: _categories
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Supplier',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: _selectedSubcategory,
                    items: _subcategories
                        .map((subcategory) => DropdownMenuItem(
                              value: subcategory,
                              child: Text(subcategory),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubcategory = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_selectedCategory != null && _selectedSubcategory != null) {
                  // Implement search logic
                  CustomErrorSnackbar.show(context,
                      'Categories and Subcategories are not yet added!');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            _buyingSheetTable(data: _dummyTableData),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  minimumSize: Size(
                    MediaQuery.of(context).size.width * 0.4,
                    MediaQuery.of(context).size.height * 0.06,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  CustomSuccessSnackbar.show(
                      context, 'Order added successfully!');
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buyingSheetTable({
    required List<Map<String, dynamic>> data,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Table(
              columnWidths: const {
                0: FixedColumnWidth(150.0),
                1: FixedColumnWidth(200.0),
                2: FixedColumnWidth(100.0),
                3: FixedColumnWidth(100.0),
                4: FixedColumnWidth(200.0),
                5: FixedColumnWidth(300.0),
              },
              border: TableBorder.all(color: Colors.black),
              children: [
                TableRow(
                  children: [
                    SizedBox.shrink(),
                    SizedBox.shrink(),
                    SizedBox.shrink(),
                    SizedBox.shrink(),
                    _buildTableHeader('Stock'),
                    _buildTableHeader('Order'),
                  ],
                ),
              ],
            ),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(150.0),
                1: FixedColumnWidth(200.0),
                2: FixedColumnWidth(100.0),
                3: FixedColumnWidth(100.0),
                4: FixedColumnWidth(100.0),
                5: FixedColumnWidth(100.0),
                6: FixedColumnWidth(150.0),
                7: FixedColumnWidth(150.0),
              },
              border: TableBorder.all(color: Colors.black),
              children: [
                TableRow(
                  children: [
                    _buildTableHeader('Code'),
                    _buildTableHeader('Name'),
                    _buildTableHeader('UOM'),
                    _buildTableHeader('Con Val'),
                    _buildTableHeader('Bulk'),
                    _buildTableHeader('Split'),
                    _buildTableHeader('Bulk'),
                    _buildTableHeader('Split'),
                  ],
                ),
                ...data.map((item) {
                  return TableRow(
                    children: [
                      _buildTableCell(item['code']),
                      _buildTableCell(item['name']),
                      _buildTableCell(item['uom']),
                      _buildTableCell(item['corYal']),
                      _buildTableCell(item['stockBulk']),
                      _buildTableCell(item['stockSplit']),
                      _buildTableCellWithTextField(item['orderBulk']),
                      _buildTableCellWithTextField(item['orderSplit']),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey.shade800,
      child: Center(
        child: Text(
          text,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTableCell(String? text) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Center(
        child: Text(
          text ?? '',
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildTableCellWithTextField(TextEditingController controller) {
    return Container(
      height: 60,
      color: Colors.grey.shade800,
      padding: const EdgeInsets.only(bottom: 0, top: 5, left: 5, right: 5),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: 'Enter value',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
