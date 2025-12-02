import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

/// Abstract interface for network connectivity checking.
abstract class NetworkInfo {
  /// Check if the device is currently online.
  /// Returns true if connected to WiFi, mobile data, or ethernet.
  Future<bool> isOnline();

  /// Stream that emits connectivity status changes.
  /// Emits true when connected, false when disconnected.
  Stream<bool> get onConnectivityChanged;
}

/// Implementation of NetworkInfo using connectivity_plus package.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  final Logger _logger;

  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  NetworkInfoImpl({Connectivity? connectivity, Logger? logger})
    : _connectivity = connectivity ?? Connectivity(),
      _logger = logger ?? Logger();

  @override
  Future<bool> isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final isConnected = _isConnected(results);

      _logger.d('Connectivity check: $results -> $isConnected');
      return isConnected;
    } catch (e) {
      _logger.e('Error checking connectivity: $e');
      // If we can't check connectivity, assume offline
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    _connectivityController ??= StreamController<bool>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _connectivityController!.stream;
  }

  void _startListening() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        final isConnected = _isConnected(results);
        _logger.d('Connectivity changed: $results -> $isConnected');
        _connectivityController?.add(isConnected);
      },
      onError: (error) {
        _logger.e('Connectivity stream error: $error');
        _connectivityController?.add(false);
      },
    );
  }

  void _stopListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Check if any of the connectivity results indicate an active connection.
  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet,
    );
  }

  /// Dispose resources when no longer needed.
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController?.close();
  }
}
