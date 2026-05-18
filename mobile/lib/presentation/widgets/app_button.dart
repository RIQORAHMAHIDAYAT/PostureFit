import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';

enum AppButtonVariant { primary, outline, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final Widget? prefixIcon;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.prefixIcon,
    this.isLoading = false,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case AppButtonVariant.primary:
        return _PrimaryButton(
          label: label,
          onTap: onTap,
          isLoading: isLoading,
          prefixIcon: prefixIcon,
          backgroundColor: backgroundColor,
          textColor: textColor,
        );
      case AppButtonVariant.outline:
        return _OutlineButton(
          label: label,
          onTap: onTap,
          isLoading: isLoading,
          prefixIcon: prefixIcon,
        );
      case AppButtonVariant.ghost:
        return _GhostButton(
          label: label,
          onTap: onTap,
          prefixIcon: prefixIcon,
        );
    }
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget? prefixIcon;
  final Color? backgroundColor;
  final Color? textColor;

  const _PrimaryButton({
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.prefixIcon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Ink(
          decoration: BoxDecoration(
            gradient: backgroundColor != null
                ? null
                : AppColors.primaryGradient,
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (prefixIcon != null) ...[
                        prefixIcon!,
                        const SizedBox(width: AppDimensions.paddingSM),
                      ],
                      Text(
                        label,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: textColor ?? AppColors.textWhite,
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

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget? prefixIcon;

  const _OutlineButton({
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        backgroundColor: AppColors.cardBackground,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: AppDimensions.paddingSM),
          ],
          Text(
            label,
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget? prefixIcon;

  const _GhostButton({
    required this.label,
    this.onTap,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: AppDimensions.paddingSM),
          ],
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
