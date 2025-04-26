import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/simple_placeholder.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final String streamUrl;
  final String? posterUrl;

  const PlayerScreen({
    super.key,
    required this.title,
    required this.streamUrl,
    this.posterUrl,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();

    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Hide status bar and navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Show status bar and navigation bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.streamUrl),
      );

      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder:
            widget.posterUrl != null && widget.posterUrl!.isNotEmpty
                ? CachedNetworkImage(
                  imageUrl: widget.posterUrl!,
                  fit: BoxFit.contain,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.black,
                        child: const Center(
                          child: SimplePlaceholder(width: 80, height: 80),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.black,
                        child: const Center(
                          child: SimplePlaceholder(width: 80, height: 80),
                        ),
                      ),
                )
                : Container(
                  color: Colors.black,
                  child: const Center(
                    child: SimplePlaceholder(width: 80, height: 80),
                  ),
                ),
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.accent,
          backgroundColor: AppColors.card,
          bufferedColor: AppColors.divider,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: AppColors.error),
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load video: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child:
            _isLoading
                ? const LoadingIndicator(message: 'Loading video...')
                : _error != null
                ? ErrorDisplay(
                  errorMessage: _error!,
                  onRetry: _initializePlayer,
                )
                : _chewieController != null
                ? Chewie(controller: _chewieController!)
                : const Center(
                  child: Text(
                    'Failed to load video player',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
      ),
    );
  }
}
