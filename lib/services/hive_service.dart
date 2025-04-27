import 'package:flutter/foundation.dart' hide Category;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/category.dart';
import '../models/channel.dart';
import '../models/movie.dart';
import '../models/series.dart';

/// Service for managing Hive database operations
class HiveService {
  static const String _vodCategoriesBoxName = 'vod_categories';
  static const String _seriesCategoriesBoxName = 'series_categories';
  static const String _liveCategoriesBoxName = 'live_categories';
  static const String _moviesBoxName = 'movies';
  static const String _seriesBoxName = 'series';
  static const String _channelsBoxName = 'channels';
  static const String _preloadedDataFlagBoxName = 'preloaded_data_flag';
  static const String _preloadedDataKey = 'has_preloaded_data';
  static const String _connectionIdKey = 'connection_id';

  /// Initialize Hive
  static Future<void> init() async {
    try {
      debugPrint('HIVE SERVICE: Initializing Hive...');
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);

      // Register adapters
      Hive.registerAdapter(CategoryAdapter());
      Hive.registerAdapter(MovieAdapter());
      Hive.registerAdapter(SeriesAdapter());
      Hive.registerAdapter(ChannelAdapter());

      // Open boxes
      await Hive.openBox<Category>(_vodCategoriesBoxName);
      await Hive.openBox<Category>(_seriesCategoriesBoxName);
      await Hive.openBox<Category>(_liveCategoriesBoxName);
      await Hive.openBox<Movie>(_moviesBoxName);
      await Hive.openBox<Series>(_seriesBoxName);
      await Hive.openBox<Channel>(_channelsBoxName);
      await Hive.openBox<String>(_preloadedDataFlagBoxName);

      debugPrint('HIVE SERVICE: Hive initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('HIVE SERVICE ERROR: Failed to initialize Hive: $e');
      debugPrint('HIVE SERVICE ERROR: Stack trace: $stackTrace');
    }
  }

  /// Save VOD categories to Hive
  static Future<void> saveVodCategories(
    List<Category> categories,
    String connectionId,
  ) async {
    try {
      debugPrint('HIVE SERVICE: Saving ${categories.length} VOD categories');
      final box = Hive.box<Category>(_vodCategoriesBoxName);
      await box.clear();
      for (var i = 0; i < categories.length; i++) {
        await box.put(i, categories[i]);
      }
      await _saveConnectionId(connectionId);
      debugPrint('HIVE SERVICE: VOD categories saved successfully');
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to save VOD categories: $e');
    }
  }

  /// Save Series categories to Hive
  static Future<void> saveSeriesCategories(
    List<Category> categories,
    String connectionId,
  ) async {
    try {
      debugPrint('HIVE SERVICE: Saving ${categories.length} Series categories');
      final box = Hive.box<Category>(_seriesCategoriesBoxName);
      await box.clear();
      for (var i = 0; i < categories.length; i++) {
        await box.put(i, categories[i]);
      }
      await _saveConnectionId(connectionId);
      debugPrint('HIVE SERVICE: Series categories saved successfully');
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to save Series categories: $e');
    }
  }

  /// Save Live categories to Hive
  static Future<void> saveLiveCategories(
    List<Category> categories,
    String connectionId,
  ) async {
    try {
      debugPrint('HIVE SERVICE: Saving ${categories.length} Live categories');
      final box = Hive.box<Category>(_liveCategoriesBoxName);
      await box.clear();
      for (var i = 0; i < categories.length; i++) {
        await box.put(i, categories[i]);
      }
      await _saveConnectionId(connectionId);
      debugPrint('HIVE SERVICE: Live categories saved successfully');
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to save Live categories: $e');
    }
  }

  /// Save Movies to Hive
  static Future<void> saveMovies(
    List<Movie> movies,
    String connectionId,
  ) async {
    try {
      debugPrint('HIVE SERVICE: Saving ${movies.length} Movies');
      final box = Hive.box<Movie>(_moviesBoxName);
      await box.clear();
      for (var i = 0; i < movies.length; i++) {
        await box.put(i, movies[i]);
      }
      await _saveConnectionId(connectionId);
      debugPrint('HIVE SERVICE: Movies saved successfully');
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to save Movies: $e');
    }
  }

  /// Save Series to Hive
  static Future<void> saveSeries(
    List<Series> series,
    String connectionId,
  ) async {
    try {
      debugPrint('HIVE SERVICE: Saving ${series.length} Series');
      final box = Hive.box<Series>(_seriesBoxName);
      await box.clear();
      for (var i = 0; i < series.length; i++) {
        await box.put(i, series[i]);
      }
      await _saveConnectionId(connectionId);
      debugPrint('HIVE SERVICE: Series saved successfully');
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to save Series: $e');
    }
  }

  /// Save Channels to Hive
  static Future<void> saveChannels(
    List<Channel> channels,
    String connectionId,
  ) async {
    try {
      debugPrint('HIVE SERVICE: Saving ${channels.length} Channels');
      final box = Hive.box<Channel>(_channelsBoxName);
      await box.clear();
      for (var i = 0; i < channels.length; i++) {
        await box.put(i, channels[i]);
      }
      await _saveConnectionId(connectionId);
      debugPrint('HIVE SERVICE: Channels saved successfully');
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to save Channels: $e');
    }
  }

  /// Save connection ID
  static Future<void> _saveConnectionId(String connectionId) async {
    try {
      final box = Hive.box<String>(_preloadedDataFlagBoxName);
      await box.put(_connectionIdKey, connectionId);
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to save connection ID: $e');
    }
  }

  /// Get connection ID
  static String? getConnectionId() {
    try {
      final box = Hive.box<String>(_preloadedDataFlagBoxName);
      return box.get(_connectionIdKey);
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to get connection ID: $e');
      return null;
    }
  }

  /// Set preloaded data flag
  static Future<void> setPreloadedDataFlag(bool value) async {
    try {
      final box = Hive.box<String>(_preloadedDataFlagBoxName);
      await box.put(_preloadedDataKey, value.toString());
      debugPrint('HIVE SERVICE: Preloaded data flag set to $value');
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to set preloaded data flag: $e');
    }
  }

  /// Check if preloaded data exists
  static bool hasPreloadedData() {
    try {
      final box = Hive.box<String>(_preloadedDataFlagBoxName);
      final value = box.get(_preloadedDataKey);
      return value == 'true';
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to check preloaded data flag: $e');
      return false;
    }
  }

  /// Get VOD categories from Hive
  static List<Category> getVodCategories() {
    try {
      final box = Hive.box<Category>(_vodCategoriesBoxName);
      return box.values.toList();
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to get VOD categories: $e');
      return [];
    }
  }

  /// Get Series categories from Hive
  static List<Category> getSeriesCategories() {
    try {
      final box = Hive.box<Category>(_seriesCategoriesBoxName);
      return box.values.toList();
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to get Series categories: $e');
      return [];
    }
  }

  /// Get Live categories from Hive
  static List<Category> getLiveCategories() {
    try {
      final box = Hive.box<Category>(_liveCategoriesBoxName);
      return box.values.toList();
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to get Live categories: $e');
      return [];
    }
  }

  /// Get Movies from Hive
  static List<Movie> getMovies() {
    try {
      final box = Hive.box<Movie>(_moviesBoxName);
      return box.values.toList();
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to get Movies: $e');
      return [];
    }
  }

  /// Get Series from Hive
  static List<Series> getSeries() {
    try {
      final box = Hive.box<Series>(_seriesBoxName);
      return box.values.toList();
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to get Series: $e');
      return [];
    }
  }

  /// Get Channels from Hive
  static List<Channel> getChannels() {
    try {
      final box = Hive.box<Channel>(_channelsBoxName);
      return box.values.toList();
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to get Channels: $e');
      return [];
    }
  }

  /// Clear all data
  static Future<void> clearAllData() async {
    try {
      debugPrint('HIVE SERVICE: Clearing all data');
      await Hive.box<Category>(_vodCategoriesBoxName).clear();
      await Hive.box<Category>(_seriesCategoriesBoxName).clear();
      await Hive.box<Category>(_liveCategoriesBoxName).clear();
      await Hive.box<Movie>(_moviesBoxName).clear();
      await Hive.box<Series>(_seriesBoxName).clear();
      await Hive.box<Channel>(_channelsBoxName).clear();
      await Hive.box<String>(_preloadedDataFlagBoxName).clear();
      debugPrint('HIVE SERVICE: All data cleared successfully');
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to clear all data: $e');
    }
  }

  /// Get the path to the Hive database directory
  static Future<String> getHiveDatabasePath() async {
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final hivePath = '${appDocumentDir.path}/hive';
      debugPrint('HIVE SERVICE: Database path: $hivePath');
      return hivePath;
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to get Hive database path: $e');
      return 'Unknown';
    }
  }

  /// Get database statistics
  static Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final stats = {
        'vodCategories': getVodCategories().length,
        'seriesCategories': getSeriesCategories().length,
        'liveCategories': getLiveCategories().length,
        'movies': getMovies().length,
        'series': getSeries().length,
        'channels': getChannels().length,
        'hasPreloadedData': hasPreloadedData(),
        'connectionId': getConnectionId(),
        'databasePath': await getHiveDatabasePath(),
      };

      debugPrint('HIVE SERVICE: Database stats: $stats');
      return stats;
    } catch (e) {
      debugPrint('HIVE SERVICE ERROR: Failed to get database stats: $e');
      return {'error': e.toString()};
    }
  }
}
