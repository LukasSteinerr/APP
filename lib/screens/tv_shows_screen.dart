import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/series.dart';
import '../providers/content_provider.dart';
import '../services/objectbox_service.dart';
import '../utils/constants.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/content_carousel.dart';
import 'series_details_screen.dart';

class TVShowsScreen extends StatefulWidget {
  const TVShowsScreen({super.key});

  @override
  State<TVShowsScreen> createState() => _TVShowsScreenState();
}

class _TVShowsScreenState extends State<TVShowsScreen>
    with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _initialLoadComplete = false;
  Map<String, List<Series>> _seriesByCategory = {};

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

      // Load all series for all categories
      _loadAllSeries().then((_) {
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

  Future<void> _loadAllSeries() async {
    debugPrint('TV SHOWS SCREEN: Loading all series for all categories');
    final provider = Provider.of<ContentProvider>(context, listen: false);

    // If we have preloaded data, use it
    if (provider.hasPreloadedData) {
      _organizeSeriesByCategory();
      return;
    }

    // Otherwise, load categories and then series
    await provider.loadSeriesCategories();

    if (provider.seriesCategories.isEmpty) {
      debugPrint('TV SHOWS SCREEN: No series categories available');
      return;
    }

    // Load all series from the database
    _organizeSeriesByCategory();
  }

  void _organizeSeriesByCategory() {
    // Get all series from the database
    final allSeries = ObjectBoxService.getSeries().cast<Series>();

    // Group series by category
    _seriesByCategory = {};
    for (final series in allSeries) {
      if (!_seriesByCategory.containsKey(series.categoryId)) {
        _seriesByCategory[series.categoryId] = [];
      }
      _seriesByCategory[series.categoryId]!.add(series);
    }

    debugPrint(
      'TV SHOWS SCREEN: Organized series into ${_seriesByCategory.length} categories',
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Series> _getFilteredSeries(List<Series> seriesList) {
    if (_searchQuery.isEmpty) return seriesList;

    return seriesList
        .where(
          (series) =>
              series.name.toLowerCase().contains(_searchQuery) ||
              (series.plot.toLowerCase().contains(_searchQuery)) ||
              (series.cast.toLowerCase().contains(_searchQuery)),
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
            onRetry: _loadAllSeries,
          );
        }

        final categories = provider.seriesCategories;

        if (!_initialLoadComplete) {
          return const LoadingIndicator(message: "Loading TV shows...");
        }

        // If search query is not empty, show filtered results
        if (_searchQuery.isNotEmpty) {
          // Flatten all series from all categories
          final allSeries =
              _seriesByCategory.values.expand((series) => series).toList();
          final filteredSeries = _getFilteredSeries(allSeries);

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
                    filteredSeries.isEmpty
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
                          itemCount: filteredSeries.length,
                          itemBuilder: (context, index) {
                            final series = filteredSeries[index];
                            return GestureDetector(
                              onTap: () => _openSeriesDetails(context, series),
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child:
                                          series.cover.isNotEmpty
                                              ? Image.network(
                                                series.cover,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Center(
                                                      child: Icon(
                                                        AppIcons.tvShows,
                                                        size: 40,
                                                        color:
                                                            AppColors.primary,
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
                                      padding: const EdgeInsets.all(
                                        AppPaddings.small,
                                      ),
                                      child: Text(
                                        series.name,
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
                  _seriesByCategory.isEmpty
                      ? const Center(child: Text('No TV shows available'))
                      : ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final seriesList =
                              _seriesByCategory[category.categoryId] ?? [];

                          if (seriesList.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return ContentCarousel(
                            title: category.categoryName,
                            items: seriesList,
                            onItemTap:
                                (series) => _openSeriesDetails(
                                  context,
                                  series as Series,
                                ),
                            contentType: ContentType.series,
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
}
