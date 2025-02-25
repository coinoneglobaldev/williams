import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus {
  notDetermined,
  isConnected,
  isDisconnected,
}

class ConnectivityStatusNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityStatusNotifier() : super(ConnectivityStatus.isDisconnected) {
    Connectivity().onConnectivityChanged.listen((event) {
      if (Platform.isIOS) {
        state = ConnectivityStatus
            .isConnected; // TODO : remove before release in IOS
      } else if (event.contains(ConnectivityResult.mobile) ||
          event.contains(ConnectivityResult.wifi)) {
        state = ConnectivityStatus.isConnected;
      } else {
        state = ConnectivityStatus.isDisconnected;
      }
    });
  }
}

final connectivityStatusProviders = StateNotifierProvider((ref) {
  return ConnectivityStatusNotifier();
});
