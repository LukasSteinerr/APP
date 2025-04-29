import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/content_provider.dart';
import '../services/data_processing_service.dart';
import '../services/image_service.dart';
import '../utils/constants.dart';
import '../widgets/category_list.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/movie_card.dart';
import 'movie_details_screen.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen>
    with AutomaticKeepAliveClientMixin {
  String? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _initialLoadComplete = false;

  @override
  bool get wantKeepAlive => true; // Keep this widget alive when switching tabs

  @override
  void initState() {
    super.initState();
    debugPrint('MOVIES SCREEN: Initializing');

    // Use addPostFrameCallback to ensure the widget is fully built before updating state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Skip if we've already loaded data
      if (_initialLoadComplete) {
        debugPrint('MOVIES SCREEN: Initial load already complete, skipping');
        return;
      }

      debugPrint('MOVIES SCREEN: Post-frame callback executing');
      final provider = Provider.of<ContentProvider>(context, listen: false);

      debugPrint(
        'MOVIES SCREEN: hasPreloadedData = ${provider.hasPreloadedData}',
      );
      debugPrint(
        'MOVIES SCREEN: vodCategories count = ${provider.vodCategories.length}',
      );
      debugPrint('MOVIES SCREEN: movies count = ${provider.movies.length}');

      // Only load categories if we don't have preloaded data
      if (!provider.hasPreloadedData) {
        debugPrint('MOVIES SCREEN: No preloaded data, loading categories');
        _loadCategories().then((_) {
          setState(() {
            _initialLoadComplete = true;
          });
        });
      } else if (provider.vodCategories.isNotEmpty) {
        // If we have preloaded data, just set the selected category
        debugPrint(
          'MOVIES SCREEN: Using preloaded data, setting selected category',
        );
        setState(() {
          _selectedCategoryId = provider.vodCategories.first.categoryId;
          _initialLoadComplete = true;
        });
        debugPrint('MOVIES SCREEN: Selected category ID: $_selectedCategoryId');
      } else {
        debugPrint(
          'MOVIES SCREEN: No categories available, even with preloaded data',
        );
        setState(() {
          _initialLoadComplete = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    debugPrint('MOVIES SCREEN: Loading VOD categories');
    final provider = Provider.of<ContentProvider>(context, listen: false);
    await provider.loadVodCategories();
    debugPrint(
      'MOVIES SCREEN: Loaded ${provider.vodCategories.length} VOD categories',
    );

    if (provider.vodCategories.isNotEmpty) {
      debugPrint('MOVIES SCREEN: Categories loaded, now loading movies');
      await _loadMovies();
    } else {
      debugPrint('MOVIES SCREEN: No VOD categories available');
    }
  }

  Future<void> _loadMovies() async {
    debugPrint('MOVIES SCREEN: Loading movies');
    final provider = Provider.of<ContentProvider>(context, listen: false);

    if (_selectedCategoryId != null) {
      debugPrint(
        'MOVIES SCREEN: Loading movies for selected category: $_selectedCategoryId',
      );
      await provider.loadMoviesByCategory(_selectedCategoryId!);
    } else if (provider.vodCategories.isNotEmpty) {
      // Load movies from the first category if none is selected
      final firstCategoryId = provider.vodCategories.first.categoryId;
      debugPrint(
        'MOVIES SCREEN: Loading movies for first category: $firstCategoryId',
      );
      await provider.loadMoviesByCategory(firstCategoryId);
    } else {
      debugPrint('MOVIES SCREEN: Cannot load movies - no categories available');
    }

    debugPrint('MOVIES SCREEN: Loaded ${provider.movies.length} movies');
  }

  void _onCategorySelected(String categoryId) {
    debugPrint('MOVIES SCREEN: Category selected: $categoryId');
    setState(() {
      _selectedCategoryId = categoryId.isEmpty ? null : categoryId;
    });
    _loadMovies();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Future<List<Movie>> _getFilteredMovies(List<Movie> movies) async {
    // Use isolate for filtering movies
    return await DataProcessingService.filterMovies(movies, _searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    super.build(
      context,
    ); // Must call super.build for AutomaticKeepAliveClientMixin
    return Consumer<ContentProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingIndicator(message: AppStrings.loading);
        }

        if (provider.error != null) {
          return ErrorDisplay(
            errorMessage: provider.error!,
            onRetry: _loadCategories,
          );
        }

        final categories = provider.vodCategories;

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(AppPaddings.medium),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.search,
                  prefixIcon: const Icon(AppIcons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  ),
                  filled: true,
                  fillColor: AppColors.card,
                ),
                style: AppTextStyles.body1,
                onChanged: _onSearchChanged,
              ),
            ),

            // Categories
            if (categories.isNotEmpty)
              CategoryList(
                categories: categories,
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: _onCategorySelected,
                showAllOption: false,
              ),

            // Movies with FutureBuilder
            Expanded(
              child: FutureBuilder<List<Movie>>(
                future: _getFilteredMovies(provider.movies),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: AppTextStyles.body1,
                      ),
                    );
                  }

                  final movies = snapshot.data ?? [];

                  if (movies.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.noResults,
                        style: AppTextStyles.body1,
                      ),
                    );
                  }

                  // Prefetch movie posters in the background
                  _prefetchMoviePosters(movies);

                  return GridView.builder(
                    padding: const EdgeInsets.all(AppPaddings.medium),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2 / 3,
                          crossAxisSpacing: AppPaddings.small,
                          mainAxisSpacing: AppPaddings.small,
                        ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return MovieCard(
                        movie: movie,
                        onTap:
                            () => _openMovieDetails(context, movie, provider),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _openMovieDetails(
    BuildContext context,
    Movie movie,
    ContentProvider provider,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MovieDetailsScreen(movie: movie)),
    );
  }

  // Prefetch movie posters in the background using isolates
  void _prefetchMoviePosters(List<Movie> movies) {
    // Extract poster URLs
    final posterUrls =
        movies
            .where((movie) => movie.streamIcon.isNotEmpty)
            .map((movie) => movie.streamIcon)
            .toList();

    // Add TMDB poster URLs if available
    for (final movie in movies) {
      if (movie.tmdbId != null &&
          movie.tmdbId!.isNotEmpty &&
          movie.tmdbId != '0') {
        // We don't have direct access to the TMDB poster URL here,
        // but we can prefetch them in the MovieCard widget
      }
    }

    // Prefetch in background
    if (posterUrls.isNotEmpty) {
      ImageService.prefetchImages(posterUrls);
    }
  }
}
