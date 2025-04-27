import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/xtream_connection.dart';
import 'database_helper.dart';

class StorageService {
  static const String _connectionsKey = 'xtream_connections';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Flag to track if we've migrated from SharedPreferences to SQLite
  static const String _migratedKey = 'migrated_to_sqlite';

  // Constructor - check if we need to migrate data
  StorageService() {
    _checkAndMigrateData();
  }

  // Check if we need to migrate data from SharedPreferences to SQLite
  Future<void> _checkAndMigrateData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool migrated = prefs.getBool(_migratedKey) ?? false;

      if (!migrated) {
        // Get connections from SharedPreferences
        final List<String> jsonList =
            prefs.getStringList(_connectionsKey) ?? [];

        if (jsonList.isNotEmpty) {
          // Convert to XtreamConnection objects
          final connections =
              jsonList
                  .map(
                    (jsonStr) => XtreamConnection.fromJson(jsonDecode(jsonStr)),
                  )
                  .toList();

          // Save to SQLite
          for (var connection in connections) {
            await _dbHelper.insertConnection(connection);
          }

          // Mark as migrated
          await prefs.setBool(_migratedKey, true);
          debugPrint(
            'Successfully migrated data from SharedPreferences to SQLite',
          );
        } else {
          // No data to migrate, just mark as migrated
          await prefs.setBool(_migratedKey, true);
        }
      }
    } catch (e) {
      debugPrint('Error during migration: $e');
    }
  }

  // Save a new Xtream connection
  Future<bool> saveXtreamConnection(XtreamConnection connection) async {
    try {
      // Save to SQLite
      final result = await _dbHelper.insertConnection(connection);
      return result > 0;
    } catch (e) {
      debugPrint('Error saving Xtream connection: $e');
      return false;
    }
  }

  // Get all saved Xtream connections
  Future<List<XtreamConnection>> getXtreamConnections() async {
    try {
      // Get from SQLite
      return await _dbHelper.getConnections();
    } catch (e) {
      debugPrint('Error getting Xtream connections: $e');
      return [];
    }
  }

  // Delete an Xtream connection by ID
  Future<bool> deleteXtreamConnection(String id) async {
    try {
      // Delete from SQLite
      final result = await _dbHelper.deleteConnection(id);
      return result > 0;
    } catch (e) {
      debugPrint('Error deleting Xtream connection: $e');
      return false;
    }
  }

  // Delete all connections
  Future<bool> deleteAllConnections() async {
    try {
      // Delete all from SQLite
      final result = await _dbHelper.deleteAllConnections();
      return result > 0;
    } catch (e) {
      debugPrint('Error deleting all connections: $e');
      return false;
    }
  }
}
