import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/channel.dart';
import '../models/movie.dart';
import '../models/series.dart';
import '../models/category_item.dart';
import '../services/objectbox_service.dart';
import '../utils/constants.dart';

class ObjectBoxDebugScreen extends StatefulWidget {
  const ObjectBoxDebugScreen({super.key});

  @override
  State<ObjectBoxDebugScreen> createState() => _ObjectBoxDebugScreenState();
}

class _ObjectBoxDebugScreenState extends State<ObjectBoxDebugScreen> {
  // Data counts
  int _vodCategoriesCount = 0;
  int _seriesCategoriesCount = 0;
  int _liveCategoriesCount = 0;
  int _moviesCount = 0;
  int _seriesCount = 0;
  int _channelsCount = 0;
  String? _connectionId;
  bool _hasPreloadedData = false;
  String _databasePath = 'Unknown';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Get counts from ObjectBox
    // Since we no longer have Category entities, we'll extract categories from content
    final movies = ObjectBoxService.getMovies().cast<Movie>();
    final series = ObjectBoxService.getSeries().cast<Series>();
    final channels = ObjectBoxService.getChannels().cast<Channel>();
    final connectionId = ObjectBoxService.getConnectionId();
    final hasPreloadedData = ObjectBoxService.hasPreloadedData();
    final databasePath = await ObjectBoxService.getObjectBoxDatabasePath();

    // Extract unique categories from content
    final vodCategoryIds = <String>{};
    for (var movie in movies) {
      vodCategoryIds.add(movie.categoryId);
    }

    final seriesCategoryIds = <String>{};
    for (var s in series) {
      seriesCategoryIds.add(s.categoryId);
    }

    final liveCategoryIds = <String>{};
    for (var channel in channels) {
      liveCategoryIds.add(channel.categoryId);
    }

    setState(() {
      _vodCategoriesCount = vodCategoryIds.length;
      _seriesCategoriesCount = seriesCategoryIds.length;
      _liveCategoriesCount = liveCategoryIds.length;
      _moviesCount = movies.length;
      _seriesCount = series.length;
      _channelsCount = channels.length;
      _connectionId = connectionId;
      _hasPreloadedData = hasPreloadedData;
      _databasePath = databasePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ObjectBox Database Debug'),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(AppPaddings.medium),
          children: [
            _buildStatusCard(),
            const SizedBox(height: AppPaddings.medium),
            _buildDataCountsCard(),
            const SizedBox(height: AppPaddings.medium),
            _buildDataSamplesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Database Status', style: AppTextStyles.headline3),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Preloaded Data Flag:'),
                Text(
                  _hasPreloadedData ? 'TRUE' : 'FALSE',
                  style: TextStyle(
                    color:
                        _hasPreloadedData ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppPaddings.small),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Connection ID:'),
                Text(_connectionId ?? 'None'),
              ],
            ),
            const SizedBox(height: AppPaddings.small),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Database Path:'),
                const SizedBox(height: 4),
                Text(_databasePath, style: AppTextStyles.body2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Path'),
                      onPressed: () {
                        // Copy to clipboard
                        Clipboard.setData(ClipboardData(text: _databasePath));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Database path copied to clipboard'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Clear All Data'),
                      onPressed: () async {
                        // Show confirmation dialog
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Clear All Data'),
                                content: const Text(
                                  'Are you sure you want to clear all ObjectBox data? This action cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                    ),
                                    child: const Text('Clear'),
                                  ),
                                ],
                              ),
                        );

                        if (confirmed == true) {
                          await ObjectBoxService.clearAllData();
                          await _loadData();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'All ObjectBox data cleared successfully',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCountsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data Counts', style: AppTextStyles.headline3),
            const Divider(),
            _buildCountRow('VOD Categories', _vodCategoriesCount),
            _buildCountRow('Series Categories', _seriesCategoriesCount),
            _buildCountRow('Live Categories', _liveCategoriesCount),
            _buildCountRow('Movies', _moviesCount),
            _buildCountRow('Series', _seriesCount),
            _buildCountRow('Channels', _channelsCount),
          ],
        ),
      ),
    );
  }

  Widget _buildCountRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: count > 0 ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSamplesSection() {
    // Get data from ObjectBox
    final movies = ObjectBoxService.getMovies().cast<Movie>();
    final series = ObjectBoxService.getSeries().cast<Series>();
    final channels = ObjectBoxService.getChannels().cast<Channel>();

    // Extract categories from content
    final vodCategories = _extractVodCategories(movies);
    final seriesCategories = _extractSeriesCategories(series);
    final liveCategories = _extractLiveCategories(channels);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data Samples', style: AppTextStyles.headline3),
            const Divider(),
            ExpansionTile(
              title: const Text('VOD Categories'),
              children: [_buildCategoryItemSamples(vodCategories)],
            ),
            ExpansionTile(
              title: const Text('Movies'),
              children: [_buildMovieSamples(movies)],
            ),
            ExpansionTile(
              title: const Text('Series Categories'),
              children: [_buildCategoryItemSamples(seriesCategories)],
            ),
            ExpansionTile(
              title: const Text('Series'),
              children: [_buildSeriesSamples(series)],
            ),
            ExpansionTile(
              title: const Text('Live Categories'),
              children: [_buildCategoryItemSamples(liveCategories)],
            ),
            ExpansionTile(
              title: const Text('Channels'),
              children: [_buildChannelSamples(channels)],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods to extract categories from content
  List<CategoryItem> _extractVodCategories(List<Movie> movies) {
    final categoryMap = <String, String>{};
    for (var movie in movies) {
      categoryMap[movie.categoryId] = movie.categoryName;
    }
    return categoryMap.entries
        .map((e) => CategoryItem(categoryId: e.key, categoryName: e.value))
        .toList();
  }

  List<CategoryItem> _extractSeriesCategories(List<Series> seriesList) {
    final categoryMap = <String, String>{};
    for (var series in seriesList) {
      categoryMap[series.categoryId] = series.categoryName;
    }
    return categoryMap.entries
        .map((e) => CategoryItem(categoryId: e.key, categoryName: e.value))
        .toList();
  }

  List<CategoryItem> _extractLiveCategories(List<Channel> channels) {
    final categoryMap = <String, String>{};
    for (var channel in channels) {
      categoryMap[channel.categoryId] = channel.categoryName;
    }
    return categoryMap.entries
        .map((e) => CategoryItem(categoryId: e.key, categoryName: e.value))
        .toList();
  }

  Widget _buildCategoryItemSamples(List<CategoryItem> categories) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppPaddings.medium),
        child: Text('No data available'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length > 5 ? 5 : categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          title: Text(category.categoryName),
          subtitle: Text('ID: ${category.categoryId}'),
        );
      },
    );
  }

  Widget _buildMovieSamples(List<Movie> movies) {
    if (movies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppPaddings.medium),
        child: Text('No data available'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: movies.length > 5 ? 5 : movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return ListTile(
          leading:
              movie.streamIcon.isNotEmpty
                  ? Image.network(
                    movie.streamIcon,
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) => const Icon(Icons.movie),
                  )
                  : const Icon(Icons.movie),
          title: Text(movie.name),
          subtitle: Text(
            'Category: ${movie.categoryName} (ID: ${movie.categoryId})',
          ),
        );
      },
    );
  }

  Widget _buildSeriesSamples(List<Series> seriesList) {
    if (seriesList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppPaddings.medium),
        child: Text('No data available'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: seriesList.length > 5 ? 5 : seriesList.length,
      itemBuilder: (context, index) {
        final series = seriesList[index];
        return ListTile(
          leading:
              series.cover.isNotEmpty
                  ? Image.network(
                    series.cover,
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) => const Icon(Icons.tv),
                  )
                  : const Icon(Icons.tv),
          title: Text(series.name),
          subtitle: Text(
            'Category: ${series.categoryName} (ID: ${series.categoryId})',
          ),
        );
      },
    );
  }

  Widget _buildChannelSamples(List<Channel> channels) {
    if (channels.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppPaddings.medium),
        child: Text('No data available'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: channels.length > 5 ? 5 : channels.length,
      itemBuilder: (context, index) {
        final channel = channels[index];
        return ListTile(
          leading:
              channel.streamIcon.isNotEmpty
                  ? Image.network(
                    channel.streamIcon,
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) => const Icon(Icons.live_tv),
                  )
                  : const Icon(Icons.live_tv),
          title: Text(channel.name),
          subtitle: Text(
            'Category: ${channel.categoryName} (ID: ${channel.categoryId})',
          ),
        );
      },
    );
  }
}
