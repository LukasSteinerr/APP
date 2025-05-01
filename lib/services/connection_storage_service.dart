import 'package:flutter/foundation.dart';
import '../models/xtream_connection.dart';
import 'objectbox_service.dart';

/// Service for managing Xtream connections using ObjectBox
class ConnectionStorageService {
  /// Save a new Xtream connection
  Future<bool> saveXtreamConnection(XtreamConnection connection) async {
    try {
      // Save to ObjectBox
      final result = await ObjectBoxService.saveConnection(connection);
      return result;
    } catch (e) {
      debugPrint('Error saving Xtream connection: $e');
      return false;
    }
  }

  /// Get all saved Xtream connections
  Future<List<XtreamConnection>> getXtreamConnections() async {
    try {
      // Get from ObjectBox
      return ObjectBoxService.getConnections();
    } catch (e) {
      debugPrint('Error getting Xtream connections: $e');
      return [];
    }
  }

  /// Delete an Xtream connection
  Future<bool> deleteXtreamConnection(String id) async {
    try {
      // Delete from ObjectBox
      final result = await ObjectBoxService.deleteConnection(id);
      return result;
    } catch (e) {
      debugPrint('Error deleting Xtream connection: $e');
      return false;
    }
  }

  /// Delete all Xtream connections
  Future<bool> deleteAllXtreamConnections() async {
    try {
      // Delete all from ObjectBox
      final result = await ObjectBoxService.deleteAllConnections();
      return result;
    } catch (e) {
      debugPrint('Error deleting all Xtream connections: $e');
      return false;
    }
  }
}
