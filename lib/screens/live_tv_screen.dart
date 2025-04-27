import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/category.dart';
import '../models/channel.dart';
import '../providers/content_provider.dart';
import '../services/data_processing_service.dart';
import '../services/image_service.dart';
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

class _LiveTVScreenState extends State<LiveTVScreen> {
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
    await provider.loadLiveCategories();

    if (provider.liveCategories.isNotEmpty) {
      await _loadChannels();
    }
  }

  Future<void> _loadChannels() async {
    final provider = Provider.of<ContentProvider>(context, listen: false);

    if (_selectedCategoryId != null) {
      await provider.loadLiveChannelsByCategory(_selectedCategoryId!);
    } else {
      await provider.loadAllLiveChannels();
    }
  }

  void _onCategorySelected(String categoryId) {
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
                    itemCount: channels.length,
                    itemBuilder: (context, index) {
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
    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      clipBehavior: Clip.antiAlias,
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
    );
  }

  void _openChannel(
    BuildContext context,
    Channel channel,
    ContentProvider provider,
  ) {
    final streamUrl = provider.getLiveStreamUrl(channel.streamId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                PlayerScreen(title: channel.name, streamUrl: streamUrl),
      ),
    );
  }

  // Prefetch channel icons in the background using isolates
  void _prefetchChannelIcons(List<Channel> channels) {
    // Extract icon URLs
    final iconUrls =
        channels
            .where((channel) => channel.streamIcon.isNotEmpty)
            .map((channel) => channel.streamIcon)
            .toList();

    // Prefetch in background
    if (iconUrls.isNotEmpty) {
      ImageService.prefetchImages(iconUrls);
    }
  }
}
