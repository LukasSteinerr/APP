import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/series.dart';
import '../providers/content_provider.dart';
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

class _TVShowsScreenState extends State<TVShowsScreen> {
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
    await provider.loadSeriesCategories();

    if (provider.seriesCategories.isNotEmpty) {
      await _loadSeries();
    }
  }

  Future<void> _loadSeries() async {
    final provider = Provider.of<ContentProvider>(context, listen: false);

    if (_selectedCategoryId != null) {
      await provider.loadSeriesByCategory(_selectedCategoryId!);
    } else if (provider.seriesCategories.isNotEmpty) {
      // Load series from the first category if none is selected
      await provider.loadSeriesByCategory(
        provider.seriesCategories.first.categoryId,
      );
    }
  }

  void _onCategorySelected(String categoryId) {
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

  List<Series> _getFilteredSeries(List<Series> seriesList) {
    if (_searchQuery.isEmpty) {
      return seriesList;
    }

    return seriesList.where((series) {
      return series.name.toLowerCase().contains(_searchQuery);
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

        final categories = provider.seriesCategories;
        final seriesList = _getFilteredSeries(provider.seriesList);

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

            // Series
            Expanded(
              child:
                  seriesList.isEmpty
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
                        itemCount: seriesList.length,
                        itemBuilder: (context, index) {
                          final series = seriesList[index];
                          return SeriesCard(
                            series: series,
                            onTap: () => _openSeriesDetails(context, series),
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
