import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/xtream_connection.dart';
import '../services/storage_service.dart';

class ConnectionsProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<XtreamConnection> _connections = [];
  bool _isLoading = false;
  String? _error;

  List<XtreamConnection> get connections => _connections;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ConnectionsProvider() {
    loadConnections();
  }

  Future<void> loadConnections() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _connections = await _storageService.getXtreamConnections();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load connections: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addConnection({
    required String name,
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    try {
      final connection = XtreamConnection(
        id: const Uuid().v4(),
        name: name,
        serverUrl: serverUrl,
        username: username,
        password: password,
        addedDate: DateTime.now(),
      );

      final success = await _storageService.saveXtreamConnection(connection);
      
      if (success) {
        await loadConnections();
      }
      
      return success;
    } catch (e) {
      _error = 'Failed to add connection: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateConnection(XtreamConnection connection) async {
    try {
      final success = await _storageService.saveXtreamConnection(connection);
      
      if (success) {
        await loadConnections();
      }
      
      return success;
    } catch (e) {
      _error = 'Failed to update connection: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteConnection(String id) async {
    try {
      final success = await _storageService.deleteXtreamConnection(id);
      
      if (success) {
        await loadConnections();
      }
      
      return success;
    } catch (e) {
      _error = 'Failed to delete connection: $e';
      notifyListeners();
      return false;
    }
  }
}
