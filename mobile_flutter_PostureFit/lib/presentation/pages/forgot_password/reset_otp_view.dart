// reset_otp_view.dart — Halaman Verifikasi OTP untuk Reset Password.
//
// Langkah 2: Setelah email diinput, user memasukkan 6 digit kode OTP.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/forgot_password_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';

class ResetOtpView extends GetView<ForgotPasswordController> {
  const ResetOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Ambil email sekali saat build — tidak perlu Obx karena tidak berubah
    final email = controller.emailController.text;

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
                // ── Back button ─────────────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: controller.goBackToForgotPassword,
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

                // ── Logo ────────────────────────────────────────────────────
                const AppLogo(),
                const SizedBox(height: AppDimensions.paddingMD),

                // ── Card utama ──────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingXXL),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // ── Icon email ────────────────────────────────────────
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
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
                          Icons.mark_email_read_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingLG),

                      Text(
                        'Kode Verifikasi',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppTheme.textPrimary(context),
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.paddingSM),

                      // ── Tampilkan email — tidak perlu Obx ─────────────────
                      Text(
                        'Kode OTP 6 digit telah dikirim ke:',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.paddingXXL),

                      // ── 6 Kotak OTP ───────────────────────────────────────
                      _ResetOtpInputRow(controller: controller, isDark: isDark),

                      // ── Error message — muncul/hilang tanpa geser layout ──
                      const SizedBox(height: AppDimensions.paddingMD),
                      Obx(() {
                        final msg = controller.otpErrorMessage.value;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: msg.isNotEmpty
                              ? Container(
                                  key: const ValueKey('error'),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.red.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: Colors.red, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          msg,
                                          style:
                                              AppTextStyles.bodySmall.copyWith(
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(key: ValueKey('empty')),
                        );
                      }),

                      const SizedBox(height: AppDimensions.paddingXXL),

                      // ── Tombol Verifikasi ─────────────────────────────────
                      Obx(() => AppButton(
                            label: 'VERIFIKASI OTP',
                            onTap: controller.verifyResetOtp,
                            isLoading: controller.isOtpLoading.value,
                          )),
                      const SizedBox(height: AppDimensions.paddingXL),

                      // ── Resend OTP ────────────────────────────────────────
                      Obx(() {
                        final sec = controller.secondsLeft.value;
                        final canResend = sec == 0;
                        final isResending = controller.isResending.value;
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
                              onTap:
                                  canResend && !isResending
                                      ? controller.resendResetOtp
                                      : null,
                              child: isResending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Text(
                                      canResend
                                          ? 'Kirim Ulang OTP'
                                          : 'Kirim ulang dalam ${sec}s',
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
                                        decorationColor: AppColors.primary,
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
// Widget: Baris 6 kotak input OTP — Responsive terhadap lebar layar
// ---------------------------------------------------------------------------
class _ResetOtpInputRow extends StatelessWidget {
  final ForgotPasswordController controller;
  final bool isDark;

  const _ResetOtpInputRow({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder mendapat lebar PERSIS dari parent (sudah dikurangi padding card)
    // lebih andal daripada MediaQuery karena tidak perlu hitung offset manual
    return LayoutBuilder(
      builder: (context, constraints) {
        // Total gap horizontal: 6 kotak × padding kiri-kanan (4+4) = 48px
        final boxSize = ((constraints.maxWidth - 48) / 6).clamp(32.0, 48.0);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _OtpDigitBox(
                textController: controller.otpControllers[i],
                focusNode: controller.focusNodes[i],
                isDark: isDark,
                boxSize: boxSize,
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
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Widget: Satu kotak digit OTP — ukuran responsif, FocusNode stabil
// ---------------------------------------------------------------------------
class _OtpDigitBox extends StatefulWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool isDark;
  final double boxSize;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpDigitBox({
    required this.textController,
    required this.focusNode,
    required this.isDark,
    required this.boxSize,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  State<_OtpDigitBox> createState() => _OtpDigitBoxState();
}

class _OtpDigitBoxState extends State<_OtpDigitBox> {
  // FocusNode untuk KeyboardListener harus stabil selama lifetime widget
  final _keyListenerFocusNode = FocusNode();

  @override
  void dispose() {
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.boxSize,
      height: widget.boxSize + 10,
      child: KeyboardListener(
        focusNode: _keyListenerFocusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            widget.onBackspace();
          }
        },
        child: TextField(
          controller: widget.textController,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: widget.boxSize * 0.45,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary(context),
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.shade50,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    widget.isDark ? Colors.white30 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    widget.isDark ? Colors.white24 : Colors.grey.shade300,
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
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
