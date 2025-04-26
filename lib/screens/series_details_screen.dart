import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/series.dart';
import '../providers/content_provider.dart';
import '../utils/constants.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import 'player_screen.dart';

class SeriesDetailsScreen extends StatefulWidget {
  final Series series;

  const SeriesDetailsScreen({super.key, required this.series});

  @override
  State<SeriesDetailsScreen> createState() => _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends State<SeriesDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  List<Season> _seasons = [];
  Map<String, List<Episode>> _episodes = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the widget is fully built before updating state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSeriesInfo();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSeriesInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final contentProvider = Provider.of<ContentProvider>(
        context,
        listen: false,
      );
      final seriesInfo = await contentProvider.getSeriesInfo(
        widget.series.seriesId,
      );

      // Parse seasons and episodes
      final dynamic seasonsRawData = seriesInfo['seasons'];
      final Map<String, dynamic> seasonsData =
          seasonsRawData is Map<String, dynamic> ? seasonsRawData : {};
      final List<Season> seasons = [];
      final Map<String, List<Episode>> episodes = {};

      // Only process if we have valid seasons data
      if (seasonsData.isNotEmpty) {
        seasonsData.forEach((seasonNumber, seasonData) {
          try {
            // Add season
            seasons.add(
              Season.fromJson({...seasonData, 'season_number': seasonNumber}),
            );

            // Add episodes for this season
            final dynamic episodesRawData = seriesInfo['episodes'];
            Map<String, dynamic> episodesData = {};

            if (episodesRawData is Map) {
              final dynamic seasonEpisodesData = episodesRawData[seasonNumber];
              if (seasonEpisodesData is Map<String, dynamic>) {
                episodesData = seasonEpisodesData;
              }
            }

            final List<Episode> seasonEpisodes = [];

            episodesData.forEach((episodeNumber, episodeData) {
              try {
                // Make sure episodeData is a Map
                final Map<String, dynamic> episodeMap =
                    episodeData is Map<String, dynamic> ? episodeData : {};

                seasonEpisodes.add(
                  Episode.fromJson({...episodeMap, 'season': seasonNumber}),
                );
              } catch (e) {
                // Use debugPrint instead of print
                debugPrint('Error parsing episode $episodeNumber: $e');
              }
            });

            // Sort episodes by episode number
            if (seasonEpisodes.isNotEmpty) {
              seasonEpisodes.sort((a, b) {
                try {
                  return int.parse(
                    a.episodeNum,
                  ).compareTo(int.parse(b.episodeNum));
                } catch (e) {
                  return a.episodeNum.compareTo(b.episodeNum);
                }
              });
              episodes[seasonNumber] = seasonEpisodes;
            }
          } catch (e) {
            // Use debugPrint instead of print
            debugPrint('Error parsing season $seasonNumber: $e');
          }
        });

        // Sort seasons by season number
        if (seasons.isNotEmpty) {
          seasons.sort((a, b) {
            try {
              return int.parse(
                a.seasonNumber,
              ).compareTo(int.parse(b.seasonNumber));
            } catch (e) {
              return a.seasonNumber.compareTo(b.seasonNumber);
            }
          });
        }
      }

      setState(() {
        _seasons = seasons;
        _episodes = episodes;
        _isLoading = false;
        _tabController = TabController(
          length: _seasons.isEmpty ? 1 : _seasons.length,
          vsync: this,
        );
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load series info: $e';
        _isLoading = false;
        _tabController = TabController(length: 1, vsync: this);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body:
          _isLoading
              ? const LoadingIndicator(message: 'Loading series info...')
              : _error != null
              ? ErrorDisplay(errorMessage: _error!, onRetry: _loadSeriesInfo)
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildDetails(),
              _buildSeasonTabs(), // Always show seasons tab (it will handle empty case)
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.series.name),
        background:
            widget.series.cover.isNotEmpty
                ? Image.network(
                  widget.series.cover,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: AppColors.primaryDark,
                        child: const Center(
                          child: Icon(
                            AppIcons.tvShows,
                            size: 80,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                )
                : Container(
                  color: AppColors.primaryDark,
                  child: const Center(
                    child: Icon(
                      AppIcons.tvShows,
                      size: 80,
                      color: AppColors.text,
                    ),
                  ),
                ),
      ),
      backgroundColor: AppColors.primaryDark,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppPaddings.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.series.rating.isNotEmpty) ...[
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(widget.series.rating, style: AppTextStyles.body1),
                const SizedBox(width: AppPaddings.medium),
              ],
              if (widget.series.releaseDate.isNotEmpty)
                Text(
                  'Released: ${widget.series.releaseDate}',
                  style: AppTextStyles.body2,
                ),
            ],
          ),
          if (widget.series.genre.isNotEmpty) ...[
            const SizedBox(height: AppPaddings.small),
            Text('Genre: ${widget.series.genre}', style: AppTextStyles.body2),
          ],
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPaddings.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.series.plot.isNotEmpty) ...[
            const Text('Plot:', style: AppTextStyles.headline3),
            const SizedBox(height: AppPaddings.small),
            Text(widget.series.plot, style: AppTextStyles.body1),
            const SizedBox(height: AppPaddings.medium),
          ],
          if (widget.series.director.isNotEmpty) ...[
            const Text('Director:', style: AppTextStyles.headline3),
            const SizedBox(height: AppPaddings.small),
            Text(widget.series.director, style: AppTextStyles.body1),
            const SizedBox(height: AppPaddings.medium),
          ],
          if (widget.series.cast.isNotEmpty) ...[
            const Text('Cast:', style: AppTextStyles.headline3),
            const SizedBox(height: AppPaddings.small),
            Text(widget.series.cast, style: AppTextStyles.body1),
            const SizedBox(height: AppPaddings.medium),
          ],
        ],
      ),
    );
  }

  Widget _buildSeasonTabs() {
    if (_seasons.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppPaddings.large),
        child: Center(
          child: Text(
            'No seasons available for this series',
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          tabs:
              _seasons.map((season) {
                return Tab(text: 'Season ${season.seasonNumber}');
              }).toList(),
        ),
        SizedBox(
          height: 400, // Fixed height for episodes list
          child: TabBarView(
            controller: _tabController,
            children:
                _seasons.map((season) {
                  final seasonEpisodes = _episodes[season.seasonNumber] ?? [];
                  return _buildEpisodesList(seasonEpisodes);
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodesList(List<Episode> episodes) {
    if (episodes.isEmpty) {
      return const Center(
        child: Text('No episodes available', style: AppTextStyles.body1),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppPaddings.medium),
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        return _buildEpisodeItem(episode);
      },
    );
  }

  Widget _buildEpisodeItem(Episode episode) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppPaddings.small),
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppPaddings.medium),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            episode.episodeNum,
            style: const TextStyle(color: AppColors.text),
          ),
        ),
        title: Text(episode.title, style: AppTextStyles.body1),
        subtitle: Text(
          episode.info,
          style: AppTextStyles.body2,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(AppIcons.play, color: AppColors.primary),
          onPressed: () => _playEpisode(episode),
        ),
        onTap: () => _playEpisode(episode),
      ),
    );
  }

  void _playEpisode(Episode episode) {
    final contentProvider = Provider.of<ContentProvider>(
      context,
      listen: false,
    );
    final streamUrl = contentProvider.getSeriesStreamUrl(episode.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PlayerScreen(
              title:
                  '${widget.series.name} - S${episode.seasonNumber} E${episode.episodeNum}',
              streamUrl: streamUrl,
            ),
      ),
    );
  }
}
