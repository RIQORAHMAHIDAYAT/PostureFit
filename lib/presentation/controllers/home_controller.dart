import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../data/models/user_model.dart';
import '../../domain/entities/activity_entity.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/tracker_service.dart';
import '../../../routes/app_routes.dart';
import 'main_controller.dart';

class HomeController extends GetxController {
  final RxInt selectedNavIndex = 0.obs;
  
  final _authService = AuthService();
  final _trackerService = TrackerService();
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;

  // Mengosongkan data dummy activity agar sesuai dengan status awal (kosong)
  final Rx<ActivityEntity> activity = const ActivityEntity(
    olahraga: 0,
    nutrisi: 0,
    tidur: 0,
    sleepDuration: 0.0,
    hydrationCurrent: 0,
    hydrationTarget: 2000,
    activityScore: 0,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    isLoading.value = true;
    try {
      final userData = await _authService.getMe();
      user.value = UserModel.fromJson(userData);
      
      // Ambil data tracker hari ini
      final trackerData = await _trackerService.getDailyTracker();
      if (trackerData != null) {
        activity.value = trackerData;
      }
    } on http.ClientException catch (_) {
      // Tidak ada koneksi → pakai cache
      final cached = await _authService.getCachedUser();
      user.value = cached;
    } catch (e) {
      final errStr = e.toString();
      // Jika 401 (token expired/invalid) → logout paksa
      if (errStr.contains('401') || errStr.toLowerCase().contains('not authenticated')) {
        debugPrint('Token expired → auto logout');
        await _authService.logout();
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      debugPrint('Gagal mengambil data user: $e. Mengambil cache lokal.');
      final cached = await _authService.getCachedUser();
      user.value = cached;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSleep(double hours) async {
    final updated = await _trackerService.updateDailyTracker({
      'tidur_jam': hours,
      'tidur_persen': (hours / 8.0 * 100).clamp(0, 100).toInt(),
    });
    if (updated != null) {
      activity.value = updated;
    }
  }

  Future<void> updateHydration(int ml) async {
    final updated = await _trackerService.updateDailyTracker({
      'hidrasi_ml': ml,
    });
    if (updated != null) {
      activity.value = updated;
    }
  }

  /// Simpan tidur & hidrasi sekaligus dalam 1 request (lebih efisien)
  Future<bool> updateSleepAndHydration(double hours, int hydrationMl) async {
    final updated = await _trackerService.updateDailyTracker({
      'tidur_jam': hours,
      'tidur_persen': (hours / 8.0 * 100).clamp(0, 100).toInt(),
      'hidrasi_ml': hydrationMl,
    });
    if (updated != null) {
      activity.value = updated;
      return true;
    }
    return false;
  }

  double get hydrationPercentage =>
      activity.value.hydrationCurrent / activity.value.hydrationTarget;

  String get greetingTime {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  void changeNavIndex(int index) {
    selectedNavIndex.value = index;
  }

  void onWorkoutPlanTap() {
    try {
      Get.find<MainController>().selectedIndex.value = 2;
    } catch (e) {
      Get.toNamed(AppRoutes.workoutPlan);
    }
  }

  void onBmiAnalysisTap() => Get.toNamed(AppRoutes.dssAnalysis);
  void onLogAktivitasTap() => Get.toNamed(AppRoutes.workoutLog);
  void onProgressTrackerTap() => Get.toNamed(AppRoutes.progressReport);

  void onLihatRekomendasiTap() {
    try {
      Get.find<MainController>().selectedIndex.value = 2;
    } catch (e) {
      Get.toNamed(AppRoutes.workoutPlan);
    }
  }
}
