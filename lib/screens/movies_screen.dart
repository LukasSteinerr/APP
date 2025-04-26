import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/movie.dart';
import '../providers/content_provider.dart';
import '../services/tmdb_service.dart';
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

class _MoviesScreenState extends State<MoviesScreen> {
  String? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the widget is fully built before updating state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final provider = Provider.of<ContentProvider>(context, listen: false);
    await provider.loadVodCategories();

    if (provider.vodCategories.isNotEmpty) {
      await _loadMovies();
    }
  }

  Future<void> _loadMovies() async {
    final provider = Provider.of<ContentProvider>(context, listen: false);

    if (_selectedCategoryId != null) {
      await provider.loadMoviesByCategory(_selectedCategoryId!);
    } else if (provider.vodCategories.isNotEmpty) {
      // Load movies from the first category if none is selected
      await provider.loadMoviesByCategory(
        provider.vodCategories.first.categoryId,
      );
    }
  }

  void _onCategorySelected(String categoryId) {
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

  List<Movie> _getFilteredMovies(List<Movie> movies) {
    if (_searchQuery.isEmpty) {
      return movies;
    }

    return movies.where((movie) {
      return movie.name.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
        final movies = _getFilteredMovies(provider.movies);

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

            // Movies
            Expanded(
              child:
                  movies.isEmpty
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
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return MovieCard(
                            movie: movie,
                            onTap:
                                () =>
                                    _openMovieDetails(context, movie, provider),
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
