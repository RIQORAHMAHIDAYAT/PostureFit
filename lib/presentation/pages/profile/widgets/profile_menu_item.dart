import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

/// Flexible settings list-tile that supports:
/// - [trailing] = Switch  (when [hasSwitch] is true)
/// - [trailing] = Arrow   (when [hasArrow] is true)
/// - No trailing widget   (e.g., App Version)
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;

  // Switch variant
  final bool hasSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  // Arrow variant
  final bool hasArrow;
  final VoidCallback? onTap;

  // Destructive (red) styling
  final bool isDestructive;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
    this.hasSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
    this.hasArrow = false,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleStyle = isDestructive
        ? AppTextStyles.headingSmall.copyWith(color: AppColors.error)
        : AppTextStyles.headingSmall.copyWith(
            color: AppTheme.textPrimary(context),
          );

    Widget? trailingWidget;
    if (hasSwitch) {
      trailingWidget = Transform.scale(
        scale: 0.85,
        child: Switch(
          value: switchValue,
          onChanged: onSwitchChanged,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primaryLight.withValues(alpha: 0.4),
          inactiveThumbColor: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          inactiveTrackColor: isDark
              ? const Color(0xFF243B55)
              : Colors.grey.shade200,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    } else if (hasArrow) {
      trailingWidget = Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppTheme.textSecondary(context),
      );
    }

    return GestureDetector(
      onTap: hasSwitch ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLG,
          vertical: AppDimensions.paddingMD,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          border: Border(
            bottom: BorderSide(
              color: AppTheme.dividerColor(context),
              width: 0.8,
            ),
          ),
        ),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Icon(icon, color: iconColor, size: AppDimensions.iconMD),
            ),
            const SizedBox(width: AppDimensions.paddingMD),
            // Label column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: titleStyle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.captionStyle.copyWith(
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
      ),
    );
  }
}
