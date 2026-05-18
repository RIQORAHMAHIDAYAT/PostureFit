import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../edit_profile_controller.dart';

/// Helper: ambil 2 huruf kapital dari nama
String _computeInitials(String name) {
  final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  if (parts.isEmpty) return '?';
  final word = parts[0];
  return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
}


/// Widget avatar yang dapat diklik untuk memilih foto baru.
/// Menampilkan foto dari [pickedImageFile] atau inisial dari [ProfileController].
class AvatarPickerWidget extends GetView<EditProfileController> {
  const AvatarPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: controller.onPickAvatar,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Foto / Inisial ───────────────────────────────────────────
              Obx(() {
                final file = controller.pickedImageFile.value;
                return Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: file == null ? AppColors.cardGradient : null,
                    color: file != null ? Colors.transparent : null,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: file != null
                      ? ClipOval(
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                            width: 104,
                            height: 104,
                          ),
                        )
                      : _InitialsAvatar(initials: _computeInitials(controller.nameCtrl.text)),
                );
              }),

              // ── Badge Kamera ─────────────────────────────────────────────
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Ubah Foto Profil',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inisial Avatar (fallback ketika belum ada foto)
// ─────────────────────────────────────────────────────────────────────────────

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: AppTextStyles.displayMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 32,
        ),
      ),
    );
  }
}
