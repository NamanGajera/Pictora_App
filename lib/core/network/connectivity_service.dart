// Dart SDK
import 'dart:async';

// Third-party
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((results) {
      _connectionStatusController.add(_hasConnection(results));
    });
  }

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.vpn)) {
      return true;
    }
    return false;
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
