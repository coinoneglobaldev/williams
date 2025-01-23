import 'dart:developer';

import 'package:data_table_2/data_table_2.dart';
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
import '../../models/PreviousOrderCountModel.dart';
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
  FocusNode _orderQtyFocus = FocusNode();
  FocusNode _rateFocus = FocusNode();
  DateTimeRange? selectedDateRange;
  CategoryListModel? _selectedCategory;
  SupplierListModel? _selectedSupplier;
  PreviousOrderCountModel? _selectedPreviousOrder;
  UomAndPackListModel? _selectedOrderUom;
  late List<UomAndPackListModel> _selectedOrderTableUom;
  late List<TextEditingController> _orderQtyControllers;
  late List<TextEditingController> _rateControllers;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemConValController = TextEditingController();
  final TextEditingController _itemOrderQtyController = TextEditingController();
  final TextEditingController _itemRateController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _billNoController = TextEditingController();
  bool _selectAll = false;
  late List<CategoryListModel> _categories = [];
  late List<SupplierListModel> _suppliers = [];
  late List<UomAndPackListModel> _oum = [];
  late List<ItemListModel> _items = [];
  late List<PreviousOrderCountModel> _previousOrders;
  bool _isLoading = false;
  List<BuyingSheetListModel> _buyingSheet = [];
  ItemListModel? selectedItem;

  bool btnIsEnabled = false;

  int _selectedCount = 0;

  double _totalAmount = 0.0;

  int selectedRowIndex = 0;
  bool isQtyCtrlSelected = false;
  bool isBillNoSelected = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    selectedDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: 1)),
    );
  }

  void calculateTotalAmount({
    required List<BuyingSheetListModel> buyingSheet,
  }) {
    _totalAmount = buyingSheet
        .asMap()
        .entries
        .where((entry) => entry.value.isSelected)
        .map((entry) {
      try {
        final rate = double.parse(entry.value.rate);
        final quantity = double.parse(entry.value.totalQty);
        return rate * quantity.ceil();
      } catch (e) {
        return 0.0;
      }
    }).fold(0, (sum, amount) => sum + amount);
    setState(() {});
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
                            onSelected: (ItemListModel selection) {
                              setState(() {
                                selectedItem = selection;
                                _codeController.text = selection.code;
                                _itemNameController.text = selection.name;
                                _itemConValController.text = selection.conVal;
                                _itemRateController.text = selection.bulkRate;
                                _selectedOrderUom = _oum
                                    .where(
                                      (e) => e.id == '19',
                                    )
                                    .first;
                              });
                              _itemOrderQtyController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset:
                                    _itemOrderQtyController.text.length,
                              );
                              _orderQtyFocus.requestFocus();
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController fieldController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted) {
                              if (_codeController.text !=
                                  fieldController.text) {
                                fieldController.text = _codeController.text;
                              }

                              return TextFormField(
                                controller: fieldController,
                                focusNode: fieldFocusNode,
                                decoration: InputDecoration(
                                  labelText: 'Code',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onChanged: (value) {
                                  _codeController.text = value;
                                },
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
                                    margin: const EdgeInsets.only(top: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2,
                                      ),
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
                            readOnly: true,
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
                            keyboardType: TextInputType.number,
                            onTap: () {
                              // Changed this line
                              _itemConValController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: _itemConValController.text.length,
                              );
                            },
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
                            keyboardType: TextInputType.number,
                            controller: _itemOrderQtyController,
                            onSubmitted: (value) {
                              // Select all text in the TextField
                              _itemRateController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: _itemRateController.text.length,
                              );
                              // Reqest focus on the TextField
                              _rateFocus.requestFocus();
                            },
                            focusNode: _orderQtyFocus,
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
                            focusNode: _rateFocus,
                            controller: _itemRateController,
                            keyboardType: TextInputType.number,
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
                            double split = 0;
                            double bulk = 0;
                            double actualNeededQty = 0;
                            if (selectedItem == null ||
                                _selectedOrderUom == null) {
                              Util.customErrorSnackBar(
                                context,
                                'Please select an item and UOM first',
                              );
                              return;
                            }
                            try {
                              int roundedOrderQty =
                                  double.parse(_itemOrderQtyController.text)
                                      .ceil();
                              // Create new controllers
                              final newOrderQtyController =
                                  TextEditingController(
                                      text: roundedOrderQty.toString());

                              final newRateController = TextEditingController(
                                  text: _itemRateController.text);

                              if (double.parse(_itemConValController.text) ==
                                  1) {
                                split =
                                    double.parse(_itemOrderQtyController.text);
                              } else {
                                actualNeededQty =
                                    double.parse(selectedItem!.eStockQty) -
                                        double.parse(_itemOrderQtyController
                                            .text
                                            .toString());

                                split = actualNeededQty.abs() %
                                    double.parse(_itemConValController.text);

                                double semiBulk = actualNeededQty.abs() -
                                    (actualNeededQty.abs() %
                                        double.parse(
                                            _itemConValController.text));
                                bulk = semiBulk.abs() /
                                    double.parse(
                                        _itemConValController.text.toString());
                              }
                              setState(() {
                                _orderQtyControllers.insert(
                                    0, newOrderQtyController);
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
                                    odrBQty: bulk.abs().ceil().toString(),
                                    odrEQty: split.abs().ceil().toString(),
                                    rate: _itemRateController.text,
                                    boxUomId: _selectedOrderUom!.id,
                                    uomConVal: _itemConValController.text,
                                    itmCnt: '0',
                                    isSelected: true,
                                    totalQty: _itemOrderQtyController.text,
                                    eStockQty:
                                        selectedItem!.eStockQty.toString(),
                                    actualNeededQty: actualNeededQty.toString(),
                                  ),
                                );
                                _selectedCount = _buyingSheet
                                    .where((item) => item.isSelected)
                                    .length;
                                calculateTotalAmount(
                                  buyingSheet: _buyingSheet,
                                );
                                setState(() {});
                                _codeController.clear();
                                _itemNameController.clear();
                                _itemConValController.clear();
                                _itemOrderQtyController.clear();
                                _itemRateController.clear();
                                selectedItem = null;
                                _selectedOrderUom = null;
                              });
                            } catch (e) {
                              print('Error adding item to buying sheet: $e');
                            }
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
                              _selectedCount = _buyingSheet
                                  .where((item) => item.isSelected)
                                  .length;

                              if (_selectAll) {
                                calculateTotalAmount(
                                  buyingSheet: _buyingSheet,
                                );
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buyingSheet.isEmpty
                              ? SizedBox()
                              : _buyingSheetTable(data: _buyingSheet),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // SizedBox(
                              //   height:
                              //       MediaQuery.of(context).size.height * 0.25,
                              // ),
                              Expanded(
                                child: Row(
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
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
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
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
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
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: _calculatorContainer(
                                        value: '.',
                                      ),
                                    ),
                                    Expanded(
                                      child: _calculatorContainer(
                                        value: '0',
                                      ),
                                    ),
                                    Expanded(
                                      child: _calculatorContainer(
                                        value: 'C',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 10),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Total Items: ${_buyingSheet.length}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          "Date: ${selectedDateRange != null ? _formatDate(selectedDateRange!.start) + ' - ' + _formatDate(selectedDateRange!.end) : _formatDate(DateTime.now()).toString() + ' - ' + _formatDate(DateTime.now().add(Duration(days: 1))).toString()}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Total Amount : £ ${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _billNoController,
                          readOnly: true,
                          onTap: () {
                            _billNoController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _billNoController.text.length,
                            );
                            setState(() {
                              isBillNoSelected = true;
                              isQtyCtrlSelected = false;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Bill No.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 50,
                          child: _buyingSheet.isEmpty
                              ? SizedBox()
                              : _buildSaveButton(),
                        ),
                      ),
                    ],
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
                  try {
                    getBuyingSheetList(
                      prmFrmDate: selectedDateRange != null
                          ? _formatDate(selectedDateRange!.start)
                          : _formatDate(DateTime.now()).toString(),
                      prmToDate: selectedDateRange != null
                          ? _formatDate(selectedDateRange!.end)
                          : _formatDate(DateTime.now().add(Duration(days: 1)))
                              .toString(),
                      prmCategory: _selectedCategory!.id,
                      prmSupplier: _selectedSupplier?.id ?? '',
                      prmPreviousOrder: _selectedPreviousOrder?.id ?? '',
                    ).whenComplete(() {
                      _selectAll = false;
                      _selectedCount = 0;
                      _totalAmount = 0.0;
                      setState(() {});
                    });
                  } catch (e) {
                    Util.customErrorSnackBar(context, e.toString());
                  }
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
                  try {
                    getBuyingSheetList(
                      prmFrmDate: selectedDateRange != null
                          ? _formatDate(selectedDateRange!.start)
                          : _formatDate(DateTime.now()).toString(),
                      prmToDate: selectedDateRange != null
                          ? _formatDate(selectedDateRange!.end)
                          : _formatDate(DateTime.now().add(Duration(days: 1)))
                              .toString(),
                      prmCategory: _selectedCategory?.id ?? '',
                      prmSupplier: _selectedSupplier?.id ?? '',
                      prmPreviousOrder: _selectedPreviousOrder?.id ?? '',
                    ).whenComplete(() {
                      _selectAll = false;
                      _selectedCount = 0;
                      _totalAmount = 0.0;
                      setState(() {});
                    });
                  } catch (e) {
                    Util.customErrorSnackBar(context, e.toString());
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 3,
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField<PreviousOrderCountModel>(
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
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                value: _selectedPreviousOrder,
                hint: const Text('Previous Order'),
                onChanged: (value) {
                  setState(() {
                    _selectedPreviousOrder = value;
                  });
                  try {
                    getBuyingSheetList(
                      prmFrmDate: selectedDateRange != null
                          ? _formatDate(selectedDateRange!.start)
                          : _formatDate(DateTime.now()).toString(),
                      prmToDate: selectedDateRange != null
                          ? _formatDate(selectedDateRange!.end)
                          : _formatDate(DateTime.now().add(Duration(days: 1)))
                              .toString(),
                      prmCategory: _selectedCategory?.id ?? '',
                      prmSupplier: _selectedSupplier?.id ?? '',
                      prmPreviousOrder: _selectedPreviousOrder?.id ?? '',
                    ).whenComplete(() {
                      _selectAll = false;
                      _selectedCount = 0;
                      _totalAmount = 0.0;
                      setState(() {});
                    });
                  } catch (e) {
                    Util.customErrorSnackBar(context, e.toString());
                  }
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
                        prmPreviousOrder: _selectedPreviousOrder?.id ?? '',
                      );
                      setState(() {
                        _selectAll = false;
                      });
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
      final previousOrder = await getPreviousOrderCount();

      _categories = categories;
      _categories.insert(
        0,
        CategoryListModel(
          id: '0',
          name: 'All Categories',
          code: '',
        ),
      );
      _suppliers = suppliers;
      _suppliers.insert(
        0,
        SupplierListModel(
          id: '0',
          name: 'All Suppliers',
          code: '',
          address: '',
          email: '',
          mobNo: '',
          phoneNo: '',
        ),
      );
      _items = items;
      _oum = oum;
      _previousOrders = previousOrder;

      await getBuyingSheetList(
        prmFrmDate: _formatDate(DateTime.now()).toString(),
        prmToDate:
            _formatDate(DateTime.now().add(Duration(days: 1))).toString(),
        prmCategory: '',
        prmSupplier: '',
        prmPreviousOrder: '',
      );

      _orderQtyControllers = List.generate(
        _buyingSheet.length,
        (index) {
          double result = calculateRoundedValue(
            _buyingSheet[index].odrBQty,
            _buyingSheet[index].odrEQty,
            _buyingSheet[index].uomConVal,
          );
          _buyingSheet[index].totalQty = result.toString();
          return TextEditingController(text: result.toString());
        },
      );

      // _selectedOrderTableUom = List.generate(
      //   _buyingSheet.length,
      //   (index) => _oum.where((e) => e.id == _buyingSheet[index].boxUomId).first,
      // ); TODO: Uncomment this line after adding UOM in BuyingSheetListModel
      // _selectedOrderTableUom = List.generate(
      //   _buyingSheet.length,
      //   (index) => _oum.first,
      // ); // TODO: Remove this line after adding UOM in BuyingSheetListModel
      _rateControllers = List.generate(
        _buyingSheet.length,
        (index) => TextEditingController(text: _buyingSheet[index].rate),
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

  double calculateRoundedValue(
      String odrBQty, String odrEQty, String uomConVal) {
    try {
      double bulkQty = double.parse(odrBQty.isEmpty ? '0' : odrBQty);
      double eachQty = double.parse(odrEQty.isEmpty ? '0' : odrEQty);
      double conversionValue = double.parse(uomConVal);

      // If both bulk and each quantities exist
      if (bulkQty > 0 && eachQty > 0) {
        double bulkTotal = bulkQty * conversionValue;
        double totalQty = bulkTotal + eachQty;
        return (totalQty / conversionValue).ceil().toDouble();
      }

      // If only bulk quantity exists
      else if (bulkQty > 0 && (eachQty == 0)) {
        return bulkQty.ceil().toDouble();
      }

      // If only each quantity exists
      else if (eachQty > 0 && bulkQty == 0) {
        return eachQty.ceil().toDouble();
      }

      // If no quantities exist
      return 0.0;
    } catch (e) {
      print('Error calculating rounded value: $e');
      return 0.0;
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
        prmItmGrpId: prmCategory,
        prmAccId: prmSupplier,
        prmPrvOrderCount: prmPreviousOrder,
      );
      if (response.isNotEmpty) {
        List<BuyingSheetListModel> _tempList = response;

        List.generate(_tempList.length, (index) {
          try {
            double actualNeededQty =
                double.parse(_tempList[index].eStockQty.toString()) -
                    double.parse(_tempList[index].odrEQty.toString());

            _tempList[index].actualNeededQty = actualNeededQty.abs().toString();
            return _tempList[index];
          } catch (e) {
            print('Error calculating actual needed qty: $e');
            return _tempList[index];
          }
        });

        List.generate(_tempList.length, (index) {
          try {
            if (double.parse(_tempList[index].uomConVal.toString()) == 1) {
              return _tempList[index];
            } else {
              double split =
                  double.parse(_tempList[index].actualNeededQty.toString()) %
                      double.parse(_tempList[index].uomConVal.toString());
              _tempList[index].odrEQty = split.abs().ceil().toString();
              return _tempList[index];
            }
          } catch (e) {
            print('Error calculating split: $e');
            return _tempList[index];
          }
        });

        List.generate(_tempList.length, (index) {
          try {
            if (double.parse(_tempList[index].uomConVal.toString()) == 1) {
              return _tempList[index].odrBQty = '0';
            } else {
              double semiBulk = double.parse(
                      _tempList[index].actualNeededQty.toString()) -
                  (double.parse(_tempList[index].actualNeededQty.toString()) %
                      double.parse(_tempList[index].uomConVal.toString()));
              double bulk = semiBulk.abs() /
                  double.parse(_tempList[index].uomConVal.toString());

              _tempList[index].odrBQty = bulk.abs().ceil().toString();
              return _tempList[index];
            }
          } catch (e) {
            print('Error calculating bulk: $e');
            return _tempList[index];
          }
        });
        _buyingSheet = _tempList;
        _selectedOrderTableUom = List.generate(
          _buyingSheet.length,
          (index) => _oum.first,
        );
        _orderQtyControllers = List.generate(
          _buyingSheet.length,
          (index) {
            double result = calculateRoundedValue(_buyingSheet[index].odrBQty,
                _buyingSheet[index].odrEQty, _buyingSheet[index].uomConVal);
            _buyingSheet[index].totalQty = result.toString();
            return TextEditingController(text: result.toString());
          },
        );

        _selectedOrderTableUom = List.generate(
          _buyingSheet.length,
          (index) {
            if (double.parse(_buyingSheet[index].odrBQty) > 0 &&
                double.parse(_buyingSheet[index].odrEQty) > 0) {
              return _selectedOrderTableUom[index] =
                  _oum.where((e) => e.id == '19').first;
            } else if (double.parse(_buyingSheet[index].odrBQty) > 0 &&
                double.parse(_buyingSheet[index].odrEQty) == 0) {
              return _selectedOrderTableUom[index] =
                  _oum.where((e) => e.id == '19').first;
            } else if (double.parse(_buyingSheet[index].odrEQty) > 0 &&
                double.parse(_buyingSheet[index].odrBQty) == 0) {
              return _selectedOrderTableUom[index] =
                  _oum.where((e) => e.id == '21').first;
            } else {
              return _selectedOrderTableUom[index] = _oum.first;
            }
          },
        ); // TODO: Remove this line after adding UOM in BuyingSheetListModel

        _rateControllers = List.generate(
          _buyingSheet.length,
          (index) => TextEditingController(text: _buyingSheet[index].rate),
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      String prmBrId = prefs.getString('brId')!;
      String prmFaId = prefs.getString('faId')!;
      final response = await ApiServices().getItemList(
          prmFrmDate: _formatDate(DateTime.now()).toString(),
          prmToDate:
              _formatDate(DateTime.now().add(Duration(days: 1))).toString(),
          prmCmpId: prmCmpId,
          prmBrId: prmBrId,
          prmFaId: prmFaId);
      if (response.isNotEmpty) {
        return response;
      } else {
        throw ('No Items Found');
      }
    } catch (e) {
      throw ('No Items Found');
    }
  }

  Future<List<PreviousOrderCountModel>> getPreviousOrderCount() async {
    try {
      final response = await ApiServices().getPreviousOrderCount();
      if (response.isNotEmpty) {
        return response;
      } else {
        throw ('No Previous Found');
      }
    } catch (e) {
      throw ('No Previous Found');
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
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: DataTable2(
          dataRowHeight: 60,
          horizontalMargin: 10,
          columnSpacing: 10,
          minWidth: 800,
          headingRowColor: WidgetStateProperty.all(
            Colors.grey.shade400.withValues(alpha: 0.5),
          ),
          border: TableBorder.symmetric(
            inside: const BorderSide(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          columns: [
            const DataColumn2(
              label: Center(
                child: Text(
                  'Code',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              size: ColumnSize.L,
              fixedWidth: 60,
            ),
            const DataColumn2(
              label: Center(
                child: Text(
                  'Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              size: ColumnSize.L,
              fixedWidth: 220,
            ),
            const DataColumn2(
              label: Center(
                child: Text(
                  'Con \nVal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              size: ColumnSize.L,
              fixedWidth: 60,
            ),
            const DataColumn2(
              label: Center(
                child: Text(
                  'Short \nBulk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              size: ColumnSize.L,
              fixedWidth: 60,
            ),
            const DataColumn2(
              label: Center(
                child: Text(
                  'Short \nBulk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              size: ColumnSize.L,
              fixedWidth: 60,
            ),
            const DataColumn2(
              label: Center(
                child: Text(
                  'Order \nUOM',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              size: ColumnSize.L,
              fixedWidth: 140,
            ),
            const DataColumn2(
              label: Center(
                child: Text(
                  'Order Qty',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              size: ColumnSize.L,
              fixedWidth: 150,
            ),
            const DataColumn2(
              label: Center(
                child: Text(
                  'Rate',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              size: ColumnSize.L,
              fixedWidth: 90,
            ),
            const DataColumn2(
              label: Center(
                child: Text(
                  'Select',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              size: ColumnSize.L,
            ),
          ],
          rows: data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return DataRow(
              color: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  return _selectedOrderTableUom[index].id == '19'
                      ? Colors.yellow
                      : Colors.green.shade200;
                },
              ),
              cells: [
                _buildDataCell(item.itemCode),
                DataCell(
                  // Special cell for Name column
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      item.itemName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                _buildDataCell(item.uomConVal),
                _buildDataCell(item.odrBQty),
                _buildDataCell(item.odrEQty),
                _buildBulkSplitDropdownCell(item, index),
                _buildEditableDataCell(_orderQtyControllers[index], index),
                _buildEditTextRateDataCell(_rateControllers[index], index),
                _buildCheckboxDataCell(item),
              ],
            );
          }).toList(),
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
          return _selectedOrderTableUom[index].id == '19'
              ? Colors.yellow
              : Colors.green.shade200;
        },
      ),
      cells: [
        _buildDataCell(item.itemCode),
        _buildDataCell(item.itemName),
        _buildDataCell(item.uomConVal),
        _buildDataCell(item.odrBQty),
        _buildDataCell(item.odrEQty),
        _buildBulkSplitDropdownCell(item, index),
        _buildEditableDataCell(_orderQtyControllers[index], index),
        _buildEditTextRateDataCell(_rateControllers[index], index),
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
            isDense: true,
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

  DataCell _buildEditableDataCell(TextEditingController controller, int index) {
    return DataCell(
      onTap: () {
        setState(() {
          selectedRowIndex = index;
          isQtyCtrlSelected = true;
          isBillNoSelected = false;
        });
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      },
      Center(
        child: SizedBox(
          width: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _decrementValue(controller, index),
                  icon: const Icon(Icons.remove)),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black),
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Enter value',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                  onTap: () {
                    setState(() {
                      selectedRowIndex = index;
                      isQtyCtrlSelected = true;
                      isBillNoSelected = false;
                    });
                    controller.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: controller.text.length,
                    );
                  },
                  onChanged: (value) {
                    controller.text = value;
                    _buyingSheet[index].totalQty = value.isEmpty ? '0' : value;
                    log('Order UOM: $value');
                    log('Order Qty: ${_buyingSheet[index].totalQty}');
                    print(_buyingSheet[index].totalQty);
                    print(value);
                    calculateTotalAmount(
                      buyingSheet: _buyingSheet,
                    );
                    setState(() {});
                  },
                ),
              ),
              IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _incrementValue(controller, index),
                  icon: const Icon(Icons.add)),
            ],
          ),
        ),
      ),
    );
  }

  DataCell _buildEditTextRateDataCell(
      TextEditingController controller, int index) {
    return DataCell(
      onTap: () {
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
        setState(() {
          selectedRowIndex = index;
          isQtyCtrlSelected = false;
          isBillNoSelected = false;
        });
      },
      Center(
        child: SizedBox(
          width: 70,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black),
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Enter value',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            onTap: () {
              setState(() {
                selectedRowIndex = index;
                isQtyCtrlSelected = false;
                isBillNoSelected = false;
              });
              controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              );
            },
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _buyingSheet[index].rate = value;

              calculateTotalAmount(
                buyingSheet: _buyingSheet,
              );

              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  void _incrementValue(TextEditingController controller, int index) {
    try {
      selectedRowIndex = index;
      isQtyCtrlSelected = true;
      isBillNoSelected = false;
      double currentValue =
          double.parse(controller.text.isEmpty ? '0' : controller.text);
      controller.text = (currentValue + 1).toString();
      _buyingSheet[index].totalQty = (currentValue + 1).toString();
      calculateTotalAmount(
        buyingSheet: _buyingSheet,
      );
      setState(() {});
    } catch (e) {
      controller.text = 'error';
    }
  }

  void _decrementValue(TextEditingController controller, int index) {
    try {
      selectedRowIndex = index;
      isQtyCtrlSelected = true;
      isBillNoSelected = false;

      double currentValue = double.parse(controller.text);
      if (currentValue > 0) {
        _buyingSheet[index].totalQty = (currentValue - 1).toString();
        controller.text = (currentValue - 1).toString();
      }
      calculateTotalAmount(
        buyingSheet: _buyingSheet,
      );
      setState(() {});
    } catch (e) {
      controller.text = 'error';
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
            onChanged: (bool? value) => _handleItemSelection(item, value),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _selectedSupplier == null
          ? null
          : () {
              _orderNow();
              setState(() {
                _selectAll = false;
              });
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        minimumSize: const Size(300, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text('Order Now (${_selectedCount})'),
    );
  }

  Future<void> _orderNow() async {
    try {
      if (_selectedSupplier!.name == 'All') {
        Util.customErrorSnackBar(context, 'Please select a supplier to order');
        return;
      }
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

      final String tokenNo = await ApiServices().fnGetTokenNoUrl(
        prmCmpId: prmCmpId,
        prmBrId: prmBrId,
        prmFaId: prmFaId,
      );
      List<BuyingSheetListModel> selectedItems = [];
      for (var item in _buyingSheet) {
        if (item.isSelected) {
          selectedItems.add(item);
        }
      }
      if (selectedItems.isEmpty) {
        Util.customErrorSnackBar(
          context,
          'Please select at least one item to order',
        );
        return;
      }
      for (int i = 0; i < selectedItems.length; i++) {
        log('Ordering item: ${selectedItems[i].itemName}');
        log('Ordering item: ${selectedItems[i].totalQty}');
        log('Ordering item: ${selectedItems[i].rate}');
        final response = await ApiServices().fnSavePoList(
          prmTokenNo: tokenNo,
          prmDatePrmToCnt: _formatDate(DateTime.now()),
          prmCurntCnt: (i + 1).toString(),
          PrmToCnt: selectedItems.length.toString(),
          prmAccId: _selectedSupplier!.id,
          prmItemId: selectedItems[i].itemId,
          prmUomId: selectedItems[i].boxUomId,
          prmTaxId: '',
          prmPackId: _selectedOrderTableUom[i].id,
          prmNoPacks: selectedItems[i].totalQty,
          prmConVal: selectedItems[i].uomConVal,
          prmCmpId: prmCmpId,
          prmBrId: prmBrId,
          prmFaId: prmFaId,
          prmUId: prmUId,
          prmRate: selectedItems[i].rate,
          prmBillNo: _billNoController.text,
        );

        if (response == '1') {
          throw ('Order is not placed');
        }
      }
      final items = await getItemList();
      _items = items;
      Navigator.pop(context);

      setState(() {
        _buyingSheet.clear();
        _billNoController.clear();
        _selectedCategory = null;
        _selectedSupplier = null;
        _selectedPreviousOrder = null;
        _selectedCount = 0;
        _totalAmount = 0.0;
      });
      await getBuyingSheetList(
        prmFrmDate: _formatDate(DateTime.now()).toString(),
        prmToDate:
            _formatDate(DateTime.now().add(Duration(days: 1))).toString(),
        prmCategory: '',
        prmSupplier: '',
        prmPreviousOrder: '',
      );
      Util.customSuccessSnackBar(
        context,
        'Order placed successfully!',
      );
    } catch (e) {
      Navigator.pop(context);
      Util.customErrorSnackBar(context, 'Error: ${e.toString()}');
    }
  }

  void _handleItemSelection(BuyingSheetListModel item, bool? value) {
    item.isSelected = value ?? false;
    _selectAll = _buyingSheet.every((item) => item.isSelected);
    _selectedCount = _buyingSheet.where((item) => item.isSelected).length;
    calculateTotalAmount(
      buyingSheet: _buyingSheet,
    );
    setState(() {});
  }

  GestureDetector _calculatorContainer({
    required String value,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          TextEditingController activeController;
          if (isBillNoSelected) {
            activeController = _billNoController;
          } else {
            final controllers =
                isQtyCtrlSelected ? _orderQtyControllers : _rateControllers;
            activeController = controllers[selectedRowIndex];
          }

          final currentText = activeController.text;
          final selection = activeController.selection;

          if (value == 'C') {
            if (currentText.isNotEmpty) {
              if (selection.baseOffset == selection.extentOffset) {
                final newText =
                    currentText.substring(0, currentText.length - 1);
                activeController.text = newText;
                activeController.selection =
                    TextSelection.collapsed(offset: newText.length);
              } else {
                final beforeSelection =
                    currentText.substring(0, selection.baseOffset);
                final afterSelection =
                    currentText.substring(selection.extentOffset);
                activeController.text = beforeSelection + afterSelection;
                activeController.selection =
                    TextSelection.collapsed(offset: selection.baseOffset);
              }
            }
          } else if (value == '.') {
            if (!currentText.contains('.')) {
              if (selection.baseOffset == selection.extentOffset) {
                final newText = currentText + value;
                activeController.text = newText;
                activeController.selection =
                    TextSelection.collapsed(offset: newText.length);
              } else {
                final beforeSelection =
                    currentText.substring(0, selection.baseOffset);
                final afterSelection =
                    currentText.substring(selection.extentOffset);
                final newText = beforeSelection + value + afterSelection;
                activeController.text = newText;
                activeController.selection =
                    TextSelection.collapsed(offset: selection.baseOffset + 1);
              }
            }
          } else {
            if (selection.baseOffset == selection.extentOffset) {
              final newText = currentText + value;
              activeController.text = newText;
              activeController.selection =
                  TextSelection.collapsed(offset: newText.length);
            } else {
              final beforeSelection =
                  currentText.substring(0, selection.baseOffset);
              final afterSelection =
                  currentText.substring(selection.extentOffset);
              final newText = beforeSelection + value + afterSelection;
              activeController.text = newText;
              activeController.selection =
                  TextSelection.collapsed(offset: selection.baseOffset + 1);
            }
          }
          if (isQtyCtrlSelected && !isBillNoSelected) {
            setState(() {
              _buyingSheet[selectedRowIndex].totalQty = activeController.text;
              calculateTotalAmount(
                buyingSheet: _buyingSheet,
              );
            });
          } else if (!isQtyCtrlSelected && !isBillNoSelected) {
            setState(() {
              _buyingSheet[selectedRowIndex].rate = activeController.text;
              calculateTotalAmount(
                buyingSheet: _buyingSheet,
              );
            });
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
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
    );
  }

  // DataCell _buildEditTextConValDataCell(
  //     TextEditingController controller, int index) {
  //   return DataCell(
  //     Center(
  //       child: SizedBox(
  //         width: 70,
  //         child: TextField(
  //           controller: controller,
  //           textAlign: TextAlign.center,
  //           style: const TextStyle(color: Colors.black),
  //           decoration: InputDecoration(
  //             hintText: 'Enter value',
  //             hintStyle: TextStyle(color: Colors.grey.shade500),
  //             border: InputBorder.none,
  //             focusedBorder: InputBorder.none,
  //             enabledBorder: InputBorder.none,
  //           ),
  //           keyboardType: TextInputType.number,
  //           onChanged: (value) {
  //             try {
  //               double actualNeededQty =
  //                   double.parse(_buyingSheet[index].eStockQty) -
  //                       double.parse(_orderQtyControllers[index].text);
  //
  //               double split = actualNeededQty.abs() % double.parse(value);
  //
  //               double semiBulk = actualNeededQty.abs() -
  //                   (actualNeededQty.abs() % double.parse(value));
  //               double bulk = semiBulk.abs() / double.parse(value.toString());
  //               log('Actual Needed Qty: ${actualNeededQty.abs()} Split: $split SemiBulk: $semiBulk Bulk: $bulk');
  //               controller.text = value;
  //               _buyingSheet[index].uomConVal = value;
  //               _buyingSheet[index].odrBQty = bulk.toString();
  //               _buyingSheet[index].odrEQty = split.toString();
  //               _orderQtyControllers = List.generate(
  //                 _buyingSheet.length,
  //                 (index) {
  //                   double result = calculateRoundedValue(
  //                       bulk.toString(), split.toString(), value);
  //                   _buyingSheet[index].uomConVal = value;
  //                   _buyingSheet[index].totalQty = result.toString();
  //                   calculateTotalAmount(
  //                     buyingSheet: _buyingSheet,
  //                   );
  //                   return TextEditingController(text: result.toString());
  //                 },
  //               );
  //               setState(() {});
  //             } catch (e) {
  //               print('Error calculating bulk: $e');
  //             }
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    for (var controller in _orderQtyControllers) {
      controller.dispose();
    }
    _itemNameController.dispose();
    _itemConValController.dispose();
    _itemOrderQtyController.dispose();
    _itemRateController.dispose();
    _billNoController.dispose();
    super.dispose();
  }
}
