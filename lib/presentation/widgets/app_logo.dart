import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';

class AppLogo extends StatelessWidget {
  final double iconSize;
  final bool showTitle;

  const AppLogo({
    super.key,
    this.iconSize = 64,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(iconSize * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.directions_run_rounded,
            color: AppColors.textWhite,
            size: iconSize * 0.55,
          ),
        ),
        if (showTitle) ...[
          const SizedBox(height: AppDimensions.paddingMD),
          Text('PostureFit', style: AppTextStyles.logoTitle),
        ],
      ],
    );
  }
}
