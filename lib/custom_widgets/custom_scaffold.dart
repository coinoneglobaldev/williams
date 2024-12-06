import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../custom_screens/custom_network_error.dart';
import '../providers/connectivity_status_provider.dart';

class ScreenCustomScaffold extends ConsumerStatefulWidget {
  final String title;
  final Widget homeWidget;
  final bool resizeToAvoidBottomInset;

  const ScreenCustomScaffold({
    super.key,
    required this.title,
    required this.homeWidget,

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
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
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
