import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/channel.dart';
import '../models/movie.dart';
import '../models/series.dart';
import '../models/xtream_connection.dart';
import '../objectbox.g.dart'; // This will be generated after running build_runner
import 'objectbox_admin.dart';

/// Service for managing ObjectBox database operations
class ObjectBoxService {
  // ObjectBox store instance
  static late Store _store;

  // Box instances for each entity
  static late Box<Movie> moviesBox;
  static late Box<Series> seriesBox;
  static late Box<Channel> channelsBox;
  static late Box<XtreamConnection> connectionsBox;

  // Flag to track if data has been preloaded
  static bool _hasPreloadedData = false;
  static String? _connectionId;

  /// Initialize ObjectBox
  static Future<void> init() async {
    try {
      debugPrint('OBJECTBOX SERVICE: Initializing ObjectBox...');
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final databasePath = join(appDocumentDir.path, 'objectbox');

      // Create the ObjectBox store
      _store = await openStore(directory: databasePath);

      // Initialize boxes
      moviesBox = Box<Movie>(_store);
      seriesBox = Box<Series>(_store);
      channelsBox = Box<Channel>(_store);
      connectionsBox = Box<XtreamConnection>(_store);

      // Initialize ObjectBox Admin interface
      ObjectBoxAdmin.initialize(_store);

      // Print the database path
      final dbPath = databasePath;
      debugPrint('OBJECTBOX DATABASE PATH: $dbPath');

      // Check if we have preloaded data
      checkPreloadedData();

      debugPrint('OBJECTBOX SERVICE: ObjectBox initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('OBJECTBOX SERVICE ERROR: Failed to initialize ObjectBox: $e');
      debugPrint('OBJECTBOX SERVICE ERROR: Stack trace: $stackTrace');
    }
  }

  /// Check if we have preloaded data
  static void checkPreloadedData() {
    try {
      // We'll use the presence of data in the boxes to determine if data is preloaded
      final hasMovies = moviesBox.count() > 0;
      final hasSeries = seriesBox.count() > 0;
      final hasChannels = channelsBox.count() > 0;

      _hasPreloadedData = hasMovies && hasSeries && hasChannels;

      debugPrint('OBJECTBOX SERVICE: Has preloaded data: $_hasPreloadedData');
    } catch (e) {
      debugPrint('OBJECTBOX SERVICE ERROR: Failed to check preloaded data: $e');
      _hasPreloadedData = false;
    }
  }

  /// Save Movies to ObjectBox
  static Future<void> saveMovies(
    List<Movie> movies,
    String connectionId,
  ) async {
    try {
      debugPrint('OBJECTBOX SERVICE: Saving ${movies.length} Movies');
      // Clear existing data
      moviesBox.removeAll();

      // Add new data
      moviesBox.putMany(movies);

      // Save connection ID
      _connectionId = connectionId;

      debugPrint('OBJECTBOX SERVICE: Movies saved successfully');
    } catch (e) {
      debugPrint('OBJECTBOX SERVICE ERROR: Failed to save Movies: $e');
    }
  }

  /// Save Series to ObjectBox
  static Future<void> saveSeries(
    List<Series> series,
    String connectionId,
  ) async {
    try {
      debugPrint('OBJECTBOX SERVICE: Saving ${series.length} Series');
      // Clear existing data
      seriesBox.removeAll();

      // Add new data
      seriesBox.putMany(series);

      // Save connection ID
      _connectionId = connectionId;

      debugPrint('OBJECTBOX SERVICE: Series saved successfully');
    } catch (e) {
      debugPrint('OBJECTBOX SERVICE ERROR: Failed to save Series: $e');
    }
  }

  /// Save Channels to ObjectBox
  static Future<void> saveChannels(
    List<Channel> channels,
    String connectionId,
  ) async {
    try {
      debugPrint('OBJECTBOX SERVICE: Saving ${channels.length} Channels');
      // Clear existing data
      channelsBox.removeAll();

      // Add new data
      channelsBox.putMany(channels);

      // Save connection ID
      _connectionId = connectionId;

      debugPrint('OBJECTBOX SERVICE: Channels saved successfully');
    } catch (e) {
      debugPrint('OBJECTBOX SERVICE ERROR: Failed to save Channels: $e');
    }
  }

  /// Set preloaded data flag
  static void setPreloadedDataFlag(bool value) {
    try {
      _hasPreloadedData = value;
      debugPrint('OBJECTBOX SERVICE: Preloaded data flag set to $value');
    } catch (e) {
      debugPrint(
        'OBJECTBOX SERVICE ERROR: Failed to set preloaded data flag: $e',
      );
    }
  }

  /// Check if preloaded data exists
  static bool hasPreloadedData() {
    return _hasPreloadedData;
  }

  /// Get connection ID
  static String? getConnectionId() {
    return _connectionId;
  }

  /// Save connection ID
  static void saveConnectionId(String connectionId) {
    try {
      _connectionId = connectionId;
      debugPrint('OBJECTBOX SERVICE: Connection ID saved: $connectionId');
    } catch (e) {
      debugPrint('OBJECTBOX SERVICE ERROR: Failed to save connection ID: $e');
    }
  }

  /// Get Movies from ObjectBox
  static List<Movie> getMovies() {
    try {
      return moviesBox.getAll();
    } catch (e) {
      debugPrint('OBJECTBOX SERVICE ERROR: Failed to get Movies: $e');
      return [];
    }
  }

  /// Get Series from ObjectBox
  static List<Series> getSeries() {
    try {
      return seriesBox.getAll();
    } catch (e) {
      debugPrint('OBJECTBOX SERVICE ERROR: Failed to get Series: $e');
      return [];
    }
  }

  /// Get Channels from ObjectBox
  static List<Channel> getChannels() {
    try {
      return channelsBox.getAll();
    } catch (e) {
      debugPrint('OBJECTBOX SERVICE ERROR: Failed to get Channels: $e');
      return [];
    }
  }

  // The updateMovie method has been removed as favorites functionality has been removed.

  /// Clear all data
  static Future<void> clearAllData() async {
    try {
      debugPrint('OBJECTBOX SERVICE: Clearing all data');
      moviesBox.removeAll();
      seriesBox.removeAll();
      channelsBox.removeAll();
      connectionsBox.removeAll();
      _hasPreloadedData = false;
      _connectionId = null;
      debugPrint('OBJECTBOX SERVICE: All data cleared successfully');
    } catch (e) {
      debugPrint('OBJECTBOX SERVICE ERROR: Failed to clear all data: $e');
    }
  }

  /// Get ObjectBox database path
  static Future<String> getObjectBoxDatabasePath() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, 'objectbox');
  }

  /// Save a connection to ObjectBox
  static Future<bool> saveConnection(XtreamConnection connection) async {
    try {
      debugPrint('OBJECTBOX SERVICE: Saving connection: ${connection.name}');

      // Check if connection with this ID already exists
      final query =
          connectionsBox
              .query(XtreamConnection_.id.equals(connection.id))
              .build();
      final existingConnections = query.find();
      query.close();

      if (existingConnections.isNotEmpty) {
        // Update existing connection
        connection.obId = existingConnections.first.obId;
      }

      // Save the connection
      connectionsBox.put(connection);

      debugPrint('OBJECTBOX SERVICE: Connection saved successfully');
      return true;
    } catch (e) {
      debugPrint('OBJECTBOX SERVICE ERROR: Failed to save connection: $e');
      return false;
    }
  }

  /// Get all connections from ObjectBox
  static List<XtreamConnection> getConnections() {
    try {
      return connectionsBox.getAll();
    } catch (e) {
      debugPrint('OBJECTBOX SERVICE ERROR: Failed to get connections: $e');
      return [];
    }
  }

  /// Delete a connection from ObjectBox and clear its associated content data
  static Future<bool> deleteConnection(String id) async {
    try {
      debugPrint('OBJECTBOX SERVICE: Deleting connection with ID: $id');

      // Find the connection with the given ID
      final query =
          connectionsBox.query(XtreamConnection_.id.equals(id)).build();
      final connections = query.find();
      query.close();

      if (connections.isNotEmpty) {
        // Check if this is the current active connection
        final currentConnectionId = getConnectionId();
        final isCurrentConnection = currentConnectionId == id;

        // Always clear content data for the connection being deleted
        debugPrint(
          'OBJECTBOX SERVICE: Clearing content data for connection: $id',
        );

        if (isCurrentConnection) {
          // If this is the current connection, clear all content data
          moviesBox.removeAll();
          seriesBox.removeAll();
          channelsBox.removeAll();

          // Reset preloaded data flag and connection ID
          _hasPreloadedData = false;
          _connectionId = null;

          debugPrint(
            'OBJECTBOX SERVICE: Content data cleared for current connection: $id',
          );
        } else {
          // If this is not the current connection, we need to:
          // 1. Save the current connection's data temporarily (if any)
          // 2. Clear all data
          // 3. Restore the current connection's data (if any)

          List<Movie> tempMovies = [];
          List<Series> tempSeries = [];
          List<Channel> tempChannels = [];

          // Only save current data if we have a current connection
          if (currentConnectionId != null) {
            debugPrint(
              'OBJECTBOX SERVICE: Temporarily saving current connection data',
            );
            tempMovies = moviesBox.getAll();
            tempSeries = seriesBox.getAll();
            tempChannels = channelsBox.getAll();
          }

          // Clear all data
          moviesBox.removeAll();
          seriesBox.removeAll();
          channelsBox.removeAll();

          // Restore current connection data if needed
          if (currentConnectionId != null && tempMovies.isNotEmpty) {
            debugPrint('OBJECTBOX SERVICE: Restoring current connection data');
            moviesBox.putMany(tempMovies);
            seriesBox.putMany(tempSeries);
            channelsBox.putMany(tempChannels);
          }

          debugPrint(
            'OBJECTBOX SERVICE: Content data cleared for non-current connection: $id',
          );
        }

        // Remove the connection
        connectionsBox.remove(connections.first.obId);
        debugPrint('OBJECTBOX SERVICE: Connection deleted successfully');
        return true;
      } else {
        debugPrint('OBJECTBOX SERVICE: Connection not found with ID: $id');
        return false;
      }
    } catch (e) {
      debugPrint('OBJECTBOX SERVICE ERROR: Failed to delete connection: $e');
      return false;
    }
  }

  /// Delete all connections from ObjectBox and clear all content data
  static Future<bool> deleteAllConnections() async {
    try {
      debugPrint(
        'OBJECTBOX SERVICE: Deleting all connections and clearing all content data',
      );

      // Clear all content data
      moviesBox.removeAll();
      seriesBox.removeAll();
      channelsBox.removeAll();

      // Reset preloaded data flag and connection ID
      _hasPreloadedData = false;
      _connectionId = null;

      // Remove all connections
      connectionsBox.removeAll();

      debugPrint(
        'OBJECTBOX SERVICE: All connections and content data deleted successfully',
      );
      return true;
    } catch (e) {
      debugPrint(
        'OBJECTBOX SERVICE ERROR: Failed to delete all connections: $e',
      );
      return false;
    }
  }

  /// Close the ObjectBox store and Admin interface
  static void close() {
    // Close the Admin interface
    ObjectBoxAdmin.close();

    // Close the store
    _store.close();
  }
}
