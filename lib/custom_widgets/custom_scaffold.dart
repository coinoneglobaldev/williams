import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../custom_screens/custom_network_error.dart';
import '../providers/connectivity_status_provider.dart';

class ScreenCustomScaffold extends ConsumerStatefulWidget {
  final Widget homeWidget;
  final bool resizeToAvoidBottomInset;
  final PreferredSizeWidget? appBar;
  const ScreenCustomScaffold({
    super.key,
    required this.homeWidget,
    this.appBar,
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
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        appBar: widget.appBar,
        key: _scaffoldKey,
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Column(
            children: [
              Expanded(
                child: widget.homeWidget,
              ),
            ],
          ),
        ),
      );
    } else {
      return const ScreenCustomNetworkError();
    }
  }
}
