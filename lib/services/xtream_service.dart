import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_item.dart';
import '../models/channel.dart';
import '../models/movie.dart';
import '../models/series.dart';
import '../services/compute_service.dart';

enum CategoryType { live, vod, series }

class XtreamService {
  final String serverUrl;
  final String username;
  final String password;

  XtreamService({
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  String get _baseUrl {
    // Normalize the URL
    String url = serverUrl;

    // Add http:// if missing
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }

    // Remove trailing slash if present
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    return '$url/player_api.php?username=$username&password=$password';
  }

  // Get live stream categories
  Future<List<CategoryItem>> getLiveCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_live_categories'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (item) => CategoryItem(
                categoryId: item['category_id']?.toString() ?? '',
                categoryName: item['category_name'] ?? '',
              ),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load live categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching live categories: $e');
    }
  }

  // Get live streams by category
  Future<List<Channel>> getLiveStreamsByCategory(String categoryId) async {
    try {
      // First get the category name
      String categoryName = await _getCategoryName(
        categoryId,
        CategoryType.live,
      );

      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_live_streams&category_id=$categoryId'),
      );

      if (response.statusCode == 200) {
        // Use isolate to parse JSON and create model objects with category name
        return await ComputeService.compute<
          Map<String, dynamic>,
          List<Channel>
        >(_parseLiveStreamsWithCategory, {
          'responseBody': response.body,
          'categoryName': categoryName,
        });
      } else {
        throw Exception('Failed to load live streams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching live streams: $e');
    }
  }

  // Helper method to get category name from category ID
  Future<String> _getCategoryName(String categoryId, CategoryType type) async {
    try {
      List<CategoryItem> categories;

      // Get the appropriate categories based on type
      switch (type) {
        case CategoryType.live:
          categories = await getLiveCategories();
          break;
        case CategoryType.vod:
          categories = await getVodCategories();
          break;
        case CategoryType.series:
          categories = await getSeriesCategories();
          break;
      }

      // Find the category with the matching ID
      final category = categories.firstWhere(
        (c) => c.categoryId == categoryId,
        orElse:
            () => CategoryItem(
              categoryId: categoryId,
              categoryName: 'Unknown Category',
            ),
      );

      return category.categoryName;
    } catch (e) {
      // Return a default value if there's an error
      return 'Unknown Category';
    }
  }

  // Static method for parsing live streams with category name in isolate
  static List<Channel> _parseLiveStreamsWithCategory(
    Map<String, dynamic> params,
  ) {
    final String responseBody = params['responseBody'];
    final String categoryName = params['categoryName'];

    final List<dynamic> data = json.decode(responseBody);
    return data.map((item) {
      // Add category name to the JSON before creating the Channel object
      final Map<String, dynamic> itemWithCategory = Map<String, dynamic>.from(
        item,
      );
      itemWithCategory['category_name'] = categoryName;
      return Channel.fromJson(itemWithCategory);
    }).toList();
  }

  // Get all live streams
  Future<List<Channel>> getAllLiveStreams() async {
    try {
      // First get all categories to map category IDs to names
      final categories = await getLiveCategories();
      final Map<String, String> categoryMap = {
        for (var category in categories)
          category.categoryId: category.categoryName,
      };

      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_live_streams'),
      );

      if (response.statusCode == 200) {
        // Use isolate to parse JSON and create model objects with category names
        return await ComputeService.compute<
          Map<String, dynamic>,
          List<Channel>
        >(_parseAllLiveStreamsWithCategories, {
          'responseBody': response.body,
          'categoryMap': categoryMap,
        });
      } else {
        throw Exception(
          'Failed to load all live streams: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching all live streams: $e');
    }
  }

  // Static method for parsing all live streams with category names in isolate
  static List<Channel> _parseAllLiveStreamsWithCategories(
    Map<String, dynamic> params,
  ) {
    final String responseBody = params['responseBody'];
    final Map<String, String> categoryMap = params['categoryMap'];

    final List<dynamic> data = json.decode(responseBody);
    return data.map((item) {
      // Add category name to the JSON before creating the Channel object
      final Map<String, dynamic> itemWithCategory = Map<String, dynamic>.from(
        item,
      );
      final String categoryId = item['category_id']?.toString() ?? '';
      itemWithCategory['category_name'] =
          categoryMap[categoryId] ?? 'Unknown Category';
      return Channel.fromJson(itemWithCategory);
    }).toList();
  }

  // Get VOD categories
  Future<List<CategoryItem>> getVodCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_vod_categories'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (item) => CategoryItem(
                categoryId: item['category_id']?.toString() ?? '',
                categoryName: item['category_name'] ?? '',
              ),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load VOD categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching VOD categories: $e');
    }
  }

  // Get VOD streams by category
  Future<List<Movie>> getVodStreamsByCategory(String categoryId) async {
    try {
      // First get the category name
      String categoryName = await _getCategoryName(
        categoryId,
        CategoryType.vod,
      );

      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_vod_streams&category_id=$categoryId'),
      );

      if (response.statusCode == 200) {
        // Use isolate to parse JSON and create model objects with category name
        return await ComputeService.compute<Map<String, dynamic>, List<Movie>>(
          _parseMoviesWithCategory,
          {'responseBody': response.body, 'categoryName': categoryName},
        );
      } else {
        throw Exception('Failed to load VOD streams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching VOD streams: $e');
    }
  }

  // Static method for parsing movies with category name in isolate
  static List<Movie> _parseMoviesWithCategory(Map<String, dynamic> params) {
    final String responseBody = params['responseBody'];
    final String categoryName = params['categoryName'];

    final List<dynamic> data = json.decode(responseBody);
    return data.map((item) {
      // Add category name to the JSON before creating the Movie object
      final Map<String, dynamic> itemWithCategory = Map<String, dynamic>.from(
        item,
      );
      itemWithCategory['category_name'] = categoryName;
      return Movie.fromJson(itemWithCategory);
    }).toList();
  }

  // Get series categories
  Future<List<CategoryItem>> getSeriesCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_series_categories'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (item) => CategoryItem(
                categoryId: item['category_id']?.toString() ?? '',
                categoryName: item['category_name'] ?? '',
              ),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load series categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching series categories: $e');
    }
  }

  // Get series by category
  Future<List<Series>> getSeriesByCategory(String categoryId) async {
    try {
      // First get the category name
      String categoryName = await _getCategoryName(
        categoryId,
        CategoryType.series,
      );

      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_series&category_id=$categoryId'),
      );

      if (response.statusCode == 200) {
        // Use isolate to parse JSON and create model objects with category name
        return await ComputeService.compute<Map<String, dynamic>, List<Series>>(
          _parseSeriesWithCategory,
          {'responseBody': response.body, 'categoryName': categoryName},
        );
      } else {
        throw Exception('Failed to load series: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching series: $e');
    }
  }

  // Static method for parsing series with category name in isolate
  static List<Series> _parseSeriesWithCategory(Map<String, dynamic> params) {
    final String responseBody = params['responseBody'];
    final String categoryName = params['categoryName'];

    final List<dynamic> data = json.decode(responseBody);
    return data.map((item) {
      // Add category name to the JSON before creating the Series object
      final Map<String, dynamic> itemWithCategory = Map<String, dynamic>.from(
        item,
      );
      itemWithCategory['category_name'] = categoryName;
      return Series.fromJson(itemWithCategory);
    }).toList();
  }

  // Get series info
  Future<Map<String, dynamic>> getSeriesInfo(String seriesId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_series_info&series_id=$seriesId'),
      );

      if (response.statusCode == 200) {
        // Use isolate to parse JSON and process the data
        return await ComputeService.compute<String, Map<String, dynamic>>(
          _parseSeriesInfo,
          response.body,
        );
      } else {
        throw Exception('Failed to load series info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching series info: $e');
    }
  }

  // Static method for parsing series info in isolate
  static Map<String, dynamic> _parseSeriesInfo(String responseBody) {
    final dynamic rawData = json.decode(responseBody);

    // Handle both Map and List responses
    if (rawData is Map<String, dynamic>) {
      return rawData;
    } else if (rawData is List && rawData.isNotEmpty) {
      // If it's a list, take the first item if it's a map
      if (rawData[0] is Map<String, dynamic>) {
        return rawData[0] as Map<String, dynamic>;
      }
    }

    // If we can't parse it as expected, return an empty map with info
    return {'info': 'No series info available', 'seasons': {}, 'episodes': {}};
  }

  // Normalize URL for stream URLs
  String _getNormalizedUrl() {
    // Normalize the URL
    String url = serverUrl;

    // Add http:// if missing
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }

    // Remove trailing slash if present
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    return url;
  }

  // Get stream URL for live TV
  String getLiveStreamUrl(String streamId) {
    final url = _getNormalizedUrl();
    return '$url/$username/$password/$streamId.ts';
  }

  // Get stream URL for VOD
  String getVodStreamUrl(String streamId) {
    final url = _getNormalizedUrl();
    return '$url/movie/$username/$password/$streamId.mp4';
  }

  // Get stream URL for series episode
  String getSeriesStreamUrl(String streamId) {
    final url = _getNormalizedUrl();
    return '$url/series/$username/$password/$streamId.mp4';
  }
}
