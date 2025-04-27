import 'package:hive/hive.dart';

part 'series.g.dart';

@HiveType(typeId: 3)
class Series {
  @HiveField(0)
  final String seriesId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String cover;

  @HiveField(3)
  final String plot;

  @HiveField(4)
  final String cast;

  @HiveField(5)
  final String director;

  @HiveField(6)
  final String genre;

  @HiveField(7)
  final String releaseDate;

  @HiveField(8)
  final String rating;

  @HiveField(9)
  final String categoryId;

  @HiveField(10)
  final String? tmdbId;

  @HiveField(11)
  final String? backdropPath;

  Series({
    required this.seriesId,
    required this.name,
    required this.cover,
    required this.plot,
    required this.cast,
    required this.director,
    required this.genre,
    required this.releaseDate,
    required this.rating,
    required this.categoryId,
    this.tmdbId,
    this.backdropPath,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert various types to string
    String safeToString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List) return value.join(', ');
      return value.toString();
    }

    return Series(
      seriesId: json['series_id']?.toString() ?? '',
      name: json['name'] ?? '',
      cover: json['cover'] ?? json['poster'] ?? json['stream_icon'] ?? '',
      plot: safeToString(json['plot']),
      cast: safeToString(json['cast']),
      director: safeToString(json['director']),
      genre: safeToString(json['genre']),
      releaseDate: safeToString(json['releaseDate']),
      rating: safeToString(json['rating']),
      categoryId: json['category_id']?.toString() ?? '',
      tmdbId: json['tmdb']?.toString() ?? json['tmdb_id']?.toString(),
      backdropPath:
          json['backdrop_path'] is String ? json['backdrop_path'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'series_id': seriesId,
    'name': name,
    'cover': cover,
    'plot': plot,
    'cast': cast,
    'director': director,
    'genre': genre,
    'releaseDate': releaseDate,
    'rating': rating,
    'category_id': categoryId,
    'tmdb_id': tmdbId,
    'backdrop_path': backdropPath,
  };
}

class Season {
  final String seasonNumber;
  final String airDate;
  final String episodeCount;
  final String cover;
  final String name;

  Season({
    required this.seasonNumber,
    required this.airDate,
    required this.episodeCount,
    required this.cover,
    required this.name,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert various types to string
    String safeToString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List) return value.join(', ');
      return value.toString();
    }

    return Season(
      seasonNumber: json['season_number']?.toString() ?? '',
      airDate: safeToString(json['air_date']),
      episodeCount: json['episode_count']?.toString() ?? '',
      cover: safeToString(json['cover']),
      name: safeToString(json['name']),
    );
  }
}

class Episode {
  final String id;
  final String episodeNum;
  final String title;
  final String containerExtension;
  final String info;
  final String? added;
  final String? seasonNumber;
  final String? cover;

  Episode({
    required this.id,
    required this.episodeNum,
    required this.title,
    required this.containerExtension,
    required this.info,
    this.added,
    this.seasonNumber,
    this.cover,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert various types to string
    String safeToString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List) return value.join(', ');
      return value.toString();
    }

    return Episode(
      id: json['id']?.toString() ?? '',
      episodeNum: json['episode_num']?.toString() ?? '',
      title: safeToString(json['title']),
      containerExtension: safeToString(json['container_extension']),
      info: safeToString(json['info']),
      added: json['added'] is String ? json['added'] : null,
      seasonNumber: json['season']?.toString(),
      cover: json['cover'] is String ? json['cover'] : null,
    );
  }
}
