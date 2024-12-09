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
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildCategoryDropdown(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildSupplierDropdown(),
                ),
                const SizedBox(width: 10),
                Expanded(child: _buildSearchButton()),
              ],
            ),
            const SizedBox(height: 10),
            _buyingSheetTable(data: _dummyTableData),
            const SizedBox(height: 10),
            _buildSaveAndBackButton(context),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _selectedCategory,
      items: _categories
          .map(
            (category) => DropdownMenuItem(
              value: category,
              child: Text(category),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  Widget _buildSupplierDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: 'Supplier',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _selectedSubcategory,
      items: _subcategories
          .map(
            (subcategory) => DropdownMenuItem(
              value: subcategory,
              child: Text(subcategory),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedSubcategory = value;
        });
      },
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          if (_selectedCategory == null || _selectedSubcategory == null) {
            CustomErrorSnackbar.show(
              context,
              'Please select Category and Subcategory!',
            );
          }
          if (_selectedCategory != null && _selectedSubcategory != null) {
            CustomErrorSnackbar.show(
              context,
              'Categories and Subcategories are not yet added!',
            );
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
    );
  }

  Widget _buildSaveAndBackButton(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Spacer(),
          Expanded(
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedCategory == null || _selectedSubcategory == null) {
                    CustomErrorSnackbar.show(
                      context,
                      'Please select Category and Subcategory!',
                    );
                  }
                  if (_selectedCategory != null && _selectedSubcategory != null) {
                    CustomErrorSnackbar.show(
                      context,
                      'Categories and Subcategories are not yet added!',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  CustomSuccessSnackbar.show(
                    context,
                    'Order added successfully!',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buyingSheetTable({required List<Map<String, dynamic>> data}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStockHeaderTable(),
          _buildDetailedDataTable(data),
        ],
      ),
    );
  }

  Widget _buildStockHeaderTable() {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(150.0),
        1: FixedColumnWidth(200.0),
        2: FixedColumnWidth(100.0),
        3: FixedColumnWidth(100.0),
        4: FixedColumnWidth(200.0),
        5: FixedColumnWidth(300.0),
      },
      border: TableBorder.all(color: Colors.white),
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
    );
  }

  Widget _buildDetailedDataTable(List<Map<String, dynamic>> data) {
    return Table(
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String? text) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey.shade200,
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
      color: Colors.white,
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
