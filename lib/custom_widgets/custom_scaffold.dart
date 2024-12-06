import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../custom_screens/custom_network_error.dart';
import '../providers/connectivity_status_provider.dart';

class ScreenCustomScaffold extends ConsumerStatefulWidget {
  final String title;
  final Widget bodyWidget;
  final bool resizeToAvoidBottomInset;
  final Widget? floatingActionButton;
  const ScreenCustomScaffold({
    super.key,
    required this.title,
    required this.bodyWidget,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScreenHomePageState();
}

class _ScreenHomePageState extends ConsumerState<ScreenCustomScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(
    BuildContext context,
  ) {
    var connectivityStatusProvider = ref.watch(connectivityStatusProviders);
    if (connectivityStatusProvider == ConnectivityStatus.isConnected) {
      return Scaffold(
        floatingActionButton: widget.floatingActionButton,
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        appBar: AppBar(
          title:
              Text(widget.title, style: const TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        key: _scaffoldKey,
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
