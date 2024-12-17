import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../custom_screens/custom_network_error.dart';
import '../providers/connectivity_status_provider.dart';

class ScreenCustomScaffold extends ConsumerStatefulWidget {
  final Widget bodyWidget;
  final bool resizeToAvoidBottomInset;
  final Widget? floatingActionButton;

  const ScreenCustomScaffold({
    super.key,
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
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        key: _scaffoldKey,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SafeArea(child: widget.bodyWidget),
        ),
      );
    } else {
      return const ScreenCustomNetworkError();
    }
  }
}
