import 'package:flutter/material.dart';
import 'package:williams/custom_widgets/custom_scaffold.dart';

class BuyingSheetScreen extends StatefulWidget {
  const BuyingSheetScreen({super.key});

  @override
  State<BuyingSheetScreen> createState() => _BuyingSheetScreenState();
}

class _BuyingSheetScreenState extends State<BuyingSheetScreen> {
  @override
  Widget build(BuildContext context) {
    return ScreenCustomScaffold(
      title: 'Buying Sheet',
      bodyWidget: Column(
        children: const [
          Text('Buying Sheet',style: TextStyle(color: Colors.white,fontSize: 20
          ),),
          Text('Buying Sheet',style: TextStyle(color: Colors.white,fontSize: 20
          ),),Text('Buying Sheet',style: TextStyle(color: Colors.white,fontSize: 20
          ),),Text('Buying Sheet',style: TextStyle(color: Colors.white,fontSize: 20
          ),),Text('Buying Sheet',style: TextStyle(color: Colors.white,fontSize: 20
          ),),
        ],
      ),
    );
  }
}
