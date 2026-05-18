import 'package:flutter/material.dart';

/// Animated logo widget with fade, scale, and soft pulsing glow effects.
///
/// Uses native Flutter animations only – no third-party packages.
class AnimatedLogoWidget extends StatelessWidget {
  const AnimatedLogoWidget({
    super.key,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.glowAnimation,
    required this.glowController,
    required this.imagePath,
    required this.logoSize,
  });

  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final Animation<double> glowAnimation; // value: 0.0 → 1.0 (pulsing)
  final AnimationController glowController;
  final String imagePath;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: AnimatedBuilder(
          animation: glowController,
          builder: (_, child) {
            return Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  // Inner soft glow – pulses with glowAnimation
                  BoxShadow(
                    color: const Color(0xFF42A5F5).withOpacity(
                      0.30 + 0.22 * glowAnimation.value,
                    ),
                    blurRadius: 40 + 22 * glowAnimation.value,
                    spreadRadius: 4 + 2 * glowAnimation.value,
                  ),
                  // Outer ambient shadow (static)
                  BoxShadow(
                    color: const Color(0xFF0D47A1).withOpacity(0.50),
                    blurRadius: 60,
                    spreadRadius: 8,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(logoSize / 2),
            child: Image.asset(
              imagePath,
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
