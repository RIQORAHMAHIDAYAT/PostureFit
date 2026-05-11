import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/scan_controller.dart';

class ScanView extends GetView<ScanController> {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2E) : const Color(0xFFDEECFA),
      body: Column(
        children: [
          _ScanAppBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const Expanded(child: _ViewfinderCard()),
                  const SizedBox(height: 24),
                  _CaptureButton(),
                  SizedBox(height: bottomSafe + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanAppBar extends GetView<ScanController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, MediaQuery.of(context).padding.top, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF0D2137),
            Color(0xFF1A3A5C),
            Color(0xFF2E6099),
            Color(0xFF5A9ED4),
            Color(0xFFAAD4F5),
          ],
          stops: [0.0, 0.2, 0.5, 0.75, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.onBack,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewfinderCard extends GetView<ScanController> {
  const _ViewfinderCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final hasCapture = controller.hasCapture.value;
      final imageFile = controller.capturedImage.value;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2E4A) : const Color(0xFF252D3D),
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Gambar yang sudah diambil / kamera preview
            if (hasCapture && imageFile != null)
              Positioned.fill(
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
              )
            else
              Positioned.fill(child: CustomPaint(painter: _CornerGuidesPainter())),

            // Tampilkan sosok manusia hanya saat belum capture
            if (!hasCapture)
              Center(
                child: Opacity(
                  opacity: 0.88,
                  child: const _HumanFigure(),
                ),
              ),

            // Overlay sukses setelah capture
            if (hasCapture)
              Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded,
                      color: Color(0xFF5EE0A0), size: 72),
                ),
              ),

            // Animasi scan line saat belum capture
            if (!hasCapture) const _ScanLine(),
          ],
        ),
      );
    });
  }
}

class _HumanFigure extends StatelessWidget {
  const _HumanFigure();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final h = constraints.maxHeight * 0.92;
        final w = h * 0.65;
        return SizedBox(
          width: w,
          height: h,
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Color(0xFF8A9AB5),
              BlendMode.srcIn,
            ),
            child: Image.asset(
              'assets/icons/logo_posture.png',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.55;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Positioned(
        top: _anim.value * maxH,
        left: 0,
        right: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Area sweep gradien di atas garis
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF00E5FF).withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
            // Garis scan utama
            Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFF00E5FF),
                    Colors.white,
                    Color(0xFF00E5FF),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.9),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            // Area sweep gradien di bawah garis
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    const Color(0xFF00E5FF).withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureButton extends GetView<ScanController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isCaptured = controller.hasCapture.value;
      final isLoading = controller.isCapturing.value;

      return Row(
        children: [
          // Tombol galeri
          GestureDetector(
            onTap: isLoading ? null : controller.onPickFromGallery,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A5C),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: const Color(0xFF4A90D9).withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Tombol kamera utama
          Expanded(
            child: GestureDetector(
              onTap: isLoading
                  ? null
                  : isCaptured
                      ? controller.onRetake
                      : controller.onCapture,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF7AAEDE), Color(0xFF4A90D9)]),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A90D9).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCaptured
                                  ? Icons.replay_rounded
                                  : Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCaptured ? 'Ambil Ulang' : 'Buka Kamera',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _CornerGuidesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF6AAEE8).withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const l = 28.0;
    const d = 20.0;
    final W = size.width;
    final H = size.height;
    canvas.drawLine(Offset(d, d + l), Offset(d, d), p);
    canvas.drawLine(Offset(d, d), Offset(d + l, d), p);
    canvas.drawLine(Offset(W - d - l, d), Offset(W - d, d), p);
    canvas.drawLine(Offset(W - d, d), Offset(W - d, d + l), p);
    canvas.drawLine(Offset(d, H - d - l), Offset(d, H - d), p);
    canvas.drawLine(Offset(d, H - d), Offset(d + l, H - d), p);
    canvas.drawLine(Offset(W - d - l, H - d), Offset(W - d, H - d), p);
    canvas.drawLine(Offset(W - d, H - d - l), Offset(W - d, H - d), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}