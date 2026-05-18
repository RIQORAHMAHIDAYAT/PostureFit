import 'package:get/get.dart';

class WorkoutLogController extends GetxController {
  final RxList<Map<String, dynamic>> workoutLogs = <Map<String, dynamic>>[
    {
      'title': 'Full Body Stretch',
      'category': 'Peregangan',
      'duration': '15 menit',
      'calories': '85 kcal',
      'date': 'Hari ini, 08:30',
      'image': 'assets/images/workout_1.jpg',
    },
    {
      'title': 'Lower Back Relief',
      'category': 'Terapi',
      'duration': '10 menit',
      'calories': '40 kcal',
      'date': 'Kemarin, 19:15',
      'image': 'assets/images/workout_2.jpg',
    },
    {
      'title': 'Yoga Morning',
      'category': 'Yoga',
      'duration': '30 menit',
      'calories': '150 kcal',
      'date': '14 Mei, 06:00',
      'image': 'assets/images/workout_3.jpg',
    },
  ].obs;

  void addLog(Map<String, dynamic> log) {
    workoutLogs.insert(0, log);
  }
}
