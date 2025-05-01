import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/content_provider.dart';
import '../services/objectbox_service.dart';
import '../utils/constants.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/content_carousel.dart';
import 'movie_details_screen.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen>
    with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _initialLoadComplete = false;
  Map<String, List<Movie>> _moviesByCategory = {};

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

      // Load all movies for all categories
      _loadAllMovies().then((_) {
        setState(() {
          _initialLoadComplete = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllMovies() async {
    debugPrint('MOVIES SCREEN: Loading all movies for all categories');
    final provider = Provider.of<ContentProvider>(context, listen: false);

    // If we have preloaded data, use it
    if (provider.hasPreloadedData) {
      _organizeMoviesByCategory();
      return;
    }

    // Otherwise, load categories and then movies
    await provider.loadVodCategories();

    if (provider.vodCategories.isEmpty) {
      debugPrint('MOVIES SCREEN: No VOD categories available');
      return;
    }

    // Load all movies from the database
    _organizeMoviesByCategory();
  }

  void _organizeMoviesByCategory() {
    // Get all movies from the database
    final allMovies = ObjectBoxService.getMovies().cast<Movie>();

    // Group movies by category
    _moviesByCategory = {};
    for (final movie in allMovies) {
      if (!_moviesByCategory.containsKey(movie.categoryId)) {
        _moviesByCategory[movie.categoryId] = [];
      }
      _moviesByCategory[movie.categoryId]!.add(movie);
    }

    debugPrint(
      'MOVIES SCREEN: Organized movies into ${_moviesByCategory.length} categories',
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Movie> _getFilteredMovies(List<Movie> movies) {
    if (_searchQuery.isEmpty) return movies;

    return movies
        .where(
          (movie) =>
              movie.name.toLowerCase().contains(_searchQuery) ||
              (movie.plot?.toLowerCase().contains(_searchQuery) ?? false) ||
              (movie.actors?.toLowerCase().contains(_searchQuery) ?? false),
        )
        .toList();
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
            onRetry: _loadAllMovies,
          );
        }

        final categories = provider.vodCategories;

        if (!_initialLoadComplete) {
          return const LoadingIndicator(message: "Loading movies...");
        }

        // If search query is not empty, show filtered results
        if (_searchQuery.isNotEmpty) {
          // Flatten all movies from all categories
          final allMovies =
              _moviesByCategory.values.expand((movies) => movies).toList();
          final filteredMovies = _getFilteredMovies(allMovies);

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
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.medium,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.card,
                  ),
                  style: AppTextStyles.body1,
                  onChanged: _onSearchChanged,
                ),
              ),

              // Search results
              Expanded(
                child:
                    filteredMovies.isEmpty
                        ? Center(
                          child: Text(
                            AppStrings.noResults,
                            style: AppTextStyles.body1,
                          ),
                        )
                        : GridView.builder(
                          padding: const EdgeInsets.all(AppPaddings.medium),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2 / 3,
                                crossAxisSpacing: AppPaddings.small,
                                mainAxisSpacing: AppPaddings.small,
                              ),
                          itemCount: filteredMovies.length,
                          itemBuilder: (context, index) {
                            final movie = filteredMovies[index];
                            return GestureDetector(
                              onTap:
                                  () => _openMovieDetails(
                                    context,
                                    movie,
                                    provider,
                                  ),
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child:
                                          movie.streamIcon.isNotEmpty
                                              ? Image.network(
                                                movie.streamIcon,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Center(
                                                      child: Icon(
                                                        AppIcons.movies,
                                                        size: 40,
                                                        color:
                                                            AppColors.primary,
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
                                      padding: const EdgeInsets.all(
                                        AppPaddings.small,
                                      ),
                                      child: Text(
                                        movie.name,
                                        style: AppTextStyles.body2,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        }

        // Show category carousels
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

            // Category Carousels
            Expanded(
              child:
                  _moviesByCategory.isEmpty
                      ? const Center(child: Text('No movies available'))
                      : ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final movies =
                              _moviesByCategory[category.categoryId] ?? [];

                          if (movies.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return ContentCarousel(
                            title: category.categoryName,
                            items: movies,
                            onItemTap:
                                (movie) => _openMovieDetails(
                                  context,
                                  movie as Movie,
                                  provider,
                                ),
                            contentType: ContentType.movie,
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
}
