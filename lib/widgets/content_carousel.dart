import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/series.dart';
import '../models/channel.dart';
import '../utils/constants.dart';
import 'movie_card.dart';
import 'series_card.dart';
import '../providers/content_provider.dart';

class ContentCarousel extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final Function(dynamic) onItemTap;
  final ContentType contentType;
  final int itemCount;

  const ContentCarousel({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
    required this.contentType,
    this.itemCount = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink(); // Don't show empty carousels
    }

    // Limit the number of items to display
    final displayItems =
        items.length > itemCount ? items.sublist(0, itemCount) : items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppPaddings.medium,
            AppPaddings.medium,
            AppPaddings.medium,
            AppPaddings.small,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.headline2),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to see all items in this category
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: contentType == ContentType.liveTV ? 120 : 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayItems.length,
            padding: const EdgeInsets.symmetric(horizontal: AppPaddings.medium),
            itemBuilder: (context, index) {
              final item = displayItems[index];
              return Padding(
                padding: const EdgeInsets.only(right: AppPaddings.small),
                child: _buildItem(item, context),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItem(dynamic item, BuildContext context) {
    switch (contentType) {
      case ContentType.movie:
        final movie = item as Movie;
        return SizedBox(
          width: 120,
          child: MovieCard(movie: movie, onTap: () => onItemTap(movie)),
        );
      case ContentType.series:
        final series = item as Series;
        return SizedBox(
          width: 120,
          child: SeriesCard(series: series, onTap: () => onItemTap(series)),
        );
      case ContentType.liveTV:
        final channel = item as Channel;
        return SizedBox(width: 180, child: _buildChannelCard(channel, context));
    }
  }

  Widget _buildChannelCard(Channel channel, BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () => onItemTap(channel),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child:
                  channel.streamIcon.isNotEmpty
                      ? Image.network(
                        channel.streamIcon,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Center(
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
            Padding(
              padding: const EdgeInsets.all(AppPaddings.small),
              child: Text(
                channel.name,
                style: AppTextStyles.body2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ContentType { movie, series, liveTV }
