import 'package:flutter/foundation.dart' hide Category;
import '../models/channel.dart';
import '../models/movie.dart';
import '../models/series.dart';
import '../models/xtream_connection.dart';
import '../services/xtream_service.dart';
import '../models/category.dart';
import '../services/data_preloader_service.dart';
import '../services/hive_service.dart';

class ContentProvider with ChangeNotifier {
  XtreamConnection? _currentConnection;
  XtreamService? _xtreamService;
  DataPreloaderService? _preloaderService;

  // Live TV
  List<Category> _liveCategories = [];
  List<Channel> _liveChannels = [];

  // VOD
  List<Category> _vodCategories = [];
  List<Movie> _movies = [];

  // Series
  List<Category> _seriesCategories = [];
  List<Series> _seriesList = [];

  // Loading and error states
  bool _isLoading = false;
  bool _isPreloading = false;
  String? _error;

  // Preloaded data status
  bool _hasPreloadedData = false;

  // Getters
  XtreamConnection? get currentConnection => _currentConnection;
  List<Category> get liveCategories => _liveCategories;
  List<Channel> get liveChannels => _liveChannels;
  List<Category> get vodCategories => _vodCategories;
  List<Movie> get movies => _movies;
  List<Category> get seriesCategories => _seriesCategories;
  List<Series> get seriesList => _seriesList;
  bool get isLoading => _isLoading;
  bool get isPreloading => _isPreloading;
  bool get hasPreloadedData => _hasPreloadedData;
  String? get error => _error;

  // Set current connection
  void setConnection(XtreamConnection connection) {
    _currentConnection = connection;
    _xtreamService = XtreamService(
      serverUrl: connection.serverUrl,
      username: connection.username,
      password: connection.password,
    );
    _preloaderService = DataPreloaderService(_xtreamService!);

    // Check if we have cached data for this connection
    _checkForCachedData(connection.id);

    notifyListeners();
  }

  // Check for cached data in Hive
  void _checkForCachedData(String connectionId) {
    debugPrint(
      'CONTENT PROVIDER: Checking for cached data for connection $connectionId',
    );

    // Check if we have preloaded data flag
    final hasPreloadedData = HiveService.hasPreloadedData();
    final cachedConnectionId = HiveService.getConnectionId();

    if (hasPreloadedData && cachedConnectionId == connectionId) {
      debugPrint(
        'CONTENT PROVIDER: Found cached data for connection $connectionId',
      );

      // Load data from Hive
      _vodCategories = HiveService.getVodCategories().cast<Category>();
      _seriesCategories = HiveService.getSeriesCategories().cast<Category>();
      _liveCategories = HiveService.getLiveCategories().cast<Category>();
      _movies = HiveService.getMovies().cast<Movie>();
      _seriesList = HiveService.getSeries().cast<Series>();
      _liveChannels = HiveService.getChannels().cast<Channel>();

      _hasPreloadedData = true;

      debugPrint('CONTENT PROVIDER: Loaded cached data:');
      debugPrint('CONTENT PROVIDER: VOD Categories: ${_vodCategories.length}');
      debugPrint(
        'CONTENT PROVIDER: Series Categories: ${_seriesCategories.length}',
      );
      debugPrint(
        'CONTENT PROVIDER: Live Categories: ${_liveCategories.length}',
      );
      debugPrint('CONTENT PROVIDER: Movies: ${_movies.length}');
      debugPrint('CONTENT PROVIDER: Series: ${_seriesList.length}');
      debugPrint('CONTENT PROVIDER: Channels: ${_liveChannels.length}');
    } else {
      debugPrint(
        'CONTENT PROVIDER: No cached data found for connection $connectionId',
      );
      _hasPreloadedData = false;
    }
  }

  // Preload all data for the current connection
  Future<bool> preloadAllData() async {
    debugPrint('CONTENT PROVIDER: Starting preloadAllData()');

    if (_xtreamService == null || _preloaderService == null) {
      debugPrint('CONTENT PROVIDER: Cannot preload - services not initialized');
      return false;
    }

    debugPrint('CONTENT PROVIDER: Setting preloading state to true');
    _isPreloading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('CONTENT PROVIDER: Calling preloaderService.preloadAllData()');
      final preloadedData = await _preloaderService!.preloadAllData();

      // Update the provider with preloaded data
      debugPrint('CONTENT PROVIDER: Updating provider with preloaded data');

      debugPrint(
        'CONTENT PROVIDER: Setting live categories (${preloadedData.liveCategories.length})',
      );
      _liveCategories = preloadedData.liveCategories.cast<Category>();

      debugPrint(
        'CONTENT PROVIDER: Setting VOD categories (${preloadedData.vodCategories.length})',
      );
      _vodCategories = preloadedData.vodCategories.cast<Category>();

      debugPrint(
        'CONTENT PROVIDER: Setting movies (${preloadedData.initialMovies.length})',
      );
      _movies = preloadedData.initialMovies.cast<Movie>();

      debugPrint(
        'CONTENT PROVIDER: Setting series categories (${preloadedData.seriesCategories.length})',
      );
      _seriesCategories = preloadedData.seriesCategories.cast<Category>();

      debugPrint(
        'CONTENT PROVIDER: Setting series list (${preloadedData.initialSeries.length})',
      );
      _seriesList = preloadedData.initialSeries.cast<Series>();

      debugPrint('CONTENT PROVIDER: Setting hasPreloadedData to true');
      _hasPreloadedData = true;
      _isPreloading = false;

      // Save data to Hive
      debugPrint('CONTENT PROVIDER: Saving preloaded data to Hive');
      if (_currentConnection != null) {
        await HiveService.saveVodCategories(
          _vodCategories,
          _currentConnection!.id,
        );
        await HiveService.saveSeriesCategories(
          _seriesCategories,
          _currentConnection!.id,
        );
        await HiveService.saveLiveCategories(
          _liveCategories,
          _currentConnection!.id,
        );
        await HiveService.saveMovies(_movies, _currentConnection!.id);
        await HiveService.saveSeries(_seriesList, _currentConnection!.id);
        await HiveService.saveChannels(_liveChannels, _currentConnection!.id);
        await HiveService.setPreloadedDataFlag(true);
        debugPrint('CONTENT PROVIDER: Data saved to Hive successfully');
      }

      notifyListeners();

      debugPrint('CONTENT PROVIDER: preloadAllData completed successfully');
      return true;
    } catch (e, stackTrace) {
      debugPrint('CONTENT PROVIDER ERROR: Failed to preload data: $e');
      debugPrint('CONTENT PROVIDER ERROR: Stack trace: $stackTrace');
      _error = 'Failed to preload data: $e';
      _isPreloading = false;
      _hasPreloadedData = false;
      notifyListeners();

      debugPrint('CONTENT PROVIDER: preloadAllData failed');
      return false;
    }
  }

  // Clear current connection
  Future<void> clearConnection() async {
    _currentConnection = null;
    _xtreamService = null;
    _preloaderService = null;
    _liveCategories = [];
    _liveChannels = [];
    _vodCategories = [];
    _movies = [];
    _seriesCategories = [];
    _seriesList = [];
    _hasPreloadedData = false;

    // Clear Hive data
    debugPrint('CONTENT PROVIDER: Clearing Hive data');
    await HiveService.clearAllData();

    notifyListeners();
  }

  // Load live categories
  Future<void> loadLiveCategories() async {
    if (_xtreamService == null) return;

    // Skip API call if we already have preloaded data
    if (_hasPreloadedData && _liveCategories.isNotEmpty) {
      debugPrint(
        'CONTENT PROVIDER: Using preloaded live categories, skipping API call',
      );
      return;
    }

    debugPrint('CONTENT PROVIDER: Loading live categories from API');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _liveCategories = await _xtreamService!.getLiveCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load live categories: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load live channels by category
  Future<void> loadLiveChannelsByCategory(String categoryId) async {
    if (_xtreamService == null) return;

    // Skip API call if we already have preloaded data for the first category
    if (_hasPreloadedData &&
        _liveChannels.isNotEmpty &&
        _liveCategories.isNotEmpty &&
        _liveCategories.first.categoryId == categoryId) {
      debugPrint(
        'CONTENT PROVIDER: Using preloaded live channels for category $categoryId, skipping API call',
      );
      return;
    }

    debugPrint(
      'CONTENT PROVIDER: Loading live channels for category $categoryId from API',
    );
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _liveChannels = await _xtreamService!.getLiveStreamsByCategory(
        categoryId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load live channels: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all live channels
  Future<void> loadAllLiveChannels() async {
    if (_xtreamService == null) return;

    // Skip API call if we already have preloaded data
    if (_hasPreloadedData && _liveChannels.isNotEmpty) {
      debugPrint(
        'CONTENT PROVIDER: Using preloaded live channels, skipping API call',
      );
      return;
    }

    debugPrint('CONTENT PROVIDER: Loading all live channels from API');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _liveChannels = await _xtreamService!.getAllLiveStreams();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load all live channels: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load VOD categories
  Future<void> loadVodCategories() async {
    if (_xtreamService == null) return;

    // Skip API call if we already have preloaded data
    if (_hasPreloadedData && _vodCategories.isNotEmpty) {
      debugPrint(
        'CONTENT PROVIDER: Using preloaded VOD categories, skipping API call',
      );
      return;
    }

    debugPrint('CONTENT PROVIDER: Loading VOD categories from API');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vodCategories = await _xtreamService!.getVodCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load VOD categories: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load movies by category
  Future<void> loadMoviesByCategory(String categoryId) async {
    if (_xtreamService == null) return;

    // Skip API call if we already have preloaded data for the first category
    if (_hasPreloadedData &&
        _movies.isNotEmpty &&
        _vodCategories.isNotEmpty &&
        _vodCategories.first.categoryId == categoryId) {
      debugPrint(
        'CONTENT PROVIDER: Using preloaded movies for category $categoryId, skipping API call',
      );
      return;
    }

    debugPrint(
      'CONTENT PROVIDER: Loading movies for category $categoryId from API',
    );
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _movies = await _xtreamService!.getVodStreamsByCategory(categoryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load movies: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load series categories
  Future<void> loadSeriesCategories() async {
    if (_xtreamService == null) return;

    // Skip API call if we already have preloaded data
    if (_hasPreloadedData && _seriesCategories.isNotEmpty) {
      debugPrint(
        'CONTENT PROVIDER: Using preloaded series categories, skipping API call',
      );
      return;
    }

    debugPrint('CONTENT PROVIDER: Loading series categories from API');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _seriesCategories = await _xtreamService!.getSeriesCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load series categories: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load series by category
  Future<void> loadSeriesByCategory(String categoryId) async {
    if (_xtreamService == null) return;

    // Skip API call if we already have preloaded data for the first category
    if (_hasPreloadedData &&
        _seriesList.isNotEmpty &&
        _seriesCategories.isNotEmpty &&
        _seriesCategories.first.categoryId == categoryId) {
      debugPrint(
        'CONTENT PROVIDER: Using preloaded series for category $categoryId, skipping API call',
      );
      return;
    }

    debugPrint(
      'CONTENT PROVIDER: Loading series for category $categoryId from API',
    );
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _seriesList = await _xtreamService!.getSeriesByCategory(categoryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load series: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get series info
  Future<Map<String, dynamic>> getSeriesInfo(String seriesId) async {
    if (_xtreamService == null) {
      throw Exception('No active connection');
    }

    try {
      return await _xtreamService!.getSeriesInfo(seriesId);
    } catch (e) {
      throw Exception('Failed to get series info: $e');
    }
  }

  // Get stream URL for live TV
  String getLiveStreamUrl(String streamId) {
    if (_xtreamService == null) {
      throw Exception('No active connection');
    }

    return _xtreamService!.getLiveStreamUrl(streamId);
  }

  // Get stream URL for VOD
  String getVodStreamUrl(String streamId) {
    if (_xtreamService == null) {
      throw Exception('No active connection');
    }

    return _xtreamService!.getVodStreamUrl(streamId);
  }

  // Get stream URL for series episode
  String getSeriesStreamUrl(String streamId) {
    if (_xtreamService == null) {
      throw Exception('No active connection');
    }

    return _xtreamService!.getSeriesStreamUrl(streamId);
  }
}
