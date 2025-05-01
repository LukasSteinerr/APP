import 'package:objectbox/objectbox.dart';

@Entity()
class Series {
  @Id()
  int id = 0;

  String seriesId;
  String name;
  String cover;
  String plot;
  String cast;
  String director;
  String genre;
  String releaseDate;
  String rating;
  String categoryId;
  String categoryName;
  String? tmdbId;
  String? backdropPath;

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
    required this.categoryName,
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
      categoryName: json['category_name'] ?? '',
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
    'category_name': categoryName,
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
