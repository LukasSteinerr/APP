import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for checking network connectivity
class NetworkService {
  static final Connectivity _connectivity = Connectivity();
  static bool _hasInternet = true;
  
  /// Check if the device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      // First, check connectivity status
      final connectivityResult = await _connectivity.checkConnectivity();
      
      // If no connectivity, return false immediately
      if (connectivityResult == ConnectivityResult.none) {
        debugPrint('NETWORK SERVICE: No connectivity');
        _hasInternet = false;
        return false;
      }
      
      // If we have connectivity, try to actually reach a server
      // This handles cases where the device is connected to a network
      // but the network doesn't have internet access
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          debugPrint('NETWORK SERVICE: Internet connection available');
          _hasInternet = true;
          return true;
        }
      } on SocketException catch (_) {
        debugPrint('NETWORK SERVICE: No internet connection (socket exception)');
        _hasInternet = false;
        return false;
      }
      
      _hasInternet = false;
      return false;
    } catch (e) {
      debugPrint('NETWORK SERVICE ERROR: $e');
      _hasInternet = false;
      return false;
    }
  }
  
  /// Get the cached internet connection status
  /// This is faster than checking the connection again
  static bool get hasInternet => _hasInternet;
  
  /// Initialize the network service and start listening for connectivity changes
  static Future<void> initialize() async {
    // Check initial connection
    await hasInternetConnection();
    
    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) async {
      debugPrint('NETWORK SERVICE: Connectivity changed to $result');
      if (result == ConnectivityResult.none) {
        _hasInternet = false;
      } else {
        // Verify internet connection
        await hasInternetConnection();
      }
    });
  }
}
