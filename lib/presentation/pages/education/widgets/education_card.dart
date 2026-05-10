import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class EducationCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String category;
  final String duration;
  final VoidCallback? onTap;

  const EducationCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.category = '',
    this.duration = '',
    this.onTap,
  });

  @override
  State<EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends State<EducationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'posture guide':
        return AppColors.primary;
      case 'tips & tricks':
        return AppColors.success;
      case 'exercise':
        return AppColors.accent;
      case 'ergonomics':
        return AppColors.warning;
      default:
        return AppColors.secondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'posture guide':
        return Icons.accessibility_new_rounded;
      case 'tips & tricks':
        return Icons.lightbulb_outline_rounded;
      case 'exercise':
        return Icons.fitness_center_rounded;
      case 'ergonomics':
        return Icons.chair_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(widget.category);
    final categoryIcon = _getCategoryIcon(widget.category);

    return GestureDetector(
      onTapDown: (_) {
        _animController.forward();
      },
      onTapUp: (_) {
        _animController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        _animController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Thumbnail placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        categoryColor.withValues(alpha: 0.15),
                        categoryColor.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: categoryColor.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      categoryIcon,
                      color: categoryColor,
                      size: AppDimensions.iconXL,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMD),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      if (widget.category.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(
                              bottom: AppDimensions.paddingXS),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSM,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusCircle),
                          ),
                          child: Text(
                            widget.category,
                            style: AppTextStyles.captionStyle.copyWith(
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      // Title
                      Text(
                        widget.title,
                        style: AppTextStyles.headingSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: AppTheme.textPrimary(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Subtitle
                      if (widget.subtitle.isNotEmpty)
                        Text(
                          widget.subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppTheme.textSecondary(context),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 6),
                      // Duration row
                      if (widget.duration.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: AppTheme.textSecondary(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.duration,
                              style: AppTextStyles.captionStyle.copyWith(
                                color: AppTheme.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Arrow
                Padding(
                  padding: const EdgeInsets.only(left: AppDimensions.paddingXS),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
