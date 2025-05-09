import 'package:flutter/foundation.dart';
import '../models/category.dart' as models;
import '../models/channel.dart';
import '../models/movie.dart';
import '../models/series.dart';
import '../models/xtream_connection.dart';
import '../services/xtream_service.dart';
import '../models/category_item.dart';
import '../services/data_preloader_service.dart';
import '../services/objectbox_service.dart';
import '../services/network_service.dart';

class ContentProvider with ChangeNotifier {
  XtreamConnection? _currentConnection;
  XtreamService? _xtreamService;
  DataPreloaderService? _preloaderService;

  // Live TV
  List<CategoryItem> _liveCategories = [];
  List<Channel> _liveChannels = [];

  // VOD
  List<CategoryItem> _vodCategories = [];
  List<Movie> _movies = [];

  // Series
  List<CategoryItem> _seriesCategories = [];
  List<Series> _seriesList = [];

  // Loading and error states
  bool _isLoading = false;
  bool _isPreloading = false;
  String? _error;

  // Preloaded data status
  bool _hasPreloadedData = false;

  // Getters
  XtreamConnection? get currentConnection => _currentConnection;
  List<CategoryItem> get liveCategories => _liveCategories;
  List<Channel> get liveChannels => _liveChannels;
  List<CategoryItem> get vodCategories => _vodCategories;
  List<Movie> get movies => _movies;
  List<CategoryItem> get seriesCategories => _seriesCategories;
  List<Series> get seriesList => _seriesList;
  bool get isLoading => _isLoading;
  bool get isPreloading => _isPreloading;
  bool get hasPreloadedData => _hasPreloadedData;
  String? get error => _error;

  // Set current connection
  Future<void> setConnection(XtreamConnection connection) async {
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
    await _checkForCachedData(connection.id);

    debugPrint(
      'TIMING: setConnection completed in ${stopwatch.elapsedMilliseconds}ms',
    );
    notifyListeners();
  }

  // Check for cached data in ObjectBox
  Future<void> _checkForCachedData(String connectionId) async {
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
      // Since we no longer have Category entities, we'll create empty category lists
      // and populate them from the content data
      _movies = ObjectBoxService.getMovies().cast<Movie>();
      _seriesList = ObjectBoxService.getSeries().cast<Series>();
      _liveChannels = ObjectBoxService.getChannels().cast<Channel>();

      // Extract category information from the content data
      if (_movies.isNotEmpty) {
        // Create a set to avoid duplicate categories
        final Set<String> categoryIds = {};
        _vodCategories =
            _movies
                .where(
                  (movie) => categoryIds.add(movie.categoryId),
                ) // Only add unique categories
                .map(
                  (movie) => CategoryItem(
                    categoryId: movie.categoryId,
                    categoryName: movie.categoryName,
                  ),
                )
                .toList();
      } else {
        _vodCategories = [];
      }

      if (_seriesList.isNotEmpty) {
        // Create a set to avoid duplicate categories
        final Set<String> categoryIds = {};
        _seriesCategories =
            _seriesList
                .where(
                  (series) => categoryIds.add(series.categoryId),
                ) // Only add unique categories
                .map(
                  (series) => CategoryItem(
                    categoryId: series.categoryId,
                    categoryName: series.categoryName,
                  ),
                )
                .toList();
      } else {
        _seriesCategories = [];
      }

      if (_liveChannels.isNotEmpty) {
        // Create a set to avoid duplicate categories
        final Set<String> categoryIds = {};
        _liveCategories =
            _liveChannels
                .where(
                  (channel) => categoryIds.add(channel.categoryId),
                ) // Only add unique categories
                .map(
                  (channel) => CategoryItem(
                    categoryId: channel.categoryId,
                    categoryName: channel.categoryName,
                  ),
                )
                .toList();
      } else {
        _liveCategories = [];
      }

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

      // Extract and save categories from the loaded content
      await extractAndSaveCategories();

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
        await _checkForCachedData(_currentConnection!.id);
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
            await _checkForCachedData(_currentConnection!.id);
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
      _liveCategories =
          preloadedData.liveCategories
              .map(
                (c) => CategoryItem(
                  categoryId: c.categoryId,
                  categoryName: c.categoryName,
                ),
              )
              .toList();

      debugPrint(
        'CONTENT PROVIDER: Setting VOD categories (${preloadedData.vodCategories.length})',
      );
      _vodCategories =
          preloadedData.vodCategories
              .map(
                (c) => CategoryItem(
                  categoryId: c.categoryId,
                  categoryName: c.categoryName,
                ),
              )
              .toList();

      debugPrint(
        'CONTENT PROVIDER: Setting movies (${preloadedData.initialMovies.length})',
      );
      _movies = preloadedData.initialMovies.cast<Movie>();

      debugPrint(
        'CONTENT PROVIDER: Setting series categories (${preloadedData.seriesCategories.length})',
      );
      _seriesCategories =
          preloadedData.seriesCategories
              .map(
                (c) => CategoryItem(
                  categoryId: c.categoryId,
                  categoryName: c.categoryName,
                ),
              )
              .toList();

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
        // We no longer need to save categories separately as they're included in the content objects
        await ObjectBoxService.saveMovies(_movies, _currentConnection!.id);
        await ObjectBoxService.saveSeries(_seriesList, _currentConnection!.id);
        await ObjectBoxService.saveChannels(
          _liveChannels,
          _currentConnection!.id,
        );

        // Extract and save categories
        await extractAndSaveCategories();

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
      // Convert Category objects to CategoryItem objects
      final categories = await _xtreamService!.getLiveCategories();
      _liveCategories =
          categories
              .map(
                (c) => CategoryItem(
                  categoryId: c.categoryId,
                  categoryName: c.categoryName,
                ),
              )
              .toList();
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

    // If we have preloaded data, filter channels by category from the existing data
    if (_hasPreloadedData && _liveChannels.isNotEmpty) {
      debugPrint(
        'CONTENT PROVIDER: Filtering preloaded live channels for category $categoryId',
      );

      // Get all channels from the database
      final allChannels = ObjectBoxService.getChannels().cast<Channel>();

      // Filter channels by category
      _liveChannels =
          allChannels
              .where((channel) => channel.categoryId == categoryId)
              .toList();

      debugPrint(
        'CONTENT PROVIDER: Found ${_liveChannels.length} channels for category $categoryId',
      );
      notifyListeners();
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
      // Convert Category objects to CategoryItem objects
      final categories = await _xtreamService!.getVodCategories();
      _vodCategories =
          categories
              .map(
                (c) => CategoryItem(
                  categoryId: c.categoryId,
                  categoryName: c.categoryName,
                ),
              )
              .toList();
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

    // If we have preloaded data, filter movies by category from the existing data
    if (_hasPreloadedData && _movies.isNotEmpty) {
      debugPrint(
        'CONTENT PROVIDER: Filtering preloaded movies for category $categoryId',
      );

      // Get all movies from the database
      final allMovies = ObjectBoxService.getMovies().cast<Movie>();

      // Filter movies by category
      _movies =
          allMovies.where((movie) => movie.categoryId == categoryId).toList();

      debugPrint(
        'CONTENT PROVIDER: Found ${_movies.length} movies for category $categoryId',
      );
      notifyListeners();
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
      // Convert Category objects to CategoryItem objects
      final categories = await _xtreamService!.getSeriesCategories();
      _seriesCategories =
          categories
              .map(
                (c) => CategoryItem(
                  categoryId: c.categoryId,
                  categoryName: c.categoryName,
                ),
              )
              .toList();
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

    // If we have preloaded data, filter series by category from the existing data
    if (_hasPreloadedData && _seriesList.isNotEmpty) {
      debugPrint(
        'CONTENT PROVIDER: Filtering preloaded series for category $categoryId',
      );

      // Get all series from the database
      final allSeries = ObjectBoxService.getSeries().cast<Series>();

      // Filter series by category
      _seriesList =
          allSeries.where((series) => series.categoryId == categoryId).toList();

      debugPrint(
        'CONTENT PROVIDER: Found ${_seriesList.length} series for category $categoryId',
      );
      notifyListeners();
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

  // Extract and save categories from content
  Future<void> extractAndSaveCategories() async {
    debugPrint('CONTENT PROVIDER: Extracting and saving categories');

    if (_currentConnection == null) {
      debugPrint(
        'CONTENT PROVIDER: Cannot extract categories - no active connection',
      );
      return;
    }

    try {
      final List<models.Category> allCategories = [];

      // Extract VOD categories
      if (_vodCategories.isNotEmpty) {
        debugPrint(
          'CONTENT PROVIDER: Extracting ${_vodCategories.length} VOD categories',
        );
        final vodCats =
            _vodCategories
                .map(
                  (cat) => models.Category(
                    categoryId: cat.categoryId,
                    categoryName: cat.categoryName,
                    contentType: 'vod',
                    playlistId: _currentConnection!.obId,
                  ),
                )
                .toList();
        allCategories.addAll(vodCats);
      }

      // Extract Live categories
      if (_liveCategories.isNotEmpty) {
        debugPrint(
          'CONTENT PROVIDER: Extracting ${_liveCategories.length} Live categories',
        );
        final liveCats =
            _liveCategories
                .map(
                  (cat) => models.Category(
                    categoryId: cat.categoryId,
                    categoryName: cat.categoryName,
                    contentType: 'live',
                    playlistId: _currentConnection!.obId,
                  ),
                )
                .toList();
        allCategories.addAll(liveCats);
      }

      // Extract Series categories
      if (_seriesCategories.isNotEmpty) {
        debugPrint(
          'CONTENT PROVIDER: Extracting ${_seriesCategories.length} Series categories',
        );
        final seriesCats =
            _seriesCategories
                .map(
                  (cat) => models.Category(
                    categoryId: cat.categoryId,
                    categoryName: cat.categoryName,
                    contentType: 'series',
                    playlistId: _currentConnection!.obId,
                  ),
                )
                .toList();
        allCategories.addAll(seriesCats);
      }

      // Save categories to ObjectBox
      if (allCategories.isNotEmpty) {
        debugPrint(
          'CONTENT PROVIDER: Saving ${allCategories.length} categories to ObjectBox',
        );
        await ObjectBoxService.saveCategories(
          allCategories,
          _currentConnection!.id,
        );
        debugPrint('CONTENT PROVIDER: Categories saved successfully');
      } else {
        debugPrint('CONTENT PROVIDER: No categories to save');
      }
    } catch (e) {
      debugPrint(
        'CONTENT PROVIDER ERROR: Failed to extract and save categories: $e',
      );
    }
  }
}
