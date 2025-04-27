import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/compute_service.dart';
import '../services/image_service.dart';
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

// Parameter class for poster loading in isolate
class _PosterLoadParams {
  final String streamIcon;
  final String? tmdbId;

  _PosterLoadParams({required this.streamIcon, required this.tmdbId});
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
    try {
      // Use isolate to load the poster
      final posterUrl = await ComputeService.compute<_PosterLoadParams, String>(
        _loadPosterInIsolate,
        _PosterLoadParams(
          streamIcon: widget.movie.streamIcon,
          tmdbId: widget.movie.tmdbId,
        ),
      );

      // Prefetch the image in the background
      if (posterUrl.isNotEmpty) {
        ImageService.prefetchImage(posterUrl);
      }

      // Only update state if the widget is still mounted
      if (mounted) {
        setState(() {
          _posterUrl = posterUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If there's an error, just use the stream icon
      debugPrint('Error loading poster: $e');

      // Only update state if the widget is still mounted
      if (mounted) {
        setState(() {
          _posterUrl = widget.movie.streamIcon;
          _isLoading = false;
        });
      }
    }
  }

  // Static method to load poster in isolate
  static Future<String> _loadPosterInIsolate(_PosterLoadParams params) async {
    // Start with the stream icon as fallback
    String posterUrl = params.streamIcon;

    try {
      // If we have a TMDB ID, try to get the poster from TMDB
      if (params.tmdbId != null &&
          params.tmdbId!.isNotEmpty &&
          params.tmdbId != '0') {
        // Get movie details from TMDB
        final movieDetails = await TMDBService.getMovieById(params.tmdbId!);

        // If we have a poster path, use it
        if (movieDetails != null && movieDetails['poster_path'] != null) {
          posterUrl = TMDBService.getPosterUrl(movieDetails['poster_path']);
        }
      }
    } catch (e) {
      // If there's an error, just use the stream icon
      debugPrint('Error loading poster in isolate: $e');
    }

    return posterUrl;
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
