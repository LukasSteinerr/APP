import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
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

      // Preload movies for the first category if available
      List<Movie> movies = [];
      if (vodCategories.isNotEmpty) {
        final firstCategoryId = vodCategories.first.categoryId;
        debugPrint(
          'PRELOADING: Fetching movies for category ID: $firstCategoryId',
        );
        movies = await _xtreamService.getVodStreamsByCategory(firstCategoryId);
        debugPrint(
          'PRELOADING: Received ${movies.length} movies for first category',
        );
      } else {
        debugPrint('PRELOADING: No VOD categories available to fetch movies');
      }

      // Preload Series data
      debugPrint('PRELOADING: Fetching series categories...');
      final seriesCategories = await _xtreamService.getSeriesCategories();
      debugPrint(
        'PRELOADING: Received ${seriesCategories.length} series categories',
      );

      // Preload series for the first category if available
      List<Series> seriesList = [];
      if (seriesCategories.isNotEmpty) {
        final firstCategoryId = seriesCategories.first.categoryId;
        debugPrint(
          'PRELOADING: Fetching series for category ID: $firstCategoryId',
        );
        seriesList = await _xtreamService.getSeriesByCategory(firstCategoryId);
        debugPrint(
          'PRELOADING: Received ${seriesList.length} series for first category',
        );
      } else {
        debugPrint(
          'PRELOADING: No series categories available to fetch series',
        );
      }

      // Preload Live TV categories
      debugPrint('PRELOADING: Fetching Live TV categories...');
      final liveCategories = await _xtreamService.getLiveCategories();
      debugPrint(
        'PRELOADING: Received ${liveCategories.length} Live TV categories',
      );

      // Preload live channels for the first category if available
      List<Channel> liveChannels = [];
      if (liveCategories.isNotEmpty) {
        final firstCategoryId = liveCategories.first.categoryId;
        debugPrint(
          'PRELOADING: Fetching live channels for category ID: $firstCategoryId',
        );
        liveChannels = await _xtreamService.getLiveStreamsByCategory(
          firstCategoryId,
        );
        debugPrint(
          'PRELOADING: Received ${liveChannels.length} live channels for first category',
        );
      } else {
        debugPrint(
          'PRELOADING: No live categories available to fetch channels',
        );
      }

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
  final List<Category> vodCategories;
  final List<Movie> initialMovies;
  final List<Category> seriesCategories;
  final List<Series> initialSeries;
  final List<Category> liveCategories;
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
