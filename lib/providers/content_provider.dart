import 'package:flutter/foundation.dart' hide Category;
import '../models/channel.dart';
import '../models/movie.dart';
import '../models/series.dart';
import '../models/xtream_connection.dart';
import '../services/xtream_service.dart';
import '../models/category.dart';
import '../services/data_preloader_service.dart';
import '../services/objectbox_service.dart';
import '../services/network_service.dart';

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
    final stopwatch = Stopwatch()..start();
    debugPrint('TIMING: setConnection started');

    _currentConnection = connection;
    _xtreamService = XtreamService(
      serverUrl: connection.serverUrl,
      username: connection.username,
      password: connection.password,
    );
    _preloaderService = DataPreloaderService(_xtreamService!);

    debugPrint(
      'TIMING: Services initialized in ${stopwatch.elapsedMilliseconds}ms',
    );

    // Check if we have cached data for this connection
    _checkForCachedData(connection.id);

    debugPrint(
      'TIMING: setConnection completed in ${stopwatch.elapsedMilliseconds}ms',
    );
    notifyListeners();
  }

  // Check for cached data in ObjectBox
  void _checkForCachedData(String connectionId) {
    final stopwatch = Stopwatch()..start();

    debugPrint(
      'CONTENT PROVIDER: Checking for cached data for connection $connectionId',
    );

    // Check if we have preloaded data flag
    final hasPreloadedData = ObjectBoxService.hasPreloadedData();
    final cachedConnectionId = ObjectBoxService.getConnectionId();

    debugPrint(
      'CONTENT PROVIDER: Database hasPreloadedData flag = $hasPreloadedData',
    );
    debugPrint(
      'CONTENT PROVIDER: Database cachedConnectionId = $cachedConnectionId',
    );
    debugPrint('CONTENT PROVIDER: Current connectionId = $connectionId');

    // Force using cached data if available, even if connection ID doesn't match
    // This is a temporary fix to diagnose the issue
    if (hasPreloadedData) {
      debugPrint(
        'CONTENT PROVIDER: Found cached data, loading it (elapsed: ${stopwatch.elapsedMilliseconds}ms)',
      );

      // Load data from ObjectBox
      _vodCategories = ObjectBoxService.getVodCategories().cast<Category>();
      _seriesCategories =
          ObjectBoxService.getSeriesCategories().cast<Category>();
      _liveCategories = ObjectBoxService.getLiveCategories().cast<Category>();
      _movies = ObjectBoxService.getMovies().cast<Movie>();
      _seriesList = ObjectBoxService.getSeries().cast<Series>();
      _liveChannels = ObjectBoxService.getChannels().cast<Channel>();

      _hasPreloadedData = true;

      debugPrint(
        'CONTENT PROVIDER: Loaded cached data (elapsed: ${stopwatch.elapsedMilliseconds}ms):',
      );
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

      // Update the connection ID in the database to match the current one
      ObjectBoxService.saveConnectionId(connectionId);
      debugPrint(
        'CONTENT PROVIDER: Updated connection ID in database to $connectionId',
      );
    } else {
      debugPrint(
        'CONTENT PROVIDER: No cached data found for connection $connectionId (elapsed: ${stopwatch.elapsedMilliseconds}ms)',
      );
      _hasPreloadedData = false;
    }

    debugPrint(
      'CONTENT PROVIDER: _checkForCachedData completed in ${stopwatch.elapsedMilliseconds}ms',
    );
  }

  // Check if we can make API calls
  Future<bool> _canMakeApiCalls() async {
    final stopwatch = Stopwatch()..start();
    debugPrint('TIMING: _canMakeApiCalls started');

    // If we have preloaded data, use it regardless of internet connection
    if (_hasPreloadedData) {
      debugPrint('CONTENT PROVIDER: Using preloaded data, skipping API calls');
      debugPrint(
        'TIMING: _canMakeApiCalls completed in ${stopwatch.elapsedMilliseconds}ms (using preloaded data)',
      );
      return false; // Don't make API calls, use cached data
    }

    // Check if we have cached data in ObjectBox
    final hasPreloadedDataInDB = ObjectBoxService.hasPreloadedData();
    if (hasPreloadedDataInDB) {
      debugPrint('CONTENT PROVIDER: Found cached data in database, loading it');

      // Load data from ObjectBox
      if (_currentConnection != null) {
        _checkForCachedData(_currentConnection!.id);
        debugPrint(
          'TIMING: _canMakeApiCalls completed in ${stopwatch.elapsedMilliseconds}ms (loaded from database)',
        );
        return false; // Don't make API calls, use cached data
      }
    }

    // If we don't have internet connection, check if we have cached data
    if (!await NetworkService.hasInternetConnection()) {
      debugPrint('CONTENT PROVIDER: No internet connection');

      // If we have a connection ID, check if we have cached data for it
      if (_currentConnection != null) {
        final hasPreloadedData = ObjectBoxService.hasPreloadedData();
        final cachedConnectionId = ObjectBoxService.getConnectionId();

        debugPrint(
          'CONTENT PROVIDER: Database hasPreloadedData = $hasPreloadedData',
        );
        debugPrint(
          'CONTENT PROVIDER: Database cachedConnectionId = $cachedConnectionId',
        );
        debugPrint(
          'CONTENT PROVIDER: Current connectionId = ${_currentConnection!.id}',
        );

        // Use cached data even if connection ID doesn't match
        if (hasPreloadedData) {
          debugPrint('CONTENT PROVIDER: Using cached data in offline mode');

          // Load data from ObjectBox if not already loaded
          if (!_hasPreloadedData) {
            _checkForCachedData(_currentConnection!.id);
          }

          debugPrint(
            'TIMING: _canMakeApiCalls completed in ${stopwatch.elapsedMilliseconds}ms (offline mode)',
          );
          return false; // Don't make API calls, use cached data
        } else {
          // No cached data for this connection
          _error = 'No internet connection and no cached data available';
          notifyListeners();
          debugPrint(
            'TIMING: _canMakeApiCalls completed in ${stopwatch.elapsedMilliseconds}ms (no internet, no cache)',
          );
          return false;
        }
      } else {
        _error = 'No internet connection';
        notifyListeners();
        debugPrint(
          'TIMING: _canMakeApiCalls completed in ${stopwatch.elapsedMilliseconds}ms (no internet)',
        );
        return false;
      }
    }

    debugPrint(
      'TIMING: _canMakeApiCalls completed in ${stopwatch.elapsedMilliseconds}ms (will make API calls)',
    );
    return true; // We have internet and no cached data, make API calls
  }

  // Preload all data for the current connection
  Future<bool> preloadAllData() async {
    final stopwatch = Stopwatch()..start();
    debugPrint('TIMING: preloadAllData started');
    debugPrint('CONTENT PROVIDER: Starting preloadAllData()');

    if (_xtreamService == null || _preloaderService == null) {
      debugPrint('CONTENT PROVIDER: Cannot preload - services not initialized');
      debugPrint(
        'TIMING: preloadAllData completed in ${stopwatch.elapsedMilliseconds}ms (services not initialized)',
      );
      return false;
    }

    // Check if we can make API calls
    if (!await _canMakeApiCalls()) {
      debugPrint('CONTENT PROVIDER: Cannot preload - using cached data');
      debugPrint(
        'TIMING: preloadAllData completed in ${stopwatch.elapsedMilliseconds}ms (using cached data)',
      );
      return _hasPreloadedData; // Return true if we have cached data
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

      debugPrint(
        'CONTENT PROVIDER: Setting live channels (${preloadedData.initialChannels.length})',
      );
      _liveChannels = preloadedData.initialChannels.cast<Channel>();

      debugPrint('CONTENT PROVIDER: Setting hasPreloadedData to true');
      _hasPreloadedData = true;
      _isPreloading = false;

      // Save data to ObjectBox
      debugPrint('CONTENT PROVIDER: Saving preloaded data to ObjectBox');
      if (_currentConnection != null) {
        await ObjectBoxService.saveVodCategories(
          _vodCategories,
          _currentConnection!.id,
        );
        await ObjectBoxService.saveSeriesCategories(
          _seriesCategories,
          _currentConnection!.id,
        );
        await ObjectBoxService.saveLiveCategories(
          _liveCategories,
          _currentConnection!.id,
        );
        await ObjectBoxService.saveMovies(_movies, _currentConnection!.id);
        await ObjectBoxService.saveSeries(_seriesList, _currentConnection!.id);
        await ObjectBoxService.saveChannels(
          _liveChannels,
          _currentConnection!.id,
        );
        ObjectBoxService.setPreloadedDataFlag(true);
        debugPrint('CONTENT PROVIDER: Data saved to ObjectBox successfully');
      }

      notifyListeners();

      debugPrint('CONTENT PROVIDER: preloadAllData completed successfully');
      debugPrint(
        'TIMING: preloadAllData completed in ${stopwatch.elapsedMilliseconds}ms (success)',
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint('CONTENT PROVIDER ERROR: Failed to preload data: $e');
      debugPrint('CONTENT PROVIDER ERROR: Stack trace: $stackTrace');
      _error = 'Failed to preload data: $e';
      _isPreloading = false;
      _hasPreloadedData = false;
      notifyListeners();

      debugPrint('CONTENT PROVIDER: preloadAllData failed');
      debugPrint(
        'TIMING: preloadAllData completed in ${stopwatch.elapsedMilliseconds}ms (failed)',
      );
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

    // Clear ObjectBox data
    debugPrint('CONTENT PROVIDER: Clearing ObjectBox data');
    await ObjectBoxService.clearAllData();

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

    // Check if we can make API calls
    if (!await _canMakeApiCalls()) {
      debugPrint(
        'CONTENT PROVIDER: Cannot load live categories - no internet connection',
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

    // Check if we can make API calls
    if (!await _canMakeApiCalls()) {
      debugPrint(
        'CONTENT PROVIDER: Cannot load live channels - no internet connection',
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

    // Check if we can make API calls
    if (!await _canMakeApiCalls()) {
      debugPrint(
        'CONTENT PROVIDER: Cannot load live channels - no internet connection',
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
