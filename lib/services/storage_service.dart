import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/xtream_connection.dart';

class StorageService {
  static const String _connectionsKey = 'xtream_connections';

  // Save a new Xtream connection
  Future<bool> saveXtreamConnection(XtreamConnection connection) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing connections
      final List<XtreamConnection> connections = await getXtreamConnections();
      
      // Check if a connection with this ID already exists
      final existingIndex = connections.indexWhere((c) => c.id == connection.id);
      
      if (existingIndex >= 0) {
        // Update existing connection
        connections[existingIndex] = connection;
      } else {
        // Add new connection
        connections.add(connection);
      }
      
      // Convert to JSON and save
      final List<String> jsonList = connections
          .map((conn) => jsonEncode(conn.toJson()))
          .toList();
      
      return await prefs.setStringList(_connectionsKey, jsonList);
    } catch (e) {
      print('Error saving Xtream connection: $e');
      return false;
    }
  }

  // Get all saved Xtream connections
  Future<List<XtreamConnection>> getXtreamConnections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final List<String> jsonList = prefs.getStringList(_connectionsKey) ?? [];
      
      return jsonList
          .map((jsonStr) => XtreamConnection.fromJson(jsonDecode(jsonStr)))
          .toList();
    } catch (e) {
      print('Error getting Xtream connections: $e');
      return [];
    }
  }

  // Delete an Xtream connection by ID
  Future<bool> deleteXtreamConnection(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing connections
      final List<XtreamConnection> connections = await getXtreamConnections();
      
      // Remove the connection with the given ID
      connections.removeWhere((conn) => conn.id == id);
      
      // Convert to JSON and save
      final List<String> jsonList = connections
          .map((conn) => jsonEncode(conn.toJson()))
          .toList();
      
      return await prefs.setStringList(_connectionsKey, jsonList);
    } catch (e) {
      print('Error deleting Xtream connection: $e');
      return false;
    }
  }
}
