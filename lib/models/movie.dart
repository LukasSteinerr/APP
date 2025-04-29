import 'package:objectbox/objectbox.dart';

@Entity()
class Movie {
  @Id()
  int id = 0;

  String streamId;
  String name;
  String streamIcon;
  String containerExtension;
  String categoryId;
  String? rating;
  String? plot;
  String? releaseDate;
  String? director;
  String? actors;
  String? backdropPath;
  String? youtubeTrailer;
  String? tmdbId;
  String? year;

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
