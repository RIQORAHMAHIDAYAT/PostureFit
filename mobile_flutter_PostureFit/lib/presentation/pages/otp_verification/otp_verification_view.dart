// otp_verification_view.dart — Halaman verifikasi OTP saat register.
//
// Desain: 6 kotak input OTP dengan styling premium,
// countdown resend, animasi loading, pesan error.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/otp_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';

class OtpVerificationView extends GetView<OtpController> {
  const OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.bgColor(context),
                    AppTheme.bgSecondaryColor(context),
                  ],
                )
              : AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingXL,
              vertical: AppDimensions.paddingXXL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Back button ──────────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: controller.goBack,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLG),

                // ── Logo ─────────────────────────────────────────────────
                const AppLogo(),
                const SizedBox(height: AppDimensions.paddingMD),

                // ── Card utama ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingXXL),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.borderColor(context),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // ── Icon shield ────────────────────────────────────
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF2196F3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingLG),

                      Text(
                        'Verifikasi Email',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppTheme.textPrimary(context),
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.paddingSM),

                      Text(
                        'Kode OTP 6 digit telah dikirim ke Email:\n${controller.email}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.paddingXXL),

                      // ── 6 Kotak OTP ────────────────────────────────────
                      _OtpInputRow(controller: controller, isDark: isDark),
                      const SizedBox(height: AppDimensions.paddingMD),

                      // ── Error message ──────────────────────────────────
                      Obx(() {
                        if (controller.errorMessage.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: AppDimensions.paddingXXL),

                      // ── Tombol Verifikasi ──────────────────────────────
                      Obx(() => AppButton(
                            label: 'VERIFIKASI',
                            onTap: controller.verifyOtp,
                            isLoading: controller.isLoading.value,
                          )),
                      const SizedBox(height: AppDimensions.paddingXL),

                      // ── Resend OTP ─────────────────────────────────────
                      Obx(() {
                        final sec = controller.secondsLeft.value;
                        final canResend = sec == 0;
                        return Column(
                          children: [
                            Text(
                              'Tidak menerima kode?',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppTheme.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: canResend ? controller.resendOtp : null,
                              child: controller.isResending.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Text(
                                      canResend
                                          ? 'Kirim Ulang OTP'
                                          : 'Kirim ulang dalam $sec detik',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: canResend
                                            ? AppColors.primary
                                            : AppTheme.textSecondary(context),
                                        fontWeight: canResend
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        decoration: canResend
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                      ),
                                    ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingXL),
                Text(
                  'VERIFIKASI OTP',
                  style: AppTextStyles.captionStyle.copyWith(
                    letterSpacing: 1.5,
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

// ---------------------------------------------------------------------------
// Widget: Baris 6 kotak input OTP
// ---------------------------------------------------------------------------
class _OtpInputRow extends StatelessWidget {
  final OtpController controller;
  final bool isDark;

  const _OtpInputRow({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _OtpDigitBox(
            textController: controller.otpControllers[i],
            focusNode: controller.focusNodes[i],
            isDark: isDark,
            onChanged: (v) => controller.onOtpFieldChanged(i, v),
            onBackspace: () {
              if (controller.otpControllers[i].text.isEmpty && i > 0) {
                controller.otpControllers[i - 1].clear();
                controller.focusNodes[i - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget: Satu kotak digit OTP
// ---------------------------------------------------------------------------
class _OtpDigitBox extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpDigitBox({
    required this.textController,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 54,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: TextField(
          controller: textController,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary(context),
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppTheme.inputBg(context),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.borderColor(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.borderColor(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
