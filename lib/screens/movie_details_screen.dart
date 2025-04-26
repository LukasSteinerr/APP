import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/content_provider.dart';
import '../services/tmdb_service.dart';
import '../utils/constants.dart';
import '../widgets/simple_placeholder.dart';
import 'player_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _tmdbDetails;
  String? _posterUrl;
  String? _backdropUrl;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the widget is fully built before updating state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTMDBDetails();
    });
  }

  Future<void> _loadTMDBDetails() async {
    try {
      // Try to get TMDB details
      if (widget.movie.tmdbId != null &&
          widget.movie.tmdbId!.isNotEmpty &&
          widget.movie.tmdbId != '0') {
        // Use TMDB ID if available
        _tmdbDetails = await TMDBService.getMovieById(widget.movie.tmdbId!);
      } else {
        // Fall back to search by title and year
        final title = widget.movie.name;
        final year = widget.movie.year;
        final searchResult = await TMDBService.searchMovie(title, year: year);

        if (searchResult != null) {
          // Get full details using the ID from search result
          _tmdbDetails = await TMDBService.getMovieById(
            searchResult['id'].toString(),
          );
        }
      }

      // Get poster URL (either from TMDB or from stream_icon)
      _posterUrl = widget.movie.streamIcon;
      if (_tmdbDetails != null && _tmdbDetails!['poster_path'] != null) {
        _posterUrl = TMDBService.getPosterUrl(_tmdbDetails!['poster_path']);
      }

      // Get backdrop URL from TMDB
      if (_tmdbDetails != null && _tmdbDetails!['backdrop_path'] != null) {
        _backdropUrl = TMDBService.getBackdropUrl(
          _tmdbDetails!['backdrop_path'],
        );
      } else {
        _backdropUrl = widget.movie.backdropPath;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load movie details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body:
          _isLoading
              ? const Center(child: SimplePlaceholder(width: 100, height: 100))
              : CustomScrollView(
                slivers: [
                  _buildAppBar(context),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        _buildDetails(context),
                        _buildPlayButton(context, contentProvider),
                        if (widget.movie.plot != null &&
                            widget.movie.plot!.isNotEmpty)
                          _buildPlot(context),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background:
            _backdropUrl != null && _backdropUrl!.isNotEmpty
                ? Image.network(
                  _backdropUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: AppColors.primaryDark,
                        child: const Center(
                          child: Icon(
                            AppIcons.movies,
                            size: 80,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                )
                : Container(
                  color: AppColors.primaryDark,
                  child: const Center(
                    child: Icon(
                      AppIcons.movies,
                      size: 80,
                      color: AppColors.text,
                    ),
                  ),
                ),
      ),
      backgroundColor: AppColors.primaryDark,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppPaddings.medium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            child: SizedBox(
              width: 120,
              height: 180,
              child:
                  _posterUrl != null && _posterUrl!.isNotEmpty
                      ? Image.network(
                        _posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: AppColors.card,
                              child: const Center(
                                child: Icon(
                                  AppIcons.movies,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                      )
                      : Container(
                        color: AppColors.card,
                        child: const Center(
                          child: Icon(
                            AppIcons.movies,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
            ),
          ),
          const SizedBox(width: AppPaddings.medium),

          // Movie Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.movie.name, style: AppTextStyles.headline1),
                const SizedBox(height: AppPaddings.small),
                if (widget.movie.releaseDate != null &&
                    widget.movie.releaseDate!.isNotEmpty) ...[
                  Text(
                    'Released: ${widget.movie.releaseDate}',
                    style: AppTextStyles.body2,
                  ),
                  const SizedBox(height: AppPaddings.small),
                ],
                if (widget.movie.rating != null &&
                    widget.movie.rating!.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(widget.movie.rating!, style: AppTextStyles.body1),
                    ],
                  ),
                  const SizedBox(height: AppPaddings.small),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPaddings.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.movie.director != null &&
              widget.movie.director!.isNotEmpty) ...[
            const Text('Director:', style: AppTextStyles.headline3),
            const SizedBox(height: AppPaddings.small),
            Text(widget.movie.director!, style: AppTextStyles.body1),
            const SizedBox(height: AppPaddings.medium),
          ],
          if (widget.movie.actors != null &&
              widget.movie.actors!.isNotEmpty) ...[
            const Text('Cast:', style: AppTextStyles.headline3),
            const SizedBox(height: AppPaddings.small),
            Text(widget.movie.actors!, style: AppTextStyles.body1),
            const SizedBox(height: AppPaddings.medium),
          ],
        ],
      ),
    );
  }

  Widget _buildPlot(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppPaddings.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plot:', style: AppTextStyles.headline3),
          const SizedBox(height: AppPaddings.small),
          Text(widget.movie.plot!, style: AppTextStyles.body1),
        ],
      ),
    );
  }

  Widget _buildPlayButton(
    BuildContext context,
    ContentProvider contentProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppPaddings.medium),
      child: ElevatedButton.icon(
        onPressed: () => _playMovie(context, contentProvider),
        icon: const Icon(AppIcons.play),
        label: const Text('Play Movie'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            vertical: AppPaddings.medium,
            horizontal: AppPaddings.large,
          ),
          minimumSize: const Size(double.infinity, 0),
        ),
      ),
    );
  }

  void _playMovie(BuildContext context, ContentProvider contentProvider) {
    final streamUrl = contentProvider.getVodStreamUrl(widget.movie.streamId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PlayerScreen(
              title: widget.movie.name,
              streamUrl: streamUrl,
              posterUrl: _posterUrl,
            ),
      ),
    );
  }
}
