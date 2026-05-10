import 'package:get/get.dart';

class EducationItem {
  final String title;
  final String subtitle;
  final String category;
  final String duration;

  const EducationItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.duration,
  });
}

class EducationController extends GetxController {
  final RxList<EducationItem> educationList = <EducationItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    isLoading.value = true;
    educationList.assignAll([
      const EducationItem(
        title: 'Correct Sitting Posture',
        subtitle: 'Learn how to sit properly to avoid long-term spine issues.',
        category: 'Posture Guide',
        duration: '5 min read',
      ),
      const EducationItem(
        title: 'Avoid Back Pain',
        subtitle: 'Simple daily habits that protect your back from chronic pain.',
        category: 'Tips & Tricks',
        duration: '4 min read',
      ),
      const EducationItem(
        title: 'Stretching Routine',
        subtitle: 'A quick 10-minute morning stretch to energize your body.',
        category: 'Exercise',
        duration: '3 min read',
      ),
      const EducationItem(
        title: 'Ergonomic Workspace Setup',
        subtitle: 'Set up your desk and chair for maximum comfort and posture.',
        category: 'Ergonomics',
        duration: '6 min read',
      ),
      const EducationItem(
        title: 'Neck & Shoulder Relief',
        subtitle: 'Targeted exercises to relieve tension in neck and shoulders.',
        category: 'Exercise',
        duration: '4 min read',
      ),
    ]);
    isLoading.value = false;
  }
}
