import 'package:flutter/material.dart';
import '../models/series.dart';
import '../services/tmdb_service.dart';
import '../utils/constants.dart';
import '../widgets/simple_placeholder.dart';

class SeriesCard extends StatefulWidget {
  final Series series;
  final VoidCallback onTap;

  const SeriesCard({super.key, required this.series, required this.onTap});

  @override
  State<SeriesCard> createState() => _SeriesCardState();
}

class _SeriesCardState extends State<SeriesCard> {
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
    // Start with the cover as fallback
    String posterUrl = widget.series.cover;

    try {
      // If we have a TMDB ID, try to get the poster from TMDB
      if (widget.series.tmdbId != null &&
          widget.series.tmdbId!.isNotEmpty &&
          widget.series.tmdbId != '0') {
        // Get series details from TMDB
        final seriesDetails = await TMDBService.getTVShowById(
          widget.series.tmdbId!,
        );

        // If we have a poster path, use it
        if (seriesDetails != null && seriesDetails['poster_path'] != null) {
          posterUrl = TMDBService.getPosterUrl(seriesDetails['poster_path']);
        }
      }
    } catch (e) {
      // If there's an error, just use the cover
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
                      ? Image.network(
                        _posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const Center(
                              child: Icon(
                                AppIcons.tvShows,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                      )
                      : const Center(
                        child: Icon(
                          AppIcons.tvShows,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppPaddings.small),
              child: Text(
                widget.series.name,
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
