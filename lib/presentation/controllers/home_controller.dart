import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/activity_entity.dart';

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

  void onWorkoutPlanTap() {}
  void onBmiAnalysisTap() => Get.toNamed('/result');
  void onLogAktivitasTap() {}
  void onProgressTrackerTap() {}
  void onLihatRekomendasiTap() {}
}
