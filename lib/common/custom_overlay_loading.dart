import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../custom_widgets/custom_spinning_logo.dart';

class CustomOverlayLoading extends ConsumerStatefulWidget {
  const CustomOverlayLoading({
    super.key,
  });

  @override
  ConsumerState<CustomOverlayLoading> createState() =>
      _CustomProcessingPopupState();
}

class _CustomProcessingPopupState extends ConsumerState<CustomOverlayLoading> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(15),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
          child: const CustomLogoSpinner(
            color: Colors.white,
          )),
    );
  }
}
