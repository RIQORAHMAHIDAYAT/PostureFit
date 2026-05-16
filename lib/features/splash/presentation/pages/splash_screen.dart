import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/splash_background_widget.dart';

enum SplashState { none, logo2, logo1 }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  
  // Controller untuk efek glow pada Logo 1
  late final AnimationController _glowController;
  late final Animation<double> _glowPulse;

  // Menyimpan state logo mana yang sedang tampil
  SplashState _currentState = SplashState.none;

  @override
  void initState() {
    super.initState();
    _setupSystemUI();
    
    // Inisialisasi controller glow untuk logo_1
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      _preloadAndStart();
    }
  }

  Future<void> _preloadAndStart() async {
    // Pre-load images so they don't pop abruptly
    await Future.wait([
      precacheImage(const AssetImage('assets/icons/Logo_2.png'), context),
      precacheImage(const AssetImage('assets/icons/Logo_1.png'), context),
    ]);
    if (!mounted) return;
    _startSequence();
  }

  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A1628),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  Future<void> _startSequence() async {
    // 1. Beri jeda sangat singkat
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // Memunculkan Logo 2 dengan animasi Fade via AnimatedSwitcher
    setState(() {
      _currentState = SplashState.logo2;
    });

    // 2. Tahan Logo 2 selama 1.5 detik (Pacing original)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // Transisi ke Logo 1 secara smooth
    setState(() {
      _currentState = SplashState.logo1;
    });

    // Jalankan animasi glow berulang untuk Logo 1
    _glowController.repeat(reverse: true);

    // 3. Tunggu sisa waktu sebelum pindah halaman
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SplashBackgroundWidget(
        child: Center(
          // AnimatedSwitcher akan mengurus cross-fade antara logo
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              // HANYA menggunakan FadeTransition murni agar sangat smooth 
              // dan Logo 2 menghilang sempurna saat Logo 1 masuk
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _buildCurrentLogo(size),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLogo(Size size) {
    // Membuat bingkai statis/pasti untuk kedua logo agar posisinya sama persis
    // dan tidak menyebabkan pergeseran layout saat cross-fade
    final logoSize = size.width * 0.65;

    switch (_currentState) {
      case SplashState.none:
        return SizedBox(key: const ValueKey('none'), width: logoSize, height: logoSize);

      case SplashState.logo2:
        return SizedBox(
          key: const ValueKey('logo2'),
          width: logoSize,
          height: logoSize,
          child: Center(
            child: Image.asset(
              'assets/icons/Logo_2.png',
              fit: BoxFit.contain,
            ),
          ),
        );

      case SplashState.logo1:
        return SizedBox(
          key: const ValueKey('logo1'),
          width: logoSize,
          height: logoSize,
          child: Center(
            child: AnimatedBuilder(
              animation: _glowPulse,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.25 * _glowPulse.value),
                        blurRadius: 40 * _glowPulse.value,
                        spreadRadius: 12 * _glowPulse.value,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/icons/Logo_1.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
    }
  }
}
