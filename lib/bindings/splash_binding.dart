import 'package:get/get.dart';

/// Binding for the Splash screen.
/// No extra controllers needed – the SplashScreen manages its own
/// AnimationControllers via TickerProviderStateMixin.
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Reserved for future splash-specific dependencies (e.g. auth check).
  }
}
