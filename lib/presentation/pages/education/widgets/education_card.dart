import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../education/education_controller.dart';

/// Card edukasi: menampilkan gambar dari server + judul + deskripsi.
/// Jika [item] null → tampilkan card kosong (placeholder layout).
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
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Area Gambar ──────────────────────────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusLG),
                ),
                child: _buildImage(context),
              ),

              // ── Area Teks ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    _buildPlaceholderBox(
                      context,
                      child: isEmpty
                          ? null
                          : Text(
                              widget.item!.title,
                              style: AppTextStyles.headingSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                                color: AppTheme.textPrimary(context),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                      height: 18,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 8),
                    // Deskripsi baris 1
                    _buildPlaceholderBox(
                      context,
                      child: isEmpty
                          ? null
                          : Text(
                              widget.item!.description,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppTheme.textSecondary(context),
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                      height: 13,
                      width: double.infinity,
                    ),
                    if (isEmpty) ...[
                      const SizedBox(height: 6),
                      _buildPlaceholderBox(
                        context,
                        child: null,
                        height: 13,
                        width: 200,
                      ),
                    ],
                    const SizedBox(height: AppDimensions.paddingSM),
                    // Baca selengkapnya
                    Align(
                      alignment: Alignment.centerRight,
                      child: isEmpty
                          ? _buildPlaceholderBox(
                              context,
                              child: null,
                              height: 12,
                              width: 120,
                            )
                          : Text(
                              'Baca selengkapnya →',
                              style: AppTextStyles.captionStyle.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
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
    // Card kosong → area gambar abu-abu polos
    if (widget.item == null || widget.item!.imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 180,
        color: AppTheme.inputBg(context),
      );
    }

    // Ada URL → load dari server
    return Image.network(
      widget.item!.imageUrl,
      width: double.infinity,
      height: 180,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: double.infinity,
          height: 180,
          color: AppTheme.inputBg(context),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, _, __) => Container(
        width: double.infinity,
        height: 180,
        color: AppTheme.inputBg(context),
      ),
    );
  }

  /// Kotak placeholder abu-abu untuk teks kosong, atau tampilkan [child] jika ada data.
  Widget _buildPlaceholderBox(
    BuildContext context, {
    required Widget? child,
    required double height,
    required double width,
  }) {
    if (child != null) return child;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.borderColor(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
