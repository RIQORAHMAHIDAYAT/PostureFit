import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated tagline that slides up and fades in with a soft glow text effect.
class SplashTaglineWidget extends StatelessWidget {
  const SplashTaglineWidget({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Column(
          children: [
            // ── Main tagline
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF90CAF9), Color(0xFFE3F2FD)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: Text(
                'Move Smart. Live Strong.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF42A5F5).withOpacity(0.7),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Sub-tagline
            Text(
              'Posture correction · AI powered',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.55),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
