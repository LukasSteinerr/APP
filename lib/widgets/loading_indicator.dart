import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'simple_placeholder.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SimplePlaceholder(width: 100, height: 20),
          if (message != null) ...[
            const SizedBox(height: AppPaddings.medium),
            Text(
              message!,
              style: AppTextStyles.body1,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
