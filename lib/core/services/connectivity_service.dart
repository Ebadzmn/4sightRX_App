import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final RxBool isOffline = false.obs;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<ConnectivityService> init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
    return this;
  }

  void _updateStatus(List<ConnectivityResult> results) {
    isOffline.value = results.isEmpty || results.contains(ConnectivityResult.none);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
