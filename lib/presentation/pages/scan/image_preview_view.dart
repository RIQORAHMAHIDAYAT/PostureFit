import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/scan_controller.dart';

/// Halaman preview gambar hasil scan postur.
/// Mengambil bytes gambar dari ScanController (cross-platform: web & mobile).
class ImagePreviewView extends StatefulWidget {
  const ImagePreviewView({super.key});

  @override
  State<ImagePreviewView> createState() => _ImagePreviewViewState();
}

class _ImagePreviewViewState extends State<ImagePreviewView> {
  Uint8List? _imageBytes;
  final TransformationController _transformCtrl = TransformationController();

  @override
  void initState() {
    super.initState();
    // Ambil bytes dari ScanController (sudah tersimpan saat pick/capture)
    if (Get.isRegistered<ScanController>()) {
      _imageBytes = Get.find<ScanController>().capturedBytes.value;
    }
    // Fallback: cek apakah dikirim lewat arguments (untuk mobile path)
    final args = Get.arguments;
    if (_imageBytes == null && args is Map && args['imageBytes'] is Uint8List) {
      _imageBytes = args['imageBytes'] as Uint8List;
    }
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformCtrl.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imageBytes != null && _imageBytes!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: hasImage
                ? _buildImageViewer(_imageBytes!)
                : _buildNoImageState(),
          ),
          if (hasImage) _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top,
        16,
        12,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryAppBarGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: AppColors.primaryAppBarShadow,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
            ),
          ),
          Expanded(
            child: Text(
              'Hasil Gambar Postur',
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Tombol reset zoom
          GestureDetector(
            onTap: _resetZoom,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.zoom_out_map_rounded,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Reset',
                    style: AppTextStyles.captionStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer(Uint8List bytes) {
    return Stack(
      children: [
        // Gambar interaktif (bisa di-pinch zoom & pan) — pakai Image.memory (cross-platform)
        InteractiveViewer(
          transformationController: _transformCtrl,
          minScale: 0.5,
          maxScale: 5.0,
          child: Center(
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        // Label hint zoom
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pinch_outlined, color: Colors.white70, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    kIsWeb
                        ? 'Scroll untuk zoom • Geser untuk pindah'
                        : 'Cubit untuk zoom • Geser untuk pindah',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoImageState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Gambar tidak tersedia',
            style: AppTextStyles.headingSmall.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Ambil foto terlebih dahulu\nmelalui halaman Scan.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white38,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Kembali',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      color: const Color(0xFF0D1B2E),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Colors.white38, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gambar digunakan untuk analisis postur. Gunakan pinch-to-zoom untuk melihat detail.',
              style: AppTextStyles.captionStyle.copyWith(
                color: Colors.white38,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
