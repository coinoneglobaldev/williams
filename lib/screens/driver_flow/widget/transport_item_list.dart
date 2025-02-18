import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lasovrana/custom_widgets/custom_scaffold_driver.dart';
import 'package:lasovrana/services/api_services.dart';

import '../../../custom_widgets/util_class.dart';
import '../../../models/daily_drop_list_model.dart';
import '../../../models/transport_item_list_model.dart';

class TransportItemList extends StatefulWidget {
  final DailyDropListModel selectedItem;
  const TransportItemList({
    super.key,
    required this.selectedItem,
  });

  @override
  State<TransportItemList> createState() => _TransportItemListState();
}

class _TransportItemListState extends State<TransportItemList> {
  bool isLoading = false;
  ApiServices apiServices = ApiServices();
  List<TransportItemListModel> transportItems = [];

  @override
  void initState() {
    super.initState();
    _fnGetTransportItemList();
  }

  Future<List<TransportItemListModel>> _fnGetTransportItemList() async {
    setState(() {
      isLoading = true;
    });
    try {
      final items = await apiServices.fnGetTransportItemList(
        prmInvoiceId: widget.selectedItem.id,
        prmTokeNo: widget.selectedItem.tokenNo,
        prmCmpId: widget.selectedItem.companyId,
        prmBrId: widget.selectedItem.branchId,
        prmFaId: widget.selectedItem.faId,
        prmUId: widget.selectedItem.userId,
      );
      setState(() {
        transportItems = items;
        isLoading = false;
      });
      return items;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return [];
      Util.customErrorSnackBar(context, "Failed to fetch transport items");
      if (kDebugMode) {
        print('Error fetching transport items: $e');
      }
      rethrow;
    }
  }

  void _toggleSelectAll() {
    final bool allSelected = transportItems.every((item) => item.isChk == '1');
    setState(() {
      if (allSelected) {
        for (var item in transportItems) {
          item.isChk = '0';
        }
      } else {
        for (var item in transportItems) {
          item.isChk = '1';
        }
      }
    });
  }

  Future<void> _fnSaveSelectedItems() async {
    setState(() {
      isLoading = true;
    });
    try {
      String isAll =
          transportItems.every((item) => item.isChk == '1') ? '1' : '0';
      final bool allSelected =
          transportItems.every((item) => item.isChk == '1');

      for (int i = 0; i < transportItems.length; i++) {
        final result = await apiServices.fnSaveCheckList(
          prmTrnportAutoId: widget.selectedItem.autoId,
          prmItemAutoId: transportItems[i].autoId,
          prmTokenNo: widget.selectedItem.tokenNo,
          prmInvoiceId: widget.selectedItem.id,
          prmChkVal: transportItems[i].isChk,
          prmItemId: transportItems[i].itemId,
          prmCmpId: widget.selectedItem.companyId,
          prmBrId: widget.selectedItem.branchId,
          prmFaId: widget.selectedItem.faId,
          prmUId: widget.selectedItem.userId,
          prmIsAll: allSelected
              ? isAll == '1' && transportItems.length == i + 1
                  ? transportItems.isEmpty
                      ? '0'
                      : '1'
                  : '0'
              : '1',
        );
        if (!mounted) return;
        if (result.message != "Success") {
          throw Exception("Save selected items failed: ${result.message}");
        }
      }
      setState(() {
        isLoading = false;
      });
      Util.customSuccessSnackBar(context, "Save selected items successfully!");
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Util.customErrorSnackBar(
        context,
        "Failed to Save selected items.\n(${e.toString()})",
      );
      rethrow;
    }
  }

  void _handleSave() {
    _fnSaveSelectedItems();
  }

  @override
  Widget build(BuildContext context) {
    final bool allSelected = transportItems.every((item) => item.isChk == '1');
    return CustomScaffoldDriver(
      title: 'Transport Item List',
      actions: [
        TextButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
          // onPressed: _toggleSelectAll,
          onPressed: null,
          icon: Icon(
            allSelected ? Icons.deselect : Icons.select_all,
            color: Colors.black,
          ),
          label: Text(
            allSelected ? 'Deselect All' : 'Select All',
            style: const TextStyle(color: Colors.black),
          ),
        ),
        const SizedBox(width: 10),
      ],
      bodyWidget: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: transportItems.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final item = transportItems[index];
                    return CheckboxListTile(
                      title: Text('Item Name: ${item.itemName}'),
                      subtitle: Text('Quantity: ${item.qty}'),
                      value: item.isChk == '1',
                      onChanged: (bool? value) {
                        setState(() {
                          item.isChk = value == true ? '1' : '0';
                          if (value == true) {
                            setState(() {
                              item.isChk = '1';
                            });
                          } else {
                            setState(() {
                              item.isChk = '0';
                            });
                          }
                        });
                      },
                    );
                  },
                ),
          Positioned(
            bottom: 16,
            right: 16,
            left: 16,
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save Selected Items',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
