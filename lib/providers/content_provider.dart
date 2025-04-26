import 'package:flutter/foundation.dart' hide Category;
import '../models/channel.dart';
import '../models/movie.dart';
import '../models/series.dart';
import '../models/xtream_connection.dart';
import '../services/xtream_service.dart';
import '../models/category.dart';

class ContentProvider with ChangeNotifier {
  XtreamConnection? _currentConnection;
  XtreamService? _xtreamService;

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
  String? _error;

  // Getters
  XtreamConnection? get currentConnection => _currentConnection;
  List<Category> get liveCategories => _liveCategories;
  List<Channel> get liveChannels => _liveChannels;
  List<Category> get vodCategories => _vodCategories;
  List<Movie> get movies => _movies;
  List<Category> get seriesCategories => _seriesCategories;
  List<Series> get seriesList => _seriesList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set current connection
  void setConnection(XtreamConnection connection) {
    _currentConnection = connection;
    _xtreamService = XtreamService(
      serverUrl: connection.serverUrl,
      username: connection.username,
      password: connection.password,
    );
    notifyListeners();
  }

  // Clear current connection
  void clearConnection() {
    _currentConnection = null;
    _xtreamService = null;
    _liveCategories = [];
    _liveChannels = [];
    _vodCategories = [];
    _movies = [];
    _seriesCategories = [];
    _seriesList = [];
    notifyListeners();
  }

  // Load live categories
  Future<void> loadLiveCategories() async {
    if (_xtreamService == null) return;

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
