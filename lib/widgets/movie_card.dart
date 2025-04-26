import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../utils/constants.dart';
import '../widgets/simple_placeholder.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({super.key, required this.movie, required this.onTap});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  String? _posterUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the widget is fully built before updating state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPoster();
    });
  }

  Future<void> _loadPoster() async {
    // Start with the stream icon as fallback
    String posterUrl = widget.movie.streamIcon;

    try {
      // If we have a TMDB ID, try to get the poster from TMDB
      if (widget.movie.tmdbId != null &&
          widget.movie.tmdbId!.isNotEmpty &&
          widget.movie.tmdbId != '0') {
        // Get movie details from TMDB
        final movieDetails = await TMDBService.getMovieById(
          widget.movie.tmdbId!,
        );

        // If we have a poster path, use it
        if (movieDetails != null && movieDetails['poster_path'] != null) {
          posterUrl = TMDBService.getPosterUrl(movieDetails['poster_path']);
        }
      }
    } catch (e) {
      // If there's an error, just use the stream icon
      debugPrint('Error loading poster: $e');
    }

    // Only update state if the widget is still mounted
    if (mounted) {
      setState(() {
        _posterUrl = posterUrl;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: SimplePlaceholder())
                      : _posterUrl != null && _posterUrl!.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: _posterUrl!,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) =>
                                const Center(child: SimplePlaceholder()),
                        errorWidget:
                            (context, url, error) => const Center(
                              child: Icon(
                                AppIcons.movies,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                      )
                      : const Center(
                        child: Icon(
                          AppIcons.movies,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppPaddings.small),
              child: Text(
                widget.movie.name,
                style: AppTextStyles.body2,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
