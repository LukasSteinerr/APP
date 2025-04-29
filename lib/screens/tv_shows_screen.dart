import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/series.dart';
import '../providers/content_provider.dart';
import '../services/data_processing_service.dart';
import '../services/image_service.dart';
import '../utils/constants.dart';
import '../widgets/category_list.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/series_card.dart';
import 'series_details_screen.dart';

class TVShowsScreen extends StatefulWidget {
  const TVShowsScreen({super.key});

  @override
  State<TVShowsScreen> createState() => _TVShowsScreenState();
}

class _TVShowsScreenState extends State<TVShowsScreen>
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
    debugPrint('TV SHOWS SCREEN: Initializing');

    // Use addPostFrameCallback to ensure the widget is fully built before updating state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Skip if we've already loaded data
      if (_initialLoadComplete) {
        debugPrint('TV SHOWS SCREEN: Initial load already complete, skipping');
        return;
      }

      debugPrint('TV SHOWS SCREEN: Post-frame callback executing');
      final provider = Provider.of<ContentProvider>(context, listen: false);

      debugPrint(
        'TV SHOWS SCREEN: hasPreloadedData = ${provider.hasPreloadedData}',
      );
      debugPrint(
        'TV SHOWS SCREEN: seriesCategories count = ${provider.seriesCategories.length}',
      );
      debugPrint(
        'TV SHOWS SCREEN: seriesList count = ${provider.seriesList.length}',
      );

      // Only load categories if we don't have preloaded data
      if (!provider.hasPreloadedData) {
        debugPrint('TV SHOWS SCREEN: No preloaded data, loading categories');
        _loadCategories().then((_) {
          setState(() {
            _initialLoadComplete = true;
          });
        });
      } else if (provider.seriesCategories.isNotEmpty) {
        // If we have preloaded data, just set the selected category
        debugPrint(
          'TV SHOWS SCREEN: Using preloaded data, setting selected category',
        );
        setState(() {
          _selectedCategoryId = provider.seriesCategories.first.categoryId;
          _initialLoadComplete = true;
        });
        debugPrint(
          'TV SHOWS SCREEN: Selected category ID: $_selectedCategoryId',
        );
      } else {
        debugPrint(
          'TV SHOWS SCREEN: No categories available, even with preloaded data',
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
    debugPrint('TV SHOWS SCREEN: Loading series categories');
    final provider = Provider.of<ContentProvider>(context, listen: false);
    await provider.loadSeriesCategories();
    debugPrint(
      'TV SHOWS SCREEN: Loaded ${provider.seriesCategories.length} series categories',
    );

    if (provider.seriesCategories.isNotEmpty) {
      debugPrint('TV SHOWS SCREEN: Categories loaded, now loading series');
      await _loadSeries();
    } else {
      debugPrint('TV SHOWS SCREEN: No series categories available');
    }
  }

  Future<void> _loadSeries() async {
    debugPrint('TV SHOWS SCREEN: Loading series');
    final provider = Provider.of<ContentProvider>(context, listen: false);

    if (_selectedCategoryId != null) {
      debugPrint(
        'TV SHOWS SCREEN: Loading series for selected category: $_selectedCategoryId',
      );
      await provider.loadSeriesByCategory(_selectedCategoryId!);
    } else if (provider.seriesCategories.isNotEmpty) {
      // Load series from the first category if none is selected
      final firstCategoryId = provider.seriesCategories.first.categoryId;
      debugPrint(
        'TV SHOWS SCREEN: Loading series for first category: $firstCategoryId',
      );
      await provider.loadSeriesByCategory(firstCategoryId);
    } else {
      debugPrint(
        'TV SHOWS SCREEN: Cannot load series - no categories available',
      );
    }

    debugPrint('TV SHOWS SCREEN: Loaded ${provider.seriesList.length} series');
  }

  void _onCategorySelected(String categoryId) {
    debugPrint('TV SHOWS SCREEN: Category selected: $categoryId');
    setState(() {
      _selectedCategoryId = categoryId.isEmpty ? null : categoryId;
    });
    _loadSeries();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Future<List<Series>> _getFilteredSeries(List<Series> seriesList) async {
    // Use isolate for filtering series
    return await DataProcessingService.filterSeries(seriesList, _searchQuery);
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

        final categories = provider.seriesCategories;

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

            // Series with FutureBuilder
            Expanded(
              child: FutureBuilder<List<Series>>(
                future: _getFilteredSeries(provider.seriesList),
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

                  final seriesList = snapshot.data ?? [];

                  if (seriesList.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.noResults,
                        style: AppTextStyles.body1,
                      ),
                    );
                  }

                  // Prefetch series posters in the background
                  _prefetchSeriesPosters(seriesList);

                  return GridView.builder(
                    padding: const EdgeInsets.all(AppPaddings.medium),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2 / 3,
                          crossAxisSpacing: AppPaddings.small,
                          mainAxisSpacing: AppPaddings.small,
                        ),
                    itemCount: seriesList.length,
                    itemBuilder: (context, index) {
                      final series = seriesList[index];
                      return SeriesCard(
                        series: series,
                        onTap: () => _openSeriesDetails(context, series),
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

  void _openSeriesDetails(BuildContext context, Series series) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeriesDetailsScreen(series: series),
      ),
    );
  }

  // Prefetch series posters in the background using isolates
  void _prefetchSeriesPosters(List<Series> seriesList) {
    // Extract poster URLs
    final posterUrls =
        seriesList
            .where((series) => series.cover.isNotEmpty)
            .map((series) => series.cover)
            .toList();

    // Prefetch in background
    if (posterUrls.isNotEmpty) {
      ImageService.prefetchImages(posterUrls);
    }
  }
}
