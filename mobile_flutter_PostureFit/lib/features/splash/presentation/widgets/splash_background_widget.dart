import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full-screen gradient background with subtle decorative circles.
class SplashBackgroundWidget extends StatelessWidget {
  const SplashBackgroundWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Main gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF), // Putih bersih
                Color(0xFFF0F7FF), // Putih kebiruan sangat muda
                Color(0xFFD6E8FB), // Biru muda lembut
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
        ),

        // ── Decorative circles (top-right)
        Positioned(
          top: -80,
          right: -60,
          child: _DecorativeCircle(
            size: 260,
            color: const Color(0xFF42A5F5).withOpacity(0.06), // Biru transparan
          ),
        ),
        Positioned(
          top: 40,
          right: 30,
          child: _DecorativeCircle(
            size: 120,
            color: const Color(0xFF1E88E5).withOpacity(0.04),
          ),
        ),

        // ── Decorative circles (bottom-left)
        Positioned(
          bottom: -100,
          left: -70,
          child: _DecorativeCircle(
            size: 300,
            color: const Color(0xFF42A5F5).withOpacity(0.08),
          ),
        ),
        Positioned(
          bottom: 60,
          left: 20,
          child: _DecorativeCircle(
            size: 80,
            color: const Color(0xFF1565C0).withOpacity(0.03),
          ),
        ),

        // ── Mesh / shimmer overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _MeshPainter(),
          ),
        ),

        // ── Content
        child,
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

/// Paints subtle diagonal mesh lines for premium texture.
class _MeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // Mengubah warna mesh menjadi biru sangat tipis karena background sekarang terang
      ..color = const Color(0xFF1565C0).withOpacity(0.03) 
      ..strokeWidth = 1;

    const spacing = 40.0;
    final count = (size.width / spacing).ceil() + (size.height / spacing).ceil();
    for (var i = -count; i <= count; i++) {
      final x = i * spacing;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * math.tan(math.pi / 5), size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
