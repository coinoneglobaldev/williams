import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../custom_widgets/custom_exit_confirmation.dart';
import '../../custom_widgets/util_class.dart';
import '../../models/daily_drop_list_model.dart';
import '../../services/api_services.dart';
import 'delivery_upload_screen.dart';
import 'widget/delivery_item_list.dart';
import 'widget/driver_home_appbar.dart';

class DeliveryItemsListScreen extends StatefulWidget {
  final String name;
  final String dNo;

  const DeliveryItemsListScreen({
    super.key,
    required this.name,
    required this.dNo,
  });

  @override
  State<DeliveryItemsListScreen> createState() =>
      _DeliveryItemsListScreenState();
}

class _DeliveryItemsListScreenState extends State<DeliveryItemsListScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  late List<DailyDropListModel> deliveryItems = [];
  ApiServices apiServices = ApiServices();
  late TabController _tabController;

  List<DailyDropListModel> get pendingDeliveries =>
      deliveryItems.where((item) => item.isDelivery == '0').toList();

  List<DailyDropListModel> get finishedDeliveries =>
      deliveryItems.where((item) => item.isDelivery == '1').toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchDeliveryItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dte) {
    try {
      DateFormat date = DateFormat('dd/MMM/yyyy');
      return date.format(dte);
    } catch (e) {
      return '';
    }
  }

  Future<List<DailyDropListModel>> fetchDeliveryItems() async {
    setState(() {
      isLoading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String prmCmpId = prefs.getString('cmpId')!;
      String prmBrId = prefs.getString('brId')!;
      String prmFaId = prefs.getString('faId')!;
      String prmUId = prefs.getString('userId')!;
      String todayDate = _formatDate(DateTime.now());

      final items = await apiServices.fnGetVehicleTransportList(
        prmDate: todayDate,
        prmCmpId: prmCmpId,
        prmBrId: prmBrId,
        prmFaId: prmFaId,
        prmUId: prmUId,
      );
      setState(() {
        deliveryItems = items;
        isLoading = false;
      });
      return items;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return [];
      Util.customErrorSnackBar(context, "Failed to fetch delivery items");
      if (kDebugMode) {
        print('Error fetching delivery items: $e');
      }
      rethrow;
    }
  }

  Widget _buildDeliveryList(List<DailyDropListModel> items) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => fetchDeliveryItems(),
        child: ListView(
          children: [
            const SizedBox(height: 100),
            Center(
              child: Icon(
                Icons.inbox_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                'No deliveries available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => fetchDeliveryItems(),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () {
              if (item.isDelivery == '0') {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => DeliveryUploadScreen(
                      deliveryItem: item,
                    ),
                  ),
                ).then((_) => fetchDeliveryItems());
              } else {
                Util.customSuccessSnackBar(
                    context, "Delivery already uploaded");
              }
            },
            child: DeliveryItemList(
              selectedItem: item,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              children: [
                DriverHomeAppbar(name: widget.name, dNo: widget.dNo),
                const SizedBox(height: 10),
                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15),
                      ),
                      color: _tabController.index == 0
                          ? Colors.green
                          : Colors.blue,
                      shape: BoxShape.rectangle,
                    ),
                    labelColor: Colors.white,
                    labelStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelColor: Colors.grey,
                    splashFactory: NoSplash.splashFactory,
                    dividerHeight: 0,
                    indicatorSize: TabBarIndicatorSize.tab,
                    controller: _tabController,
                    onTap: (index) {
                      setState(() {
                        _tabController.index = index;
                      });
                    },
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pending_actions),
                            SizedBox(width: 8),
                            Text(
                              'Pending (${pendingDeliveries.length})',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline),
                            const SizedBox(width: 8),
                            Text(
                              'Finished (${finishedDeliveries.length})',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: _tabController,
                          children: [
                            _buildDeliveryList(pendingDeliveries),
                            _buildDeliveryList(finishedDeliveries),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
