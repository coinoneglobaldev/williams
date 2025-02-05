import 'dart:developer';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:williams/constants.dart';
import 'package:williams/custom_widgets/custom_scaffold.dart';
import 'package:williams/models/po_details_model.dart';

import '../../common/custom_overlay_loading.dart';
import '../../custom_widgets/custom_exit_confirmation.dart';
import '../../custom_widgets/custom_logout_button.dart';
import '../../custom_widgets/custom_spinning_logo.dart';
import '../../custom_widgets/util_class.dart';
import '../../models/PreviousOrderCountModel.dart';
import '../../models/category_list_model.dart';
import '../../models/item_list_model.dart';
import '../../models/supplier_list_model.dart';
import '../../models/uom_list_model.dart';
import '../../services/api_services.dart';

class PurchaseOrder extends StatefulWidget {
  const PurchaseOrder({super.key});

  @override
  State<PurchaseOrder> createState() => _PurchaseOrderState();
}

class _PurchaseOrderState extends State<PurchaseOrder> {
  FocusNode _orderQtyFocus = FocusNode();
  FocusNode _rateFocus = FocusNode();
  DateTimeRange? selectedDateRange;
  CategoryListModel? _selectedCategory;
  SupplierListModel? _selectedSupplier;
  PreviousOrderCountModel? _selectedPreviousOrder;
  UomAndPackListModel? _selectedOrderUom;
  late List<UomAndPackListModel> _selectedOrderTableUom;
  late List<TextEditingController> _orderQtyControllers;
  late List<TextEditingController> _orderQtyReadOnnlyControllers;
  late List<TextEditingController> _rateControllers;
  late List<TextEditingController> _rateReadOnlyControllers;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemConValController = TextEditingController();
  final TextEditingController _itemOrderQtyController = TextEditingController();
  final TextEditingController _itemRateController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _billNoController = TextEditingController();
  final TextEditingController _itemRefController = TextEditingController();
  bool _selectAll = false;
  late List<CategoryListModel> _categories = [];
  late List<SupplierListModel> _suppliers = [];
  late List<UomAndPackListModel> _oum = [];
  late List<ItemListModel> _items = [];
  late List<PreviousOrderCountModel> _previousOrders;
  bool _isLoading = false;
  List<PoDetailsModel> _purchaseSheet = [];
  ItemListModel? selectedItem;
  late String slectedSupplier;
  late List<String> currencyId;

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
    required List<PoDetailsModel> buyingSheet,
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
                          'Purchase Order',
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
                        // Expanded(
                        //   flex: 2,
                        //   child: TextField(
                        //     controller: _itemNameController,
                        //     readOnly: true,
                        //     decoration: InputDecoration(
                        //       labelText: 'Name',
                        //       border: OutlineInputBorder(),
                        //     ),
                        //   ),
                        // ),
                        Expanded(
                          flex: 2,
                          child: Autocomplete<ItemListModel>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<ItemListModel>.empty();
                              }
                              return _items.where((ItemListModel option) {
                                return option.name.toLowerCase().contains(
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
                              if (_itemNameController.text !=
                                  fieldController.text) {
                                fieldController.text = _itemNameController.text;
                              }

                              return TextFormField(
                                controller: fieldController,
                                focusNode: fieldFocusNode,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onChanged: (value) {
                                  _itemNameController.text = value;
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
                              labelText: 'Unit/Box',
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
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.166, 50),
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
                              if (_purchaseSheet.isEmpty) {
                                _selectedOrderTableUom = List.generate(
                                  1,
                                  (index) => _oum.first,
                                );
                              }
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
                                //TODO: Add item to _purchaseSheet sheet

                                _purchaseSheet.insert(
                                    0,
                                    PoDetailsModel(
                                      itemId: selectedItem!.id,
                                      itemName: _itemNameController.text,
                                      itemCode: selectedItem!.code,
                                      accountCr: "",
                                      accountDr: "",
                                      active: "",
                                      addChargeId: "",
                                      addCharges: "",
                                      addPer: "",
                                      amount: "",
                                      autoId: "",
                                      balQty: "",
                                      batchNo: "",
                                      branchId: "",
                                      cessAccId: "",
                                      cessAccName: "",
                                      cessId: "",
                                      cessName: "",
                                      cessValue: "",
                                      comm: "",
                                      commission: "",
                                      companyId: "",
                                      conVal: _itemConValController.text,
                                      counrtry: "",
                                      country: "",
                                      crAccGroup: "",
                                      crCode: "",
                                      crDesc: "",
                                      crGroupId: "",
                                      crId: "",
                                      discount: "",
                                      drAccGroup: "",
                                      drCode: "",
                                      drDesc: "",
                                      drGroupId: "",
                                      drId: "",
                                      itemGroup: selectedItem!.itemGroup,
                                      faId: "",
                                      gradeId: "",
                                      gradeName: "",
                                      id: "",
                                      invoiceId: "",
                                      isBefore: "",
                                      isPercentage: "",
                                      isTaxInclusive: "",
                                      itemGroupId: "",
                                      itmGroup: "",
                                      itmGrpId: "",
                                      margin: "",
                                      mrp: "",
                                      numberofPacks: "",
                                      packId: _selectedOrderUom!.id,
                                      packName: _selectedOrderUom!.name,
                                      price: "",
                                      printUom: "",
                                      puQty: "",
                                      puRate: "",
                                      puTotal: "",
                                      qty: _itemOrderQtyController.text,
                                      refNo: _purchaseSheet.first.crId,
                                      remarks: "",
                                      sellingPrc: "",
                                      shopId: "",
                                      shopName: "",
                                      slQty: "",
                                      specVal: "",
                                      tType: "",
                                      taxAccId: "",
                                      taxAccName: "",
                                      taxId: "",
                                      taxName: "",
                                      taxValue: "",
                                      tokenNo: "",
                                      totalAmt: "",
                                      trDate: "",
                                      uomId: _selectedOrderUom!.id,
                                      uomName: "",
                                      uomSplitId: "",
                                      updateDate: "",
                                      userId: "",
                                      boxUomId: _selectedOrderUom!.id,
                                      isSelected: true,
                                      totalQty: double.parse(
                                        _itemOrderQtyController.text,
                                      ).abs().ceil().toString(),
                                      umoId: _selectedOrderUom!.id,
                                      prvBoxQty: "",
                                      prvQty: "",
                                      rate: _itemRateController.text,
                                      currencyId: "",
                                    ));
                                _selectedCount = _purchaseSheet
                                    .where((item) => item.isSelected)
                                    .length;
                                calculateTotalAmount(
                                  buyingSheet: _purchaseSheet,
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
                          child: _purchaseSheet.isEmpty
                              ? SizedBox()
                              : _buyingSheetTable(data: _purchaseSheet),
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

                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade900,
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.166,
                                      50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                icon: Transform.rotate(
                                  angle: 3.14159, // 180 degrees in radians (pi)
                                  child: const Icon(
                                    Icons.login,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                                label: const Text('Buying Sheet'),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
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
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Total Items: ${_purchaseSheet.length}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Expanded(
                      //   flex: 4,
                      //   child: Text(
                      //     "Date: ${selectedDateRange != null ? _formatDate(selectedDateRange!.start) + ' - ' + _formatDate(selectedDateRange!.end) : _formatDate(DateTime.now()).toString() + ' - ' + _formatDate(DateTime.now().add(Duration(days: 1))).toString()}",
                      //     style: const TextStyle(
                      //       fontSize: 20,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      // Expanded(
                      //   flex: 3,
                      //   child: Text(
                      //     'Total Amount : £ ${_totalAmount.toStringAsFixed(2)}',
                      //     style: const TextStyle(
                      //       fontSize: 20,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 50,
                          child: _purchaseSheet.isEmpty
                              ? SizedBox()
                              : _buildSaveButton(),
                        ),
                      ),
                      const SizedBox(width: 20),

                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 100,
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
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
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
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () async {
                getPurchaseList(
                        prmFlag: "PREVIOUS", refNo: _itemRefController.text)
                    .whenComplete(() {
                  _selectAll = false;
                  _selectedCount = 0;
                  _totalAmount = 0.0;
                  setState(() {});
                });
              },
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
              child: const Text('Previous'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _itemRefController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Reference No.',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () async {
                getPurchaseList(prmFlag: "NEXT", refNo: _itemRefController.text)
                    .whenComplete(() {
                  _selectAll = false;
                  _selectedCount = 0;
                  _totalAmount = 0.0;
                  setState(() {});
                });
              },
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
              child: const Text('Next'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                getPurchaseList(prmFlag: "GET", refNo: _itemRefController.text)
                    .whenComplete(() {
                  _selectAll = false;
                  _selectedCount = 0;
                  _totalAmount = 0.0;
                  setState(() {});
                });
              },
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
              child: const Text('Get'),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 4,
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
                    getPurchaseList(prmFlag: "LAST", refNo: "0")
                        .whenComplete(() {
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

      getPurchaseList(prmFlag: "LAST", refNo: "0");
      // _orderQtyControllers = List.generate(
      //   _purchaseSheet.length,
      //   (index) {
      //     double result = calculateRoundedValue(
      //       _purchaseSheet[index].odrBQty,
      //       _purchaseSheet[index].odrEQty,
      //       _purchaseSheet[index].uomConVal,
      //     );
      //     _purchaseSheet[index].totalQty = result.toString();
      //     return TextEditingController(text: result.toString());
      //   },
      // );

      // _selectedOrderTableUom = List.generate(
      //   _buyingSheet.length,
      //   (index) => _oum.where((e) => e.id == _buyingSheet[index].boxUomId).first,
      // ); TODO: Uncomment this line after adding UOM in BuyingSheetListModel
      // _selectedOrderTableUom = List.generate(
      //   _buyingSheet.length,
      //   (index) => _oum.first,
      // ); // TODO: Remove this line after adding UOM in BuyingSheetListModel
      _rateControllers = List.generate(
        _purchaseSheet.length,
        (index) => TextEditingController(text: _purchaseSheet[index].rate),
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
          await ApiServices().getSupplierAllList(prmCompanyId: prmCmpId);
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

  Future getPurchaseList({
    required String prmFlag,
    required String refNo,
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
      final response = await ApiServices().fnGetPurchaseList(
          prmCmpId: prmCmpId,
          prmBrId: prmBrId,
          prmFaId: prmFaId,
          prmUId: prmUId,
          prmFlag: prmFlag,
          prmCurntRefNo: refNo);
      if (response.isNotEmpty) {
        _purchaseSheet = response;
        _itemRefController.text = _purchaseSheet[0].refNo;
        // _suppliers.contains(_purchaseSheet[0].accountCr);
        _selectedSupplier = _suppliers
            .where((e) => e.name == _purchaseSheet[0].accountCr)
            .first;

        _selectedOrderTableUom = List.generate(
          _purchaseSheet.length,
          (index) => _oum.first,
        );
        _orderQtyControllers = List.generate(
          _purchaseSheet.length,
          (index) {
            double result = _purchaseSheet[index].numberofPacks.isEmpty
                ? 0.0
                : double.parse(_purchaseSheet[index].numberofPacks);
            _purchaseSheet[index].totalQty = result.toString();
            return TextEditingController(text: result.toString());
          },
        );
        _orderQtyReadOnnlyControllers = List.generate(
          _purchaseSheet.length,
          (index) {
            double result = _purchaseSheet[index].numberofPacks.isEmpty
                ? 0.0
                : double.parse(_purchaseSheet[index].numberofPacks);
            _purchaseSheet[index].totalQty = result.toString();
            return TextEditingController(text: result.toString());
          },
        );
        currencyId = List.generate(
          _purchaseSheet.length,
          (index) {
            return _purchaseSheet[index].currencyId;
          },
        );

        _selectedOrderTableUom = List.generate(
          _purchaseSheet.length,
          (index) {
            return _oum
                .where((e) => e.id == _purchaseSheet[index].packId)
                .first;
          },
        ); // TODO: Remove this line after adding UOM in BuyingSheetListModel

        _rateControllers = List.generate(
          _purchaseSheet.length,
          (index) => TextEditingController(text: _purchaseSheet[index].rate),
        );
        _rateReadOnlyControllers = List.generate(
          _purchaseSheet.length,
          (index) => TextEditingController(text: _purchaseSheet[index].rate),
        );
        setState(() {});
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        throw ('No Items Found');
      }
    } catch (e) {
      _purchaseSheet = [];
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

  Widget _buyingSheetTable({required List<PoDetailsModel> data}) {
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
              fixedWidth: 200,
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
                  'Unit \n/Box',
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
            DataColumn2(
              label: Center(
                child: ElevatedButton(
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
                      for (var item in _purchaseSheet) {
                        item.isSelected = _selectAll;
                      }
                      _selectedCount = _purchaseSheet
                          .where((item) => item.isSelected)
                          .length;

                      if (_selectAll) {
                        calculateTotalAmount(
                          buyingSheet: _purchaseSheet,
                        );
                      }
                    });
                  },
                  child: Text(
                    _selectAll ? 'Deselect All' : 'Select All',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              size: ColumnSize.L,
            ),
          ],
          rows: data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return DataRow(
              color: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  return _selectedOrderTableUom[index].id == '19'
                      ? Colors.red.shade200
                      : Colors.blue.shade200;
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
                _buildBulkSplitDropdownCell(item, index),
                _buildDataCell(item.conVal),
                _buildEditableDataCell(
                  double.parse(currencyId[index]) > 1
                      ? _orderQtyReadOnnlyControllers[index]
                      : _orderQtyControllers[index],
                  index,
                ),
                _buildEditTextRateDataCell(
                  double.parse(currencyId[index]) > 1
                      ? _rateReadOnlyControllers[index]
                      : _rateControllers[index],
                  index,
                ),
                _buildCheckboxDataCell(item),
              ],
            );
          }).toList(),
        ),
      ),
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

  DataCell _buildBulkSplitDropdownCell(PoDetailsModel item, int index) {
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
            onChanged: double.parse(item.conVal) == 1
                ? null
                : (UomAndPackListModel? value) {
                    setState(() {
                      _selectedOrderTableUom[index] = value!;
                      _purchaseSheet[index].umoId = value.id;
                    });
                    log('Order UOM: ${_selectedOrderTableUom[index].name}');
                  },
          ),
        ),
      ),
    );
  }

  DataCell _buildEditableDataCell(
    TextEditingController controller,
    int index,
  ) {
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
                    _purchaseSheet[index].totalQty =
                        value.isEmpty ? '0' : value;
                    log('Order UOM: $value');
                    log('Order Qty: ${_purchaseSheet[index].totalQty}');
                    print(_purchaseSheet[index].totalQty);
                    print(value);
                    calculateTotalAmount(
                      buyingSheet: _purchaseSheet,
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
              _purchaseSheet[index].rate = value;

              calculateTotalAmount(
                buyingSheet: _purchaseSheet,
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
      _purchaseSheet[index].totalQty = (currentValue + 1).toString();
      calculateTotalAmount(
        buyingSheet: _purchaseSheet,
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
        _purchaseSheet[index].totalQty = (currentValue - 1).toString();
        controller.text = (currentValue - 1).toString();
      }
      calculateTotalAmount(
        buyingSheet: _purchaseSheet,
      );
      setState(() {});
    } catch (e) {
      controller.text = 'error';
    }
  }

  DataCell _buildCheckboxDataCell(PoDetailsModel item) {
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
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        minimumSize: const Size(300, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text('Update (${_selectedCount})'),
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
      List<PoDetailsModel> selectedItems = [];
      for (var item in _purchaseSheet) {
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
          prmPackId: selectedItems[i].umoId,
          prmNoPacks: selectedItems[i].totalQty,
          prmConVal: selectedItems[i].conVal, //TODO: Add conVal
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
        _purchaseSheet.clear();
        _billNoController.clear();
        _selectedCategory = null;
        _selectedSupplier = null;
        _selectedPreviousOrder = null;
        _selectedCount = 0;
        _totalAmount = 0.0;
      });
      await getPurchaseList(prmFlag: "LAST", refNo: '0');
      Util.customSuccessSnackBar(
        context,
        'Order placed successfully!',
      );
    } catch (e) {
      Navigator.pop(context);
      Util.customErrorSnackBar(context, 'Error: ${e.toString()}');
    }
  }

  void _handleItemSelection(PoDetailsModel item, bool? value) {
    item.isSelected = value ?? false;
    _selectAll = _purchaseSheet.every((item) => item.isSelected);
    _selectedCount = _purchaseSheet.where((item) => item.isSelected).length;
    calculateTotalAmount(
      buyingSheet: _purchaseSheet,
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
              _purchaseSheet[selectedRowIndex].totalQty = activeController.text;
              calculateTotalAmount(
                buyingSheet: _purchaseSheet,
              );
            });
          } else if (!isQtyCtrlSelected && !isBillNoSelected) {
            setState(() {
              _purchaseSheet[selectedRowIndex].rate = activeController.text;
              calculateTotalAmount(
                buyingSheet: _purchaseSheet,
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
