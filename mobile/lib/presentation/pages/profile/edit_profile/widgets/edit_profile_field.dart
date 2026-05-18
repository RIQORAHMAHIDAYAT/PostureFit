import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/theme/app_theme.dart';

/// Input field berdesain premium untuk halaman Edit Profile.
///
/// Mendukung:
/// - Label + ikon kiri
/// - Keyboard type & input formatters
/// - Sufiks unit teks (mis. "cm", "kg")
/// - Validasi melalui [validator]
class EditProfileField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color iconColor;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final String? Function(String?)? validator;
  final String? hintText;
  final bool readOnly;

  const EditProfileField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.suffixText,
    this.validator,
    this.hintText,
    this.readOnly = false,
  });

  @override
  State<EditProfileField> createState() => _EditProfileFieldState();
}

class _EditProfileFieldState extends State<EditProfileField>
    with SingleTickerProviderStateMixin {
  late AnimationController _borderAnim;
  late Animation<double> _borderOpacity;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _borderAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _borderOpacity = CurvedAnimation(parent: _borderAnim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _borderAnim.dispose();
    super.dispose();
  }

  void _onFocusChange(bool focused) {
    setState(() => _isFocused = focused);
    if (focused) {
      _borderAnim.forward();
    } else {
      _borderAnim.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = _isFocused ? AppColors.primary : AppTheme.borderColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            widget.label,
            style: AppTextStyles.headingSmall.copyWith(
              color: AppTheme.textPrimary(context),
              fontSize: 13,
            ),
          ),
        ),

        // ── Field ──────────────────────────────────────────────────────────
        AnimatedBuilder(
          animation: _borderOpacity,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Focus(
                onFocusChange: _onFocusChange,
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  validator: widget.validator,
                  readOnly: widget.readOnly,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppTheme.textPrimary(context),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.inputBg(context),
                    hintText: widget.hintText,
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: widget.iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(widget.icon, color: widget.iconColor, size: 18),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 58,
                      minHeight: 48,
                    ),
                    suffixText: widget.suffixText,
                    suffixStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMD,
                      vertical: AppDimensions.paddingMD,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      borderSide: BorderSide(color: borderColor, width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      borderSide: BorderSide(
                        color: AppTheme.borderColor(context),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      borderSide: const BorderSide(color: AppColors.error, width: 1.8),
                    ),
                    errorStyle: AppTextStyles.captionStyle.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
