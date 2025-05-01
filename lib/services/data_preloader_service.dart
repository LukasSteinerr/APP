import 'package:flutter/foundation.dart';
import '../models/category_item.dart';
import '../models/channel.dart';
import '../models/movie.dart';
import '../models/series.dart';
import '../services/xtream_service.dart';

/// A service for preloading data from API calls
class DataPreloaderService {
  final XtreamService _xtreamService;

  DataPreloaderService(this._xtreamService);

  /// Preload all necessary data for the app
  Future<PreloadedData> preloadAllData() async {
    try {
      debugPrint('===== PRELOADING: Starting data preloading process =====');

      // Preload VOD (Movies) data
      debugPrint('PRELOADING: Fetching VOD categories...');
      final vodCategories = await _xtreamService.getVodCategories();
      debugPrint('PRELOADING: Received ${vodCategories.length} VOD categories');

      // Preload all movies across all categories
      debugPrint('PRELOADING: Fetching all movies across all categories...');
      List<Movie> movies = await _xtreamService.getAllVodStreams();
      debugPrint('PRELOADING: Received ${movies.length} movies in total');

      // Preload Series data
      debugPrint('PRELOADING: Fetching series categories...');
      final seriesCategories = await _xtreamService.getSeriesCategories();
      debugPrint(
        'PRELOADING: Received ${seriesCategories.length} series categories',
      );

      // Preload all series across all categories
      debugPrint('PRELOADING: Fetching all series across all categories...');
      List<Series> seriesList = await _xtreamService.getAllSeries();
      debugPrint('PRELOADING: Received ${seriesList.length} series in total');

      // Preload Live TV categories
      debugPrint('PRELOADING: Fetching Live TV categories...');
      final liveCategories = await _xtreamService.getLiveCategories();
      debugPrint(
        'PRELOADING: Received ${liveCategories.length} Live TV categories',
      );

      // Preload all live channels across all categories
      debugPrint(
        'PRELOADING: Fetching all live channels across all categories...',
      );
      List<Channel> liveChannels = await _xtreamService.getAllLiveStreams();
      debugPrint(
        'PRELOADING: Received ${liveChannels.length} live channels in total',
      );

      debugPrint(
        '===== PRELOADING: Data preloading completed successfully =====',
      );

      return PreloadedData(
        vodCategories: vodCategories,
        initialMovies: movies,
        seriesCategories: seriesCategories,
        initialSeries: seriesList,
        liveCategories: liveCategories,
        initialChannels: liveChannels,
      );
    } catch (e, stackTrace) {
      debugPrint('===== PRELOADING ERROR =====');
      debugPrint('Error during data preloading: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('===========================');
      throw Exception('Failed to preload data: $e');
    }
  }
}

/// Class to hold preloaded data
class PreloadedData {
  final List<CategoryItem> vodCategories;
  final List<Movie> initialMovies;
  final List<CategoryItem> seriesCategories;
  final List<Series> initialSeries;
  final List<CategoryItem> liveCategories;
  final List<Channel> initialChannels;

  PreloadedData({
    required this.vodCategories,
    required this.initialMovies,
    required this.seriesCategories,
    required this.initialSeries,
    required this.liveCategories,
    required this.initialChannels,
  });
}
