import 'package:hive/hive.dart';

part 'movie.g.dart';

@HiveType(typeId: 2)
class Movie {
  @HiveField(0)
  final String streamId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String streamIcon;

  @HiveField(3)
  final String containerExtension;

  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final String? rating;

  @HiveField(6)
  final String? plot;

  @HiveField(7)
  final String? releaseDate;

  @HiveField(8)
  final String? director;

  @HiveField(9)
  final String? actors;

  @HiveField(10)
  final String? backdropPath;

  @HiveField(11)
  final String? youtubeTrailer;

  @HiveField(12)
  final String? tmdbId;

  @HiveField(13)
  final String? year;

  Movie({
    required this.streamId,
    required this.name,
    required this.streamIcon,
    required this.containerExtension,
    required this.categoryId,
    this.rating,
    this.plot,
    this.releaseDate,
    this.director,
    this.actors,
    this.backdropPath,
    this.youtubeTrailer,
    this.tmdbId,
    this.year,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      streamId: json['stream_id']?.toString() ?? '',
      name: json['name'] ?? '',
      streamIcon: json['stream_icon'] ?? '',
      containerExtension: json['container_extension'] ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      rating: json['rating'],
      plot: json['plot'],
      releaseDate: json['releasedate'],
      director: json['director'],
      actors: json['cast'],
      backdropPath: json['backdrop_path'],
      youtubeTrailer: json['youtube_trailer'] ?? json['trailer'],
      tmdbId: json['tmdb']?.toString() ?? json['tmdb_id']?.toString(),
      year: json['year']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'stream_id': streamId,
    'name': name,
    'stream_icon': streamIcon,
    'container_extension': containerExtension,
    'category_id': categoryId,
    'rating': rating,
    'plot': plot,
    'releasedate': releaseDate,
    'director': director,
    'cast': actors,
    'backdrop_path': backdropPath,
    'youtube_trailer': youtubeTrailer,
    'tmdb_id': tmdbId,
    'year': year,
  };
}
