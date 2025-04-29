import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/channel.dart';
import '../providers/content_provider.dart';
import '../services/data_processing_service.dart';
import '../services/image_service.dart';
import '../services/network_service.dart';
import '../utils/constants.dart';
import '../widgets/category_list.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/simple_placeholder.dart';
import 'player_screen.dart';

class LiveTVScreen extends StatefulWidget {
  const LiveTVScreen({super.key});

  @override
  State<LiveTVScreen> createState() => _LiveTVScreenState();
}

class _LiveTVScreenState extends State<LiveTVScreen>
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
    debugPrint('LIVE TV SCREEN: Initializing');

    // Optimize image cache settings
    ImageService.optimizeCacheSettings();

    // Use addPostFrameCallback to ensure the widget is fully built before updating state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Skip if we've already loaded data
      if (_initialLoadComplete) {
        debugPrint('LIVE TV SCREEN: Initial load already complete, skipping');
        return;
      }

      debugPrint('LIVE TV SCREEN: Post-frame callback executing');
      final provider = Provider.of<ContentProvider>(context, listen: false);

      debugPrint(
        'LIVE TV SCREEN: hasPreloadedData = ${provider.hasPreloadedData}',
      );
      debugPrint(
        'LIVE TV SCREEN: liveCategories count = ${provider.liveCategories.length}',
      );
      debugPrint(
        'LIVE TV SCREEN: liveChannels count = ${provider.liveChannels.length}',
      );

      // Only load categories if we don't have preloaded data
      if (!provider.hasPreloadedData) {
        debugPrint('LIVE TV SCREEN: No preloaded data, loading categories');
        _loadCategories().then((_) {
          setState(() {
            _initialLoadComplete = true;
          });
        });
      } else if (provider.liveCategories.isNotEmpty) {
        // If we have preloaded data, load channels
        debugPrint('LIVE TV SCREEN: Using preloaded data, loading channels');
        _loadChannels().then((_) {
          setState(() {
            _initialLoadComplete = true;
          });
        });
      } else {
        debugPrint(
          'LIVE TV SCREEN: No categories available, even with preloaded data',
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
    debugPrint('LIVE TV SCREEN: Loading live categories');
    final provider = Provider.of<ContentProvider>(context, listen: false);
    await provider.loadLiveCategories();
    debugPrint(
      'LIVE TV SCREEN: Loaded ${provider.liveCategories.length} live categories',
    );

    if (provider.liveCategories.isNotEmpty) {
      debugPrint('LIVE TV SCREEN: Categories loaded, now loading channels');
      await _loadChannels();
    } else {
      debugPrint('LIVE TV SCREEN: No live categories available');
    }
  }

  Future<void> _loadChannels() async {
    debugPrint('LIVE TV SCREEN: Loading channels');
    final provider = Provider.of<ContentProvider>(context, listen: false);

    if (_selectedCategoryId != null) {
      debugPrint(
        'LIVE TV SCREEN: Loading channels for selected category: $_selectedCategoryId',
      );
      await provider.loadLiveChannelsByCategory(_selectedCategoryId!);
    } else {
      debugPrint('LIVE TV SCREEN: Loading all live channels');
      await provider.loadAllLiveChannels();
    }

    debugPrint(
      'LIVE TV SCREEN: Loaded ${provider.liveChannels.length} channels',
    );
  }

  void _onCategorySelected(String categoryId) {
    debugPrint('LIVE TV SCREEN: Category selected: $categoryId');
    setState(() {
      _selectedCategoryId = categoryId.isEmpty ? null : categoryId;
    });
    _loadChannels();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Future<List<Channel>> _getFilteredChannels(List<Channel> channels) async {
    // Use isolate for filtering channels
    return await DataProcessingService.filterChannels(channels, _searchQuery);
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

        final categories = provider.liveCategories;

        // Use FutureBuilder to handle the async filtering
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
              ),

            // Channels with FutureBuilder
            Expanded(
              child: FutureBuilder<List<Channel>>(
                future: _getFilteredChannels(provider.liveChannels),
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

                  final channels = snapshot.data ?? [];

                  if (channels.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.noResults,
                        style: AppTextStyles.body1,
                      ),
                    );
                  }

                  // Prefetch channel icons in the background
                  _prefetchChannelIcons(channels);

                  return GridView.builder(
                    padding: const EdgeInsets.all(AppPaddings.medium),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 16 / 9,
                          crossAxisSpacing: AppPaddings.medium,
                          mainAxisSpacing: AppPaddings.medium,
                        ),
                    // Use caching for better performance
                    cacheExtent: 500, // Cache more items for smoother scrolling
                    addAutomaticKeepAlives: true,
                    itemCount: channels.length,
                    itemBuilder: (context, index) {
                      // Only build channel cards that are visible or about to be visible
                      final channel = channels[index];
                      return _buildChannelCard(context, channel, provider);
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

  Widget _buildChannelCard(
    BuildContext context,
    Channel channel,
    ContentProvider provider,
  ) {
    // Use RepaintBoundary to isolate repainting
    return RepaintBoundary(
      child: Card(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        ),
        clipBehavior: Clip.antiAlias,
        elevation: 2, // Reduced elevation for better performance
        child: InkWell(
          onTap: () => _openChannel(context, channel, provider),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child:
                    channel.streamIcon.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: channel.streamIcon,
                          fit: BoxFit.cover,
                          // Improved caching settings
                          memCacheWidth: 200, // Limit memory cache size
                          memCacheHeight: 120,
                          fadeInDuration: const Duration(milliseconds: 200),
                          placeholder:
                              (context, url) =>
                                  const Center(child: SimplePlaceholder()),
                          errorWidget:
                              (context, url, error) => const Center(
                                child: Icon(
                                  AppIcons.live,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                              ),
                        )
                        : const Center(
                          child: Icon(
                            AppIcons.live,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
              ),
              Container(
                padding: const EdgeInsets.all(AppPaddings.small),
                color: AppColors.card,
                child: Text(
                  channel.name,
                  style: AppTextStyles.body1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openChannel(
    BuildContext context,
    Channel channel,
    ContentProvider provider,
  ) async {
    try {
      // Check if we have internet connection before trying to play
      final hasInternet = await NetworkService.hasInternetConnection();
      if (!hasInternet) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No internet connection. Cannot play channel.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final streamUrl = provider.getLiveStreamUrl(channel.streamId);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    PlayerScreen(title: channel.name, streamUrl: streamUrl),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Prefetch channel icons in the background using isolates
  void _prefetchChannelIcons(List<Channel> channels) {
    // Only prefetch a limited number of images to avoid memory issues
    final visibleChannels = channels.take(20).toList();

    // Extract icon URLs
    final iconUrls =
        visibleChannels
            .where((channel) => channel.streamIcon.isNotEmpty)
            .map((channel) => channel.streamIcon)
            .toList();

    // Prefetch in background
    if (iconUrls.isNotEmpty) {
      // Use a microtask to avoid blocking the UI
      Future.microtask(() {
        ImageService.prefetchImages(iconUrls);
      });
    }
  }
}
