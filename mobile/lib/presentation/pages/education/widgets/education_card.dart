import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../controllers/education_controller.dart';

/// Card edukasi: menampilkan gambar + judul + ringkasan + kategori.
class EducationCard extends StatefulWidget {
  final EducationItem? item;
  final VoidCallback? onTap;

  const EducationCard({
    super.key,
    this.item,
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

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.item == null;

    return GestureDetector(
      onTapDown: isEmpty ? null : (_) => _animController.forward(),
      onTapUp: isEmpty
          ? null
          : (_) {
              _animController.reverse();
              widget.onTap?.call();
            },
      onTapCancel: isEmpty ? null : () => _animController.reverse(),
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
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Area Gambar & Tag ────────────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusLG),
                    ),
                    child: _buildImage(context),
                  ),
                  if (!isEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.item!.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // ── Area Teks ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isEmpty)
                      _buildShimmerText(context)
                    else ...[
                      Text(
                        widget.item!.title,
                        style: AppTextStyles.headingSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppTheme.textPrimary(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.item!.summary,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textSecondary(context),
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${widget.item!.source} • ${widget.item!.publishedAt}",
                            style: AppTextStyles.captionStyle.copyWith(
                              color: AppTheme.textSecondary(context).withValues(alpha: 0.7),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (widget.item == null || widget.item!.imageUrl.isEmpty) {
      return Shimmer.fromColors(
        baseColor: AppTheme.inputBg(context),
        highlightColor: AppTheme.inputBg(context).withValues(alpha: 0.5),
        child: Container(
          width: double.infinity,
          height: 160,
          color: Colors.white,
        ),
      );
    }

    return Image.network(
      widget.item!.imageUrl,
      width: double.infinity,
      height: 160,
      fit: BoxFit.cover,
      errorBuilder: (context, _, __) => Container(
        width: double.infinity,
        height: 160,
        color: AppTheme.inputBg(context),
        child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
      ),
    );
  }

  Widget _buildShimmerText(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.inputBg(context),
      highlightColor: AppTheme.inputBg(context).withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 16, width: double.infinity, color: Colors.white),
          const SizedBox(height: 8),
          Container(height: 12, width: double.infinity, color: Colors.white),
          const SizedBox(height: 6),
          Container(height: 12, width: 150, color: Colors.white),
        ],
      ),
    );
  }
}
