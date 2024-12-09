import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../custom_screens/custom_network_error.dart';
import '../providers/connectivity_status_provider.dart';

class CustomScaffoldDriver extends ConsumerStatefulWidget {
  final String title;
  final Widget bodyWidget;
  final bool resizeToAvoidBottomInset;

  const CustomScaffoldDriver({
    super.key,
    required this.title,
    required this.bodyWidget,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScreenHomePageState();
}

class _ScreenHomePageState extends ConsumerState<CustomScaffoldDriver> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(
    BuildContext context,
  ) {
    var connectivityStatusProvider = ref.watch(connectivityStatusProviders);
    if (connectivityStatusProvider == ConnectivityStatus.isConnected) {
      return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        // key: _scaffoldKey,
        body: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: SafeArea(child: widget.bodyWidget),
        ),
      );
    } else {
      return const ScreenCustomNetworkError();
    }
  }
}
