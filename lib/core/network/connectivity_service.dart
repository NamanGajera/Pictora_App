import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

  ConnectivityService() {
    // Start listening when service is created
    _connectivity.onConnectivityChanged.listen((results) {
      _connectionStatusController.add(_hasConnection(results));
    });
  }

  /// Expose a stream of online/offline status
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// Check current connectivity once
  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  /// Convert connectivity results into a single online/offline bool
  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.vpn)) {
      return true; // Has internet (but not guaranteed, just network available)
    }
    return false; // No network at all
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
