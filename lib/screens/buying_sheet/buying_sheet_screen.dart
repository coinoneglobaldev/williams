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

  // Dummy data for the table
  final List<Map<String, dynamic>> _dummyTableData = [
    {
      'code': 'P001',
      'name': 'Product A',
      'uom': 'Pcs',
      'corYal': '10',
      'stockBulk': '500',
      'stockSplit': '100',
      'orderBulk': '',
      'orderSplit': '',
    },
    {
      'code': 'P002',
      'name': 'Product B',
      'uom': 'Kg',
      'corYal': '15',
      'stockBulk': '250',
      'stockSplit': '50',
      'orderBulk': '',
      'orderSplit': '',
    },
    {
      'code': 'P003',
      'name': 'Product C',
      'uom': 'Mtr',
      'corYal': '5',
      'stockBulk': '750',
      'stockSplit': '200',
      'orderBulk': '',
      'orderSplit': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenCustomScaffold(
      title: 'Buying Sheet',
      bodyWidget: Column(
        children: [
          DropdownButtonFormField<String>(
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
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_selectedCategory != null && _selectedSubcategory != null) {
                // todo: implement search logic
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Search with Category: $_selectedCategory, Subcategory: $_selectedSubcategory'),
                ),
              );
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              border: TableBorder.all(
                color: Colors.white,
              ),
              columnWidths: {
                0: FixedColumnWidth(80),
                1: FixedColumnWidth(120),
                2: FixedColumnWidth(80),
                3: FixedColumnWidth(80),
                4: FixedColumnWidth(100),
                5: FixedColumnWidth(100),
                6: FixedColumnWidth(100),
                7: FixedColumnWidth(100),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Uom', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Cor Yal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Stock Bulk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Stock Split', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Order Bulk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Order Split', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                // Generate rows with dummy data and order text fields
                ...List.generate(_dummyTableData.length, (index) {
                  var item = _dummyTableData[index];
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item['code'], style: const TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item['name'], style: const TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item['uom'], style: const TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item['corYal'], style: const TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item['stockBulk'], style: const TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item['stockSplit'], style: const TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Bulk Order',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _dummyTableData[index]['orderBulk'] = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Split Order',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _dummyTableData[index]['orderSplit'] = value;
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
        ],
      ),
    );
  }
}