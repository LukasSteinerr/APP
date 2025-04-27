import 'package:flutter/foundation.dart';
import '../models/channel.dart';
import '../models/movie.dart';
import '../models/series.dart';
import '../services/compute_service.dart';

/// A service for handling data processing tasks in isolates
class DataProcessingService {
  /// Filter channels by search query in an isolate
  static Future<List<Channel>> filterChannels(
    List<Channel> channels,
    String query,
  ) async {
    if (query.isEmpty) {
      return channels;
    }

    // Use isolate for filtering
    return await ComputeService.compute<_FilterChannelsParams, List<Channel>>(
      _filterChannelsIsolate,
      _FilterChannelsParams(channels: channels, query: query.toLowerCase()),
    );
  }

  /// Filter channels implementation for isolate
  static List<Channel> _filterChannelsIsolate(_FilterChannelsParams params) {
    return params.channels.where((channel) {
      return channel.name.toLowerCase().contains(params.query);
    }).toList();
  }

  /// Filter movies by search query in an isolate
  static Future<List<Movie>> filterMovies(
    List<Movie> movies,
    String query,
  ) async {
    if (query.isEmpty) {
      return movies;
    }

    // Use isolate for filtering
    return await ComputeService.compute<_FilterMoviesParams, List<Movie>>(
      _filterMoviesIsolate,
      _FilterMoviesParams(movies: movies, query: query.toLowerCase()),
    );
  }

  /// Filter movies implementation for isolate
  static List<Movie> _filterMoviesIsolate(_FilterMoviesParams params) {
    return params.movies.where((movie) {
      return movie.name.toLowerCase().contains(params.query);
    }).toList();
  }

  /// Filter series by search query in an isolate
  static Future<List<Series>> filterSeries(
    List<Series> seriesList,
    String query,
  ) async {
    if (query.isEmpty) {
      return seriesList;
    }

    // Use isolate for filtering
    return await ComputeService.compute<_FilterSeriesParams, List<Series>>(
      _filterSeriesIsolate,
      _FilterSeriesParams(seriesList: seriesList, query: query.toLowerCase()),
    );
  }

  /// Filter series implementation for isolate
  static List<Series> _filterSeriesIsolate(_FilterSeriesParams params) {
    return params.seriesList.where((series) {
      return series.name.toLowerCase().contains(params.query);
    }).toList();
  }

  /// Sort channels by name in an isolate
  static Future<List<Channel>> sortChannels(List<Channel> channels) async {
    return await ComputeService.compute<List<Channel>, List<Channel>>(
      _sortChannelsIsolate,
      channels,
    );
  }

  /// Sort channels implementation for isolate
  static List<Channel> _sortChannelsIsolate(List<Channel> channels) {
    final sortedList = List<Channel>.from(channels);
    sortedList.sort((a, b) => a.name.compareTo(b.name));
    return sortedList;
  }
}

/// Parameter class for filtering channels
class _FilterChannelsParams {
  final List<Channel> channels;
  final String query;

  _FilterChannelsParams({required this.channels, required this.query});
}

/// Parameter class for filtering movies
class _FilterMoviesParams {
  final List<Movie> movies;
  final String query;

  _FilterMoviesParams({required this.movies, required this.query});
}

/// Parameter class for filtering series
class _FilterSeriesParams {
  final List<Series> seriesList;
  final String query;

  _FilterSeriesParams({required this.seriesList, required this.query});
}
