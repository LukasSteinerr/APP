import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/network_service.dart';

class ErrorDisplay extends StatefulWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const ErrorDisplay({super.key, required this.errorMessage, this.onRetry});

  @override
  State<ErrorDisplay> createState() => _ErrorDisplayState();
}

class _ErrorDisplayState extends State<ErrorDisplay> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final hasInternet = await NetworkService.hasInternetConnection();
    if (mounted) {
      setState(() {
        _isOffline = !hasInternet;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the error is related to connectivity
    final bool isConnectivityError =
        widget.errorMessage.toLowerCase().contains('no internet') ||
        widget.errorMessage.toLowerCase().contains('failed host lookup') ||
        widget.errorMessage.toLowerCase().contains('socket') ||
        widget.errorMessage.toLowerCase().contains('connection') ||
        _isOffline;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isConnectivityError ? Icons.wifi_off : Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: AppPaddings.medium),
            Text(
              isConnectivityError
                  ? 'No internet connection.\nUsing cached data if available.'
                  : widget.errorMessage,
              style: AppTextStyles.body1,
              textAlign: TextAlign.center,
            ),
            if (widget.onRetry != null) ...[
              const SizedBox(height: AppPaddings.large),
              ElevatedButton(
                onPressed: () {
                  _checkConnectivity();
                  widget.onRetry?.call();
                },
                child: Text(
                  isConnectivityError ? 'Check Connection' : AppStrings.retry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
