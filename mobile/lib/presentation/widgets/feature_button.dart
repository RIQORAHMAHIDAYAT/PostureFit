import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';

class FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? bgColor;

  const FeatureButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark
        ? const Color(0xFF1E3A52)
        : AppColors.cardBlue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingLG,
        ),
        decoration: BoxDecoration(
          color: bgColor ?? defaultBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: AppDimensions.iconMD,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.captionStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(context),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
