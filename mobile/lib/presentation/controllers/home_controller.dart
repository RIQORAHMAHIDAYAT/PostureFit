import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/activity_entity.dart';
import '../../../routes/app_routes.dart';
import 'main_controller.dart';

class HomeController extends GetxController {
  final RxInt selectedNavIndex = 0.obs;

  final Rx<UserModel> user = UserModel.mock.obs;

  final Rx<ActivityEntity> activity = const ActivityEntity(
    olahraga: 65,
    nutrisi: 80,
    tidur: 70,
    sleepDuration: 7.2,
    hydrationCurrent: 1680,
    hydrationTarget: 2000,
    activityScore: 78,
  ).obs;

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
