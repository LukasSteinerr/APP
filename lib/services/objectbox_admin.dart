import 'package:flutter/foundation.dart';
import 'package:objectbox/objectbox.dart';

/// A helper class to initialize and manage the ObjectBox Admin interface
class ObjectBoxAdmin {
  static Admin? _admin;
  static final int _adminPort = 8090;

  /// Initialize the ObjectBox Admin interface
  static void initialize(Store store) {
    if (kDebugMode) {
      try {
        if (Admin.isAvailable()) {
          // Keep a reference until no longer needed or manually closed
          _admin = Admin(store);
          debugPrint(
            'OBJECTBOX ADMIN: Admin interface initialized successfully',
          );
          debugPrint(
            'OBJECTBOX ADMIN: Open http://127.0.0.1:$_adminPort in your browser to access the admin interface',
          );

          // For physical devices, you need to use port forwarding:
          // adb forward tcp:8090 tcp:8090
          debugPrint(
            'OBJECTBOX ADMIN: For physical devices, run: adb forward tcp:$_adminPort tcp:$_adminPort',
          );
        } else {
          debugPrint('OBJECTBOX ADMIN: Admin interface is not available');
        }
      } catch (e) {
        debugPrint(
          'OBJECTBOX ADMIN ERROR: Failed to initialize Admin interface: $e',
        );
      }
    }
  }

  /// Close the ObjectBox Admin interface
  static void close() {
    if (_admin != null) {
      _admin!.close();
      _admin = null;
      debugPrint('OBJECTBOX ADMIN: Admin interface closed');
    }
  }

  /// Get the admin port
  static int getPort() {
    return _adminPort;
  }
}
