import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/activity_entity.dart';
import '../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';
import 'main_controller.dart';

class HomeController extends GetxController {
  final RxInt selectedNavIndex = 0.obs;
  
  final _authService = AuthService();
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
    } catch (e) {
      print('Gagal mengambil data user: $e');
    } finally {
      isLoading.value = false;
    }
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
