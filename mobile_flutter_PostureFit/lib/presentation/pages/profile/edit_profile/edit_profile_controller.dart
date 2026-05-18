import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/profile_controller.dart';

/// Controller untuk halaman Edit Profile.
/// Mengelola form input, pemilihan foto, dan menyimpan perubahan ke [ProfileController].
class EditProfileController extends GetxController {
  // ── Referensi ke ProfileController utama ─────────────────────────────────
  final ProfileController _profileCtrl = Get.find<ProfileController>();

  // ── Form Key ──────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();

  // ── Text Controllers ──────────────────────────────────────────────────────
  late final TextEditingController nameCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController ageCtrl;
  late final TextEditingController heightCtrl;
  late final TextEditingController weightCtrl;

  // ── Reactive State ────────────────────────────────────────────────────────
  /// Path gambar yang dipilih user (null = belum ada foto baru).
  final Rxn<File> pickedImageFile = Rxn<File>();

  /// Menandai apakah operasi simpan sedang berjalan.
  final RxBool isSaving = false.obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Isi form dengan data saat ini dari ProfileController
    nameCtrl   = TextEditingController(text: _profileCtrl.name.value);
    emailCtrl  = TextEditingController(text: _profileCtrl.email.value);
    ageCtrl    = TextEditingController(text: '${_profileCtrl.age.value}');
    heightCtrl = TextEditingController(text: '${_profileCtrl.height.value.toInt()}');
    weightCtrl = TextEditingController(text: '${_profileCtrl.weight.value.toInt()}');
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    ageCtrl.dispose();
    heightCtrl.dispose();
    weightCtrl.dispose();
    super.onClose();
  }

  // ── Avatar Picker ─────────────────────────────────────────────────────────

  /// Tampilkan bottom sheet pilihan sumber foto (kamera / galeri).
  void onPickAvatar() {
    Get.bottomSheet(
      _AvatarSourceSheet(onSelectSource: _pickImage),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Get.back(); // tutup bottom sheet
    final picker = ImagePicker();
    final XFile? xFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (xFile != null) {
      pickedImageFile.value = File(xFile.path);
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> onSave() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 600)); // simulasi async

    // Perbarui data di ProfileController (single source of truth)
    _profileCtrl.name.value   = nameCtrl.text.trim();
    _profileCtrl.email.value  = emailCtrl.text.trim();
    _profileCtrl.age.value    = int.tryParse(ageCtrl.text.trim()) ?? _profileCtrl.age.value;

    final h = double.tryParse(heightCtrl.text.trim()) ?? _profileCtrl.height.value;
    final w = double.tryParse(weightCtrl.text.trim()) ?? _profileCtrl.weight.value;
    _profileCtrl.height.value = h;
    _profileCtrl.weight.value = w;
    // Hitung ulang BMI
    if (h > 0) _profileCtrl.bmi.value = w / ((h / 100) * (h / 100));

    isSaving.value = false;

    Get.back();
    Get.snackbar(
      'Berhasil',
      'Profil kamu berhasil diperbarui!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF82),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
    );
  }

  // ── Validators ────────────────────────────────────────────────────────────

  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nama tidak boleh kosong';
    if (v.trim().length < 2) return 'Nama minimal 2 karakter';
    return null;
  }

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
    if (!GetUtils.isEmail(v.trim())) return 'Format email tidak valid';
    return null;
  }

  String? validateAge(String? v) {
    if (v == null || v.trim().isEmpty) return 'Usia tidak boleh kosong';
    final n = int.tryParse(v.trim());
    if (n == null || n < 5 || n > 120) return 'Usia harus antara 5–120 tahun';
    return null;
  }

  String? validateHeight(String? v) {
    if (v == null || v.trim().isEmpty) return 'Tinggi tidak boleh kosong';
    final n = double.tryParse(v.trim());
    if (n == null || n < 50 || n > 250) return 'Tinggi harus antara 50–250 cm';
    return null;
  }

  String? validateWeight(String? v) {
    if (v == null || v.trim().isEmpty) return 'Berat tidak boleh kosong';
    final n = double.tryParse(v.trim());
    if (n == null || n < 10 || n > 300) return 'Berat harus antara 10–300 kg';
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal Bottom Sheet Widget (pilihan sumber foto)
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarSourceSheet extends StatelessWidget {
  final void Function(ImageSource) onSelectSource;

  const _AvatarSourceSheet({required this.onSelectSource});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A2E4A) : Colors.white;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF243B55) : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Pilih Foto Profil',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE8F3FC) : const Color(0xFF1A2E4A),
              ),
            ),
          ),
          const Divider(height: 1),
          _SheetOption(
            icon: Icons.camera_alt_rounded,
            iconColor: const Color(0xFF4A90D9),
            label: 'Kamera',
            onTap: () => onSelectSource(ImageSource.camera),
          ),
          _SheetOption(
            icon: Icons.photo_library_rounded,
            iconColor: const Color(0xFF9B59B6),
            label: 'Galeri Foto',
            onTap: () => onSelectSource(ImageSource.gallery),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFFE8F3FC) : const Color(0xFF1A2E4A),
        ),
      ),
      onTap: onTap,
    );
  }
}
