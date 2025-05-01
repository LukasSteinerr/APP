import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/channel.dart';
import '../providers/content_provider.dart';
import '../services/network_service.dart';
import '../services/objectbox_service.dart';
import '../utils/constants.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/content_carousel.dart';
import 'player_screen.dart';

class LiveTVScreen extends StatefulWidget {
  const LiveTVScreen({super.key});

  @override
  State<LiveTVScreen> createState() => _LiveTVScreenState();
}

class _LiveTVScreenState extends State<LiveTVScreen>
    with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _initialLoadComplete = false;
  Map<String, List<Channel>> _channelsByCategory = {};

  @override
  bool get wantKeepAlive => true; // Keep this widget alive when switching tabs

  @override
  void initState() {
    super.initState();
    debugPrint('LIVE TV SCREEN: Initializing');

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

      // Load all channels for all categories
      _loadAllChannels().then((_) {
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

  Future<void> _loadAllChannels() async {
    debugPrint('LIVE TV SCREEN: Loading all channels for all categories');
    final provider = Provider.of<ContentProvider>(context, listen: false);

    // If we have preloaded data, use it
    if (provider.hasPreloadedData) {
      _organizeChannelsByCategory();
      return;
    }

    // Otherwise, load categories and then channels
    await provider.loadLiveCategories();

    if (provider.liveCategories.isEmpty) {
      debugPrint('LIVE TV SCREEN: No live categories available');
      return;
    }

    // Load all channels from the database
    _organizeChannelsByCategory();
  }

  void _organizeChannelsByCategory() {
    // Get all channels from the database
    final allChannels = ObjectBoxService.getChannels().cast<Channel>();

    // Group channels by category
    _channelsByCategory = {};
    for (final channel in allChannels) {
      if (!_channelsByCategory.containsKey(channel.categoryId)) {
        _channelsByCategory[channel.categoryId] = [];
      }
      _channelsByCategory[channel.categoryId]!.add(channel);
    }

    debugPrint(
      'LIVE TV SCREEN: Organized channels into ${_channelsByCategory.length} categories',
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Channel> _getFilteredChannels(List<Channel> channels) {
    if (_searchQuery.isEmpty) return channels;

    return channels
        .where((channel) => channel.name.toLowerCase().contains(_searchQuery))
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
            onRetry: _loadAllChannels,
          );
        }

        final categories = provider.liveCategories;

        if (!_initialLoadComplete) {
          return const LoadingIndicator(message: "Loading channels...");
        }

        // If search query is not empty, show filtered results
        if (_searchQuery.isNotEmpty) {
          // Flatten all channels from all categories
          final allChannels =
              _channelsByCategory.values
                  .expand((channels) => channels)
                  .toList();
          final filteredChannels = _getFilteredChannels(allChannels);

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
                    filteredChannels.isEmpty
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
                                crossAxisCount: 2,
                                childAspectRatio: 16 / 9,
                                crossAxisSpacing: AppPaddings.medium,
                                mainAxisSpacing: AppPaddings.medium,
                              ),
                          itemCount: filteredChannels.length,
                          itemBuilder: (context, index) {
                            final channel = filteredChannels[index];
                            return _buildChannelCard(
                              context,
                              channel,
                              provider,
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
                  _channelsByCategory.isEmpty
                      ? const Center(child: Text('No channels available'))
                      : ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final channels =
                              _channelsByCategory[category.categoryId] ?? [];

                          if (channels.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return ContentCarousel(
                            title: category.categoryName,
                            items: channels,
                            onItemTap:
                                (channel) => _openChannel(
                                  context,
                                  channel as Channel,
                                  provider,
                                ),
                            contentType: ContentType.liveTV,
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
                              (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
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
}
