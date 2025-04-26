class Movie {
  final String streamId;
  final String name;
  final String streamIcon;
  final String containerExtension;
  final String categoryId;
  final String? rating;
  final String? plot;
  final String? releaseDate;
  final String? director;
  final String? actors;
  final String? backdropPath;
  final String? youtubeTrailer;
  final String? tmdbId;
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
}
