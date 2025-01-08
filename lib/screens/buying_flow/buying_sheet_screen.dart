import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:williams/constants.dart';
import 'package:williams/custom_widgets/custom_scaffold.dart';

import '../../common/custom_overlay_loading.dart';
import '../../custom_widgets/custom_exit_confirmation.dart';
import '../../custom_widgets/custom_logout_button.dart';
import '../../custom_widgets/custom_spinning_logo.dart';
import '../../custom_widgets/util_class.dart';
import '../../models/buying_sheet_list_order_model.dart';
import '../../models/category_list_model.dart';
import '../../models/item_list_model.dart';
import '../../models/supplier_list_model.dart';
import '../../models/uom_list_model.dart';
import '../../services/api_services.dart';

class BuyingSheetScreen extends StatefulWidget {
  const BuyingSheetScreen({super.key});

  @override
  State<BuyingSheetScreen> createState() => _BuyingSheetScreenState();
}

class _BuyingSheetScreenState extends State<BuyingSheetScreen> {
  DateTimeRange? selectedDateRange;
  CategoryListModel? _selectedCategory;
  SupplierListModel? _selectedSupplier;
  String? _selectedPreviousOrder;
  UomAndPackListModel? _selectedOrderUom;
  late List<UomAndPackListModel> _selectedOrderTableUom;
  late List<TextEditingController> _orderQtyControllers;
  late List<TextEditingController> _conValControllers;
  late List<TextEditingController> _rateControllers;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemConValController = TextEditingController();
  final TextEditingController _itemOrderQtyController = TextEditingController();
  final TextEditingController _itemRateController = TextEditingController();
  bool _selectAll = false;
  late List<CategoryListModel> _categories = [];
  late List<SupplierListModel> _suppliers = [];
  late List<UomAndPackListModel> _oum = [];
  late List<ItemListModel> _items = [];
  bool _isLoading = false;
  List<BuyingSheetListModel> _buyingSheet = [];
  ItemListModel? selectedItem;

  bool btnIsEnabled = false;

  final List<String> _previousOrders = [
    'Order 1',
    'Order 2',
    'Order 3',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenCustomScaffold(
      resizeToAvoidBottomInset: false,
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
        child: _isLoading
            ? CustomLogoSpinner(
                color: Colors.black,
              )
            : Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Row(
                      children: [
                        const Text(
                          'Buying Sheet',
                          style: TextStyle(
                            fontSize: 35.0,
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
                  ),
                  const SizedBox(height: 2),
                  Divider(
                    color: Colors.black,
                    thickness: 2,
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Autocomplete<ItemListModel>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<ItemListModel>.empty();
                              }
                              return _items.where((ItemListModel option) {
                                return option.code.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase());
                              });
                            },
                            onSelected: (ItemListModel selection) async {
                              setState(() {
                                selectedItem = selection;
                              });
                            },
                            fieldViewBuilder: (BuildContext context,
                                editingCurrentSupervisorController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted) {
                              return TextFormField(
                                controller: editingCurrentSupervisorController,
                                focusNode: fieldFocusNode,
                                decoration: InputDecoration(
                                  labelText: 'Code',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onFieldSubmitted: (String value) {
                                  onFieldSubmitted();
                                },
                              );
                            },
                            optionsViewBuilder: (BuildContext context,
                                AutocompleteOnSelected<ItemListModel>
                                    onSelected,
                                Iterable<ItemListModel> options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  color: Colors.transparent,
                                  elevation: 25,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      top: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      // Background color
                                      borderRadius: BorderRadius.circular(10),
                                      // Border radius
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2,
                                      ), // Border color
                                    ),
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                      maxWidth: 600,
                                    ),
                                    child: ListView(
                                      padding: const EdgeInsets.all(10.0),
                                      children:
                                          options.map((ItemListModel option) {
                                        return GestureDetector(
                                          onTap: () {
                                            onSelected(option);
                                            _itemNameController.text =
                                                option.name;
                                            _itemConValController.text =
                                                option.conVal;
                                            _itemRateController.text =
                                                option.bulkRate;
                                            selectedItem = option;
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    option.code,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 400,
                                                  child: Text(
                                                    '    ${option.name}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                  child: Text(
                                                    '    ${option.bulkRate}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _itemNameController,
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
                            controller: _itemConValController,
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
                            controller: _itemOrderQtyController,
                            decoration: InputDecoration(
                              labelText: 'Order Qty',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          flex: 1,
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButtonFormField<UomAndPackListModel>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items: _oum
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name),
                                    ),
                                  )
                                  .toList(),
                              value: _selectedOrderUom,
                              hint: const Text('UOM'),
                              onChanged: (UomAndPackListModel? value) {
                                setState(() {
                                  _selectedOrderUom = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _itemRateController,
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
                          onPressed: () {
                            if (selectedItem == null ||
                                _selectedOrderUom == null) {
                              Util.customErrorSnackBar(
                                context,
                                'Please select an item and UOM first',
                              );
                              return;
                            }

                            // Create new controllers
                            final newOrderQtyController = TextEditingController(
                                text: _itemOrderQtyController.text);
                            final newConValController = TextEditingController(
                                text: _itemConValController.text);
                            final newRateController = TextEditingController(
                                text: _itemRateController.text);

                            setState(() {
                              _orderQtyControllers.insert(
                                  0, newOrderQtyController);
                              _conValControllers.insert(0, newConValController);
                              _rateControllers.insert(0, newRateController);
                              _selectedOrderTableUom.insert(
                                  0, _selectedOrderUom!);

                              _buyingSheet.insert(
                                0,
                                BuyingSheetListModel(
                                  itemId: selectedItem!.id,
                                  itemName: _itemNameController.text,
                                  itemCode: selectedItem!.code,
                                  uom: _selectedOrderUom!.name,
                                  itemGroup: selectedItem!.itemGroup,
                                  boxQty: _itemOrderQtyController.text,
                                  eachQty: _itemRateController.text,
                                  odrBQty: '',
                                  odrEQty: _itemOrderQtyController.text,
                                  boxUomId: _selectedOrderUom!.id,
                                  uomConVal: _itemConValController.text,
                                  itmCnt: '0',
                                  isSelected: false,
                                ),
                              );

                              _itemNameController.clear();
                              _itemConValController.clear();
                              _itemOrderQtyController.clear();
                              _itemRateController.clear();
                              selectedItem = null;
                              _selectedOrderUom = null;
                            });
                          },
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
                              for (var item in _buyingSheet) {
                                item.isSelected = _selectAll;
                              }
                              if (_selectAll) {
                                _fnCheckSelection();
                              }
                            });
                          },
                          child:
                              Text(_selectAll ? 'Deselect All' : 'Select All'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buyingSheet.isEmpty
                        ? SizedBox()
                        : _buyingSheetTable(data: _buyingSheet),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: _buyingSheet.isEmpty
                        ? SizedBox()
                        : Align(
                            alignment: Alignment.centerRight,
                            child: _buildSaveButton(),
                          ),
                  ),
                ],
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
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField<CategoryListModel>(
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _categories
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                value: _selectedCategory,
                hint: const Text('Category'),
                onChanged: (CategoryListModel? value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 3,
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField<SupplierListModel>(
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _suppliers
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                value: _selectedSupplier,
                hint: const Text('Supplier'),
                onChanged: (SupplierListModel? value) {
                  setState(() {
                    _selectedSupplier = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 3,
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _previousOrders
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                value: _selectedPreviousOrder,
                hint: const Text('Previous Order'),
                onChanged: (value) {
                  setState(() {
                    _selectedPreviousOrder = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                minimumSize: const Size(50, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: _showDateRangePicker,
              child:
                  const Icon(Icons.date_range, color: Colors.white, size: 30),
            ),
          ),
          Spacer(),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: selectedDateRange != null
                  ? () async {
                      await getBuyingSheetList(
                        prmFrmDate:
                            _formatDate(selectedDateRange!.start).toString(),
                        prmToDate: _formatDate(selectedDateRange!.end),
                        prmCategory: _selectedCategory?.id ?? '',
                        prmSupplier: _selectedSupplier?.id ?? '',
                        prmPreviousOrder: _selectedPreviousOrder ?? '',
                      );
                    }
                  : null,
              // onPressed: _handleSearch,
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
          ),
        ],
      ),
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now().add(Duration(days: 1)),
      currentDate: DateTime.now(),
      saveText: 'Done',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (result != null) {
      setState(() {
        selectedDateRange = result;
      });
    }
  }

  String _formatDate(DateTime dte) {
    try {
      DateFormat date = DateFormat('dd/MMM/yyyy');
      return date.format(dte);
    } catch (e) {
      return '';
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final categories = await getCategoryList();
      final suppliers = await getSupplierList();
      final oum = await getOumList();
      final items = await getItemList();

      _categories = categories;
      _suppliers = suppliers;
      _items = items;
      _oum = oum;

      await getBuyingSheetList(
        prmFrmDate:
            _formatDate(DateTime.now().subtract(Duration(days: 5))).toString(),
        prmToDate:
            _formatDate(DateTime.now().add(Duration(days: 1))).toString(),
        prmCategory: '',
        prmSupplier: '',
        prmPreviousOrder: '',
      );
      _orderQtyControllers = List.generate(
        _buyingSheet.length,
        (index) => TextEditingController(text: _buyingSheet[index].odrEQty),
      );
      // _selectedOrderTableUom = List.generate(
      //   _buyingSheet.length,
      //   (index) => _oum.where((e) => e.id == _buyingSheet[index].boxUomId).first,
      // ); TODO: Uncomment this line after adding UOM in BuyingSheetListModel
      // _selectedOrderTableUom = List.generate(
      //   _buyingSheet.length,
      //   (index) => _oum.first,
      // ); // TODO: Remove this line after adding UOM in BuyingSheetListModel
      _conValControllers = List.generate(
        _buyingSheet.length,
        (index) => TextEditingController(text: _buyingSheet[index].uomConVal),
      );
      _rateControllers = List.generate(
        _buyingSheet.length,
        (index) => TextEditingController(text: _buyingSheet[index].eachQty),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      Util.customErrorSnackBar(
        context,
        'Category, Suppliers or Previous order not ready!',
      );
      debugPrint('Error loading dropdowns: $e');
    }
  }

  Future<List<CategoryListModel>> getCategoryList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      final response =
          await ApiServices().getCategoryList(prmCompanyId: prmCmpId);
      if (response.isNotEmpty) {
        return response;
      } else {
        throw ('No Category found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SupplierListModel>> getSupplierList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      final response =
          await ApiServices().getSupplierList(prmCompanyId: prmCmpId);
      if (response.isNotEmpty) {
        return response;
      } else {
        throw ('No Supplier found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UomAndPackListModel>> getOumList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      final response =
          await ApiServices().getPackingType(prmCompanyId: prmCmpId);
      if (response.isNotEmpty) {
        return response;
      } else {
        throw ('No Oum List found');
      }
    } catch (e) {
      rethrow;
    }
  }

//todo: check the logic
  Future _fnCheckSelection() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      String prmBrId = prefs.getString('brId')!;
      String prmFaId = prefs.getString('faId')!;
      String prmUId = prefs.getString('userId')!;
      final response = await ApiServices().fnCheckSelection(
        prmOrderId: '0',
        prmCmpId: prmCmpId,
        prmBrId: prmBrId,
        prmFaId: prmFaId,
        prmUId: prmUId,
      );
    } catch (e) {
      debugPrint("Error in fnCheckSelection: ${e.toString()}");
    }
  }

  Future getBuyingSheetList({
    required String prmFrmDate,
    required String prmToDate,
    required String prmCategory,
    required String prmSupplier,
    required String prmPreviousOrder,
  }) async {
    try {
      showDialog(
        barrierColor: Colors.black.withValues(alpha: 0.8),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const CustomOverlayLoading();
        },
      );
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
        _buyingSheet = response;
        _orderQtyControllers = List.generate(
          _buyingSheet.length,
          (index) => TextEditingController(text: _buyingSheet[index].odrEQty),
        );
        // _selectedOrderTableUom = List.generate(
        //   _buyingSheet.length,
        //   (index) => _oum.where((e) => e.id == _buyingSheet[index].boxUomId).first,
        // ); TODO: Uncomment this line after adding UOM in BuyingSheetListModel

        _selectedOrderTableUom = List.generate(
          _buyingSheet.length,
          (index) => _oum.first,
        ); // TODO: Remove this line after adding UOM in BuyingSheetListModel
        _conValControllers = List.generate(
          _buyingSheet.length,
          (index) => TextEditingController(text: _buyingSheet[index].uomConVal),
        );
        _rateControllers = List.generate(
          _buyingSheet.length,
          (index) => TextEditingController(text: _buyingSheet[index].eachQty),
        );
        setState(() {});
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        throw ('No Items Found');
      }
    } catch (e) {
      _buyingSheet = [];
      Navigator.pop(context);
      debugPrint(e.toString());
      if (!mounted) return;
      Util.customErrorSnackBar(context, e.toString());
    }
  }

  Future<List<ItemListModel>> getItemList() async {
    try {
      final response = await ApiServices().getItemList();
      if (response.isNotEmpty) {
        return response;
      } else {
        throw ('No Items Found');
      }
    } catch (e) {
      throw ('No Items Found');
    }
  }

  Widget _buyingSheetTable({required List<BuyingSheetListModel> data}) {
    return Container(
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
        child: SingleChildScrollView(
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
        _buildNameCell(item.itemName),
        _buildEditTextDataCell(
          _conValControllers[index],
        ),
        _buildDataCell(
          item.boxQty,
        ),
        _buildDataCell(item.eachQty), // For Short Split
        _buildBulkSplitDropdownCell(item, index),
        _buildEditableDataCell(
          _orderQtyControllers[index],
        ),
        _buildEditTextDataCell(
          _rateControllers[index],
        ),
        _buildCheckboxDataCell(item),
      ],
    );
  }

  DataCell _buildDataCell(
    String? text,
  ) {
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

  DataCell _buildNameCell(
    String? text,
  ) {
    return DataCell(
      SizedBox(
        height: 20,
        width: MediaQuery.of(context).size.width * 0.3,
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

  DataCell _buildBulkSplitDropdownCell(BuyingSheetListModel item, int index) {
    return DataCell(
      Center(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<UomAndPackListModel>(
            isExpanded: true,
            underline: Container(),
            items: _oum
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.name),
                  ),
                )
                .toList(),
            value: _selectedOrderTableUom[index],
            hint: const Text('Order UOM'),
            onChanged: (UomAndPackListModel? value) {
              setState(() {
                _selectedOrderTableUom[index] = value!;
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
                  onChanged: (value) {
                    controller.text = value;
                  },
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
    try {
      double currentValue =
          double.parse(controller.text.isEmpty ? '0' : controller.text);
      controller.text = (currentValue + 1).toString();
    } catch (e) {
      controller.text = 'error';
    }
  }

  void _decrementValue(TextEditingController controller) {
    double currentValue = double.parse(controller.text);
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
        // Util.customSuccessSnackBar(
        //   context,
        //   'Saved Successfully!',
        // );
        _orderNow();
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

  Future<void> _orderNow() async {
    try {
      showDialog(
        barrierColor: Colors.black.withValues(alpha: 0.8),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const CustomOverlayLoading();
        },
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      String prmBrId = prefs.getString('brId')!;
      String prmFaId = prefs.getString('faId')!;
      String prmUId = prefs.getString('userId')!;
      String prmAccId = prefs.getString('accId')!;

      final String tokenNo = await ApiServices().fnGetTokenNoUrl(
        prmCmpId: prmCmpId,
        prmBrId: prmBrId,
        prmFaId: prmFaId,
      );
      //TODO:bug fix
      for (int i = 0; i < _buyingSheet.length; i++) {
        await ApiServices().fnSavePoList(
          prmTokenNo: tokenNo,
          prmDatePrmToCnt: _formatDate(DateTime.now()),
          prmCurntCnt: (i + 1).toString(),
          PrmToCnt: _buyingSheet.length.toString(),
          prmAccId: prmAccId,
          prmItemId: _buyingSheet[i].itemId,
          prmUomId: _buyingSheet[i].boxUomId,
          prmTaxId: '',
          prmPackId: _selectedOrderTableUom[i].id,
          prmNoPacks: _orderQtyControllers[i].text,
          prmConVal: _conValControllers[i].text,
          prmCmpId: prmCmpId,
          prmBrId: prmBrId,
          prmFaId: prmFaId,
          prmUId: prmUId,
          prmRate: _rateControllers[i].text,
        );
      }
      _buyingSheet.clear();
      Navigator.pop(context);
      Util.customSuccessSnackBar(context, 'Order saved successfully');
    } catch (e) {
      Navigator.pop(context);
      Util.customErrorSnackBar(context, 'Error: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    for (var controller in _orderQtyControllers) {
      controller.dispose();
    }
    _itemNameController.dispose();
    _itemConValController.dispose();
    _itemOrderQtyController.dispose();
    _itemRateController.dispose();
    super.dispose();
  }
}
