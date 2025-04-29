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

  /// Chunk a list into smaller lists for better performance
  static Future<List<List<T>>> chunkList<T>(List<T> list, int chunkSize) async {
    return await ComputeService.compute<_ChunkParams<T>, List<List<T>>>(
      _chunkListIsolate,
      _ChunkParams<T>(list: list, chunkSize: chunkSize),
    );
  }

  /// Chunk list implementation for isolate
  static List<List<T>> _chunkListIsolate<T>(_ChunkParams<T> params) {
    final List<List<T>> chunks = [];
    final List<T> list = params.list;
    final int chunkSize = params.chunkSize;

    for (var i = 0; i < list.length; i += chunkSize) {
      final end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
      chunks.add(list.sublist(i, end));
    }

    return chunks;
  }

  /// Process data in chunks to avoid UI jank
  static Future<void> processInChunks<T>({
    required List<T> items,
    required Function(List<T> chunk) processor,
    int chunkSize = 50,
    int delayMillis = 16, // ~1 frame at 60fps
  }) async {
    // Split into chunks
    final chunks = await chunkList<T>(items, chunkSize);

    // Process each chunk with a delay between them
    for (final chunk in chunks) {
      // Process the chunk
      processor(chunk);

      // Add a small delay to allow UI to update
      await Future.delayed(Duration(milliseconds: delayMillis));
    }
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

/// Parameter class for chunking lists
class _ChunkParams<T> {
  final List<T> list;
  final int chunkSize;

  _ChunkParams({required this.list, required this.chunkSize});
}
