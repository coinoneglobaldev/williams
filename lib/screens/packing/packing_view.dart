import 'package:flutter/material.dart';

import '../../custom_widgets/custom_scaffold.dart';

class PackingView extends StatefulWidget {
  const PackingView({super.key});

  @override
  State<PackingView> createState() => _PackingViewState();
}

class _PackingViewState extends State<PackingView> {
  @override
  Widget build(BuildContext context) {
    return ScreenCustomScaffold(
      appBar: AppBar(
        title: const Text('Packing'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      homeWidget: Container(),
    );
  }
}
