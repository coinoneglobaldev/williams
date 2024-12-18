import 'package:flutter/material.dart';
import 'package:williams/constants.dart';
import 'package:williams/custom_widgets/custom_scaffold.dart';
import 'package:williams/screens/buying_flow/widgets/buying_sheet_appbar.dart';
import '../../custom_widgets/util_class.dart';

class BuyingSheetScreen extends StatefulWidget {
  const BuyingSheetScreen({super.key});

  @override
  State<BuyingSheetScreen> createState() => _BuyingSheetScreenState();
}

class _BuyingSheetScreenState extends State<BuyingSheetScreen> {
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedPreviousOrder;
  late List<TextEditingController> orderQtyControllers;

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

  final List<String> _previousOrders = [
    'Order 1',
    'Order 2',
    'Order 3',
  ];

  final List<Map<String, dynamic>> _dummyTableData = [
    {
      'code': 'Chemia EHI0422',
      'name': '20 Silk Cut Sliver',
      'uom': 'NET',
      'conVal': '1.00',
      'Bulk': '2.00',
      'Split': '0.00',
      'BulkSplit': 'Bulk',
      'orderQty': '10',
    },
    {
      'code': 'Frozen EHI1244',
      'name': 'Abramczyk Fliety Z Mintaja 400G',
      'uom': 'NET',
      'conVal': '1.00',
      'Bulk': '2.00',
      'Split': '0.00',
      'BulkSplit': 'Bulk',
      'orderQty': '20',
    },
    {
      'code': 'Gazeta EHI3074',
      'name': '100 Panaramicznych',
      'uom': 'NET',
      'conVal': '1.00',
      'Bulk': '7.00',
      'Split': '0.00',
      'BulkSplit': 'Bulk',
      'orderQty': '30',
    },
  ];

  @override
  void initState() {
    super.initState();
    orderQtyControllers = _dummyTableData
        .map((item) => TextEditingController())
        .toList();
  }

  @override
  void dispose() {
    for (var controller in orderQtyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenCustomScaffold(
      bodyWidget: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const BuyingSheetAppbar(),
            const SizedBox(height: 10),
            dropDownAndSearch(),
            const SizedBox(height: 10),
            _buyingSheetTable(data: _dummyTableData),
            const SizedBox(height: 10),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget dropDownAndSearch() {
    return Row(
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
        Expanded(
          flex: 2,
          child: _buildPreviousOrderDropdown(),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSearchButton(),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return _buildDropdownButtonFormField(
      hint: 'Category',
      value: _selectedCategory,
      items: _categories,
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  Widget _buildSupplierDropdown() {
    return _buildDropdownButtonFormField(
      hint: 'Supplier',
      value: _selectedSubcategory,
      items: _subcategories,
      onChanged: (value) {
        setState(() {
          _selectedSubcategory = value;
        });
      },
    );
  }

  Widget _buildPreviousOrderDropdown() {
    return _buildDropdownButtonFormField(
      hint: 'Previous order',
      value: _selectedPreviousOrder,
      items: _previousOrders,
      onChanged: (value) {
        setState(() {
          _selectedPreviousOrder = value;
        });
      },
    );
  }

  Widget _buildDropdownButtonFormField({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        value: value,
        items: items
            .map(
              (item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          ),
        )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: _handleSearch,
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

  void _handleSearch() {
    if (_selectedCategory == null || _selectedSubcategory == null) {
      Util.customErrorSnackbar(
        context,
        'Please select Category and Subcategory!',
      );
    }
    if (_selectedCategory != null && _selectedSubcategory != null) {
      Util.customErrorSnackbar(
        context,
        'Categories and Subcategories are not yet added!',
      );
    }
  }

  Widget _buyingSheetTable({required List<Map<String, dynamic>> data}) {
    return SingleChildScrollView(
      child: Row(
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: Colors.black),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(128),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: DataTable(
                  dataRowMinHeight: 80,
                  dataRowMaxHeight: 80,
                  horizontalMargin: 10,
                  columnSpacing: 10,
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade400),
                  border: TableBorder.symmetric(
                    inside: const BorderSide(color: Colors.black, width: 1.0),
                  ),
                  columns: _getTableColumns(),
                  rows: data.map((item) => _buildDataRow(item)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _getTableColumns() {
    return [
      'Code', 'Name', 'UOM', 'Con Val', 'Short Bulk',
      'Short Split', 'Order UOM', 'Order Qty', 'Select'
    ].map(_buildDataColumn).toList();
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  DataRow _buildDataRow(Map<String, dynamic> item) {
    item['isSelected'] ??= false;
    item['bulkSplitValue'] ??= 'Bulk';

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) => Colors.purple.shade50,
      ),
      cells: [
        _buildDataCell(item['code']),
        _buildDataCell(item['name']),
        _buildDataCell(item['uom']),
        _buildDataCell(item['conVal']),
        _buildDataCell(item['Bulk']),
        _buildDataCell(item['Split']),
        _buildBulkSplitDropdownCell(item),
        _buildEditableDataCell(TextEditingController(text: item['orderQty'])),
        _buildCheckboxDataCell(item),
      ],
    );
  }

  DataCell _buildDataCell(String? text) {
    return DataCell(
      SizedBox(
        height: 50,
        child: Center(
          child: Text(
            text ?? '',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ),
    );
  }

  DataCell _buildBulkSplitDropdownCell(Map<String, dynamic> item) {
    return DataCell(
      Center(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: item['bulkSplitValue'],
            underline: Container(),
            items: ['Bulk', 'Split'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                item['bulkSplitValue'] = newValue;
              });
            },
          ),
        ),
      ),
    );
  }

  DataCell _buildEditableDataCell(TextEditingController controller) {
    return DataCell(
      Center(
        child: SizedBox(
          width: 150,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                onTap: () => _decrementValue(controller),
                child: const Icon(Icons.remove,size: 30),
              ),
              prefixIcon: GestureDetector(
                onTap: () => _incrementValue(controller),
                child: const Icon(Icons.add,size: 30),
              ),
              hintText: 'Enter value',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ),
    );
  }

  void _incrementValue(TextEditingController controller) {
    int currentValue = int.tryParse(controller.text) ?? 0;
    controller.text = (currentValue + 1).toString();
  }

  void _decrementValue(TextEditingController controller) {
    int currentValue = int.tryParse(controller.text) ?? 0;
    if (currentValue > 0) {
      controller.text = (currentValue - 1).toString();
    }
  }

  DataCell _buildCheckboxDataCell(Map<String, dynamic> item) {
    return DataCell(
      Center(
        child: Transform.scale(
          scale: 2.5,
          child: Checkbox(
            activeColor: Colors.black,
            checkColor: Colors.black,
            fillColor: WidgetStateProperty.all(Colors.white),
            value: item['isSelected'] ?? false,
            side: const BorderSide(color: Colors.black, width: 1),
            onChanged: (bool? value) {
              setState(() {
                item['isSelected'] = value ?? false;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        Util.customSuccessSnackbar(
          context,
          'Saved Successfully!',
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        minimumSize: const Size(300, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text('Save'),
    );
  }
}