// lib/core/services/connectivity_service.dart
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to check and monitor internet connectivity
class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static bool _hasCheckedConnection = false;
  static bool _lastKnownStatus = true;
  static final _statusController = StreamController<bool>.broadcast();

  /// Stream of connectivity changes
  static Stream<bool> get connectivityStream => _statusController.stream;

  /// Check if the device has an internet connection
  static Future<bool> hasInternetConnection() async {
    if (_hasCheckedConnection) {
      return _lastKnownStatus;
    }

    try {
      // Check connectivity
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none) || results.isEmpty) {
        _updateConnectionStatus(false);
        return false;
      }

      // Actually verify internet by making a test connection
      final hasInternet = await _makeTestConnection();
      _updateConnectionStatus(hasInternet);
      return hasInternet;
    } catch (e) {
      _updateConnectionStatus(false);
      return false;
    }
  }

  /// Start monitoring connectivity changes
  static void startMonitoring() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      if (results.contains(ConnectivityResult.none) || results.isEmpty) {
        _updateConnectionStatus(false);
      } else {
        final hasInternet = await _makeTestConnection();
        _updateConnectionStatus(hasInternet);
      }
    });
  }

  /// Make a test connection to verify internet
  static Future<bool> _makeTestConnection() async {
    try {
      // Try to connect to a reliable service
      final List<InternetAddress> lookupResults = await InternetAddress.lookup('google.com');
      
      if (lookupResults.isNotEmpty && lookupResults.first.rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Update the connection status and notify listeners
  static void _updateConnectionStatus(bool isConnected) {
    _hasCheckedConnection = true;
    if (_lastKnownStatus != isConnected) {
      _lastKnownStatus = isConnected;
      _statusController.add(isConnected);
    }
  }

  /// Dispose resources
  static void dispose() {
    _statusController.close();
  }
}