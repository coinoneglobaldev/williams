import 'package:flutter/material.dart';
import 'package:williams/constants.dart';
import 'package:williams/custom_widgets/custom_scaffold.dart';

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
      bodyWidget: Column(
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Search with Category: $_selectedCategory, Subcategory: $_selectedSubcategory'),
                  ),
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
          const SizedBox(height: 20),
          _buyingSheetTable(data: _dummyTableData),
        ],
      ),
    );
  }

  Widget _buyingSheetTable({
    required List<Map<String, dynamic>> data,
  }) {
    final columns = [
      'Code',
      'Name',
      'UOM',
      'Cor Yal',
      'Bulk',
      'Split',
      'Bulk',
      'Split'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8.0),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20.0,
              dataRowColor: WidgetStateProperty.all(Colors.grey.shade900),
              headingRowColor: WidgetStateProperty.all(Colors.white),
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
              rows: data.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(
                      item['code'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    )),
                    DataCell(Text(
                      item['name'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    )),
                    DataCell(Text(
                      item['uom'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    )),
                    DataCell(Text(
                      item['corYal'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    )),
                    DataCell(Text(
                      item['stockBulk'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    )),
                    DataCell(Text(
                      item['stockSplit'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    )),
                    DataCell(
                      SizedBox(
                        width: 100,
                        height: 40,
                        child: TextField(
                          controller: item['orderBulk'],
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Bulk',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100,
                        height: 40,
                        child: TextField(
                          controller: item['orderSplit'],
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Split',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
