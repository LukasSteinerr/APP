import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SimplePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SimplePlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: borderRadius ?? BorderRadius.circular(AppBorderRadius.medium),
      ),
    );
  }
}
