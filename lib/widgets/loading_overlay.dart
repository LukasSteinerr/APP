import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'simple_placeholder.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;
  final List<String>? loadingSteps;
  final int currentStep;

  const LoadingOverlay({
    super.key,
    required this.message,
    this.loadingSteps,
    this.currentStep = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Use a semi-transparent background
    return Container(
      color: const Color(
        0xE6121212,
      ), // 90% opacity of AppColors.background (0xFF121212)
      child: Center(
        child: Card(
          color: AppColors.card,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppPaddings.large),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SimplePlaceholder(width: 100, height: 20),
                const SizedBox(height: AppPaddings.large),
                Text(
                  message,
                  style: AppTextStyles.headline3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppPaddings.medium),
                if (loadingSteps != null) ...[
                  const SizedBox(height: AppPaddings.medium),
                  _buildStepsList(),
                ],
                const SizedBox(height: AppPaddings.large),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        loadingSteps!.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (index < currentStep)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                )
              else if (index == currentStep)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                )
              else
                const Icon(
                  Icons.circle_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              const SizedBox(width: AppPaddings.small),
              Text(
                loadingSteps![index],
                style:
                    index <= currentStep
                        ? AppTextStyles.body1
                        : AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
