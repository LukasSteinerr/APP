import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/channel.dart';
import '../models/movie.dart';
import '../models/series.dart';

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
  Future<List<Category>> getLiveCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_live_categories'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Category.fromJson(item)).toList();
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
      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_live_streams&category_id=$categoryId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Channel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load live streams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching live streams: $e');
    }
  }

  // Get all live streams
  Future<List<Channel>> getAllLiveStreams() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_live_streams'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Channel.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to load all live streams: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching all live streams: $e');
    }
  }

  // Get VOD categories
  Future<List<Category>> getVodCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_vod_categories'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Category.fromJson(item)).toList();
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
      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_vod_streams&category_id=$categoryId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Movie.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load VOD streams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching VOD streams: $e');
    }
  }

  // Get series categories
  Future<List<Category>> getSeriesCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_series_categories'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Category.fromJson(item)).toList();
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
      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_series&category_id=$categoryId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Series.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load series: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching series: $e');
    }
  }

  // Get series info
  Future<Map<String, dynamic>> getSeriesInfo(String seriesId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl&action=get_series_info&series_id=$seriesId'),
      );

      if (response.statusCode == 200) {
        final dynamic rawData = json.decode(response.body);

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
        return {
          'info': 'No series info available',
          'seasons': {},
          'episodes': {},
        };
      } else {
        throw Exception('Failed to load series info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching series info: $e');
    }
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
