import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:williams/constants.dart';
import 'package:williams/custom_widgets/custom_scaffold.dart';
import '../../custom_widgets/custom_exit_confirmation.dart';
import '../../custom_widgets/custom_logout_button.dart';
import '../../custom_widgets/util_class.dart';
import '../../models/buying_sheet_list_order_model.dart';
import '../../models/category_list_model.dart';
import '../../models/supplier_list_model.dart';
import '../../models/uom_list_model.dart';
import '../../services/api_services.dart';

class BuyingSheetScreen extends StatefulWidget {
  const BuyingSheetScreen({super.key});

  @override
  State<BuyingSheetScreen> createState() => _BuyingSheetScreenState();
}

class _BuyingSheetScreenState extends State<BuyingSheetScreen> {
  String? _selectedCategory;
  String? _selectedSupplier;
  String? _selectedPreviousOrder;
  String? _selectedOrderUom;
  late List<TextEditingController> orderQtyControllers;
  bool _selectAll = false;

  late List<CategoryListModel> _categories = [];
  late List<SupplierListModel> _suppliers = [];
  late List<UomListModel> _oum = [];
  bool _isLoading = false;
  List<BuyingSheetListModel> buyingSheet = [];

  final List<String> _previousOrders = [
    'Order 1',
    'Order 2',
    'Order 3',
  ];

  Future<void> getBuyingSheetList({
    required String prmFrmDate,
    required String prmToDate,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      String prmBrId = prefs.getString('brId')!;
      String prmFaId = prefs.getString('faId')!;
      String prmUId = prefs.getString('userId')!;
      final response = await ApiServices().fnGetBuyingSheetList(
        prmFrmDate: prmFrmDate,
        prmToDate: prmToDate,
        prmCmpId: prmCmpId,
        prmBrId: prmBrId,
        prmFaId: prmFaId,
        prmUId: prmUId,
        prmItmGrpId: '0',
      );
      if (response.isNotEmpty) {
        buyingSheet = response;
      } else {
        throw ('No Sales Order Found');
      }
    } catch (e) {
      throw ('No Sales Order Found');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    orderQtyControllers = List.generate(
      buyingSheet.length,
      (index) => TextEditingController(text: buyingSheet[index].odrEQty),
    );
  }

  String _formatDate(DateTime dte) {
    DateFormat date = DateFormat('dd/MMM/yyyy');
    return date.format(dte);
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await getBuyingSheetList(
        prmFrmDate: _formatDate(DateTime.now()).toString(),
        prmToDate: _formatDate(DateTime.now().add(Duration(days: 1))).toString(),
      );
      final categories = await getCategoryList();
      final suppliers = await getSupplierList();
      final oum = await getOumList();
      setState(() {
        _categories = categories;
        _suppliers = suppliers;
        _oum = oum;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      Util.customErrorSnackbar(
        context,
        'Category, Suppliers and Previous order not ready!',
      );
      if (kDebugMode) {
        print('Error loading dropdowns: $e');
      }
    }
  }

  @override
  void dispose() {
    for (var controller in orderQtyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<List<CategoryListModel>> getCategoryList() async {
    try {
      final response =
          await ApiServices().getCategoryList(prmCompanyId: prmCompanyId);
      if (response.isNotEmpty) {
        return response;
      } else {
        throw Exception('No Category found');
      }
    } catch (e) {
      throw Exception('No Category found');
    }
  }

  Future<List<SupplierListModel>> getSupplierList() async {
    try {
      final response =
          await ApiServices().getSupplierList(prmCompanyId: prmCompanyId);
      if (response.isNotEmpty) {
        return response;
      } else {
        throw Exception('No Supplier found');
      }
    } catch (e) {
      throw Exception('No Supplier found');
    }
  }

  Future<List<UomListModel>> getOumList() async {
    try {
      final response =
          await ApiServices().getUomList(prmCompanyId: prmCompanyId);
      if (response.isNotEmpty) {
        return response;
      } else {
        throw Exception('No Oum List found');
      }
    } catch (e) {
      throw Exception('No Oum List found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenCustomScaffold(
      bodyWidget: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) {
            return;
          }
          showDialog(
            barrierColor: Colors.black.withValues(alpha: 0.8),
            context: context,
            builder: (context) => const ScreenCustomExitConfirmation(),
          );
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Text(
                      'Buying Sheet',
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildSearchRow(),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.black,
                        size: 40.0,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              const CustomLogoutConfirmation(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Divider(
                  color: Colors.black,
                  thickness: 2,
                ),
                const SizedBox(height: 2),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Code',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Con Val',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Order Qty',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        flex: 1,
                        child: _buildOrderUomDropdown(),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Rate',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          minimumSize: const Size(150, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {},
                        child: Text('Add'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(120, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectAll = !_selectAll;
                            for (var item in buyingSheet) {
                              item.isSelected = _selectAll;
                            }
                          });
                        },
                        child: Text(_selectAll ? 'Deselect All' : 'Select All'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buyingSheetTable(data: buyingSheet),
                const SizedBox(height: 10),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Expanded(
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: _buildCategoryDropdown(),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 3,
            child: _buildSupplierDropdown(),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 3,
            child: _buildPreviousOrderDropdown(),
          ),
          Spacer(),
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    if (_isLoading) {
      return _buildDropdownButtonFormField(
          hint: 'Category', value: '', items: [], onChanged: (value) {});
    }
    return _buildDropdownButtonFormField(
      hint: 'Category',
      value: _selectedCategory,
      items: _categories.map((category) => category.name).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  Widget _buildSupplierDropdown() {
    if (_isLoading) {
      return _buildDropdownButtonFormField(
          hint: 'Supplier', value: '', items: [], onChanged: (value) {});
    }
    return _buildDropdownButtonFormField(
      hint: 'Supplier',
      value: _selectedSupplier,
      items: _suppliers.map((supplier) => supplier.name).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSupplier = value;
        });
      },
    );
  }

  Widget _buildOrderUomDropdown() {
    if (_isLoading) {
      return _buildDropdownButtonFormField(
          hint: 'UOM', value: '', items: [], onChanged: (value) {});
    }
    return _buildDropdownButtonFormField(
      hint: 'UOM',
      value: _selectedOrderUom,
      items: _oum.map((oum) => oum.name).toList(),
      onChanged: (value) {
        setState(() {
          _selectedOrderUom = value;
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
    return SizedBox(
      height: 50,
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _handleSearch,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: buttonColor,
          maximumSize: const Size(100, 50),
          minimumSize: const Size(100, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Search'),
      ),
    );
  }

  void _handleSearch() {
    if (_selectedCategory == null || _selectedSupplier == null) {
      Util.customErrorSnackbar(
        context,
        'Please select Category and Subcategory!',
      );
    }
    if (_selectedCategory != null && _selectedSupplier != null) {
      Util.customErrorSnackbar(
        context,
        'Categories and Subcategories are not yet added!',
      );
    }
  }

  Widget _buyingSheetTable({required List<BuyingSheetListModel> data}) {
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
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: DataTable(
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 60,
                  horizontalMargin: 10,
                  columnSpacing: 10,
                  headingRowColor: WidgetStateProperty.all(
                    Colors.grey.shade400.withValues(alpha: 0.5),
                  ),
                  border: TableBorder.symmetric(
                    inside: const BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  columns: _getTableColumns(),
                  rows: data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildDataRow(item, index);
                  }).toList(),
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
      'Code',
      'Name',
      'Con Val',
      'Short \nBulk',
      'Short \nSplit',
      'Order \nUOM',
      'Order Qty',
      'Rate',
      'Select'
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

  DataRow _buildDataRow(BuyingSheetListModel item, int index) {
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          return index.isEven ? Colors.amber.shade50 : Colors.amber.shade100;
        },
      ),
      cells: [
        _buildDataCell(item.itemCode),
        _buildDataCell(item.itemName),
        _buildEditTextDataCell(TextEditingController(text: item.uomConVal)),
        _buildDataCell(
            item.boxQty), // Changed from eachQty to boxQty for Short Bulk
        _buildDataCell(item.eachQty), // For Short Split
        _buildBulkSplitDropdownCell(item),
        _buildEditableDataCell(TextEditingController(
            text: item.odrEQty)), // Changed to odrEQty for Order Qty
        _buildEditTextDataCell(TextEditingController(
            text: item.uomConVal)), // Using uomConVal for Rate
        _buildCheckboxDataCell(item),
      ],
    );
  }

  DataCell _buildDataCell(String? text) {
    return DataCell(
      SizedBox(
        height: 20,
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

  DataCell _buildBulkSplitDropdownCell(BuyingSheetListModel item) {
    //TODO: Add dropdown for Bulk and Split
    return DataCell(
      Center(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: 'Bulk',
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
                item.boxQty = newValue!;
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
          width: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () => _decrementValue(controller),
                  icon: const Icon(Icons.remove)),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Enter value',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              IconButton(
                  onPressed: () => _incrementValue(controller),
                  icon: const Icon(Icons.add)),
            ],
          ),
        ),
      ),
    );
  }

  DataCell _buildEditTextDataCell(TextEditingController controller) {
    return DataCell(
      Center(
        child: SizedBox(
          width: 70,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
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

  DataCell _buildCheckboxDataCell(BuyingSheetListModel item) {
    return DataCell(
      Center(
        child: Transform.scale(
          scale: 2.5,
          child: Checkbox(
            activeColor: Colors.black,
            checkColor: Colors.black,
            fillColor: WidgetStateProperty.all(Colors.white),
            value: item.isSelected,
            side: const BorderSide(color: Colors.black, width: 1),
            onChanged: (bool? value) {
              setState(() {
                item.isSelected = value ?? false;
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
      child: const Text('Order Now'),
    );
  }
}
