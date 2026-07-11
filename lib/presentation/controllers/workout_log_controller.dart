import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/workout_log_service.dart';
import './workout_plan_controller.dart';

class WorkoutLogController extends GetxController {
  final _service = WorkoutLogService();

  // State
  final RxList<Map<String, dynamic>> workoutLogs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // State untuk timer sesi aktif
  final RxBool isWorkoutActive = false.obs;
  final RxString activeWorkoutName = ''.obs;
  final RxString activeWorkoutCategory = ''.obs;
  final RxString activeWorkoutSetReps = ''.obs;
  final RxInt activeWorkoutCalories = 0.obs;
  
  final RxInt elapsedSeconds = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    fetchLogs();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> fetchLogs() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final logs = await _service.getWorkoutLogs();
      workoutLogs.value = logs;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------------------------------------------------------------
  // Timer & Session Logic
  // -------------------------------------------------------------------------
  
  void startWorkout(WorkoutItem item) {
    if (isWorkoutActive.value) {
      Get.snackbar(
        'Sesi Sedang Berjalan',
        'Selesaikan sesi latihan saat ini terlebih dahulu.',
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    activeWorkoutName.value = item.nama;
    activeWorkoutCategory.value = item.target;
    activeWorkoutSetReps.value = item.setReps;
    activeWorkoutCalories.value = item.kalori;
    elapsedSeconds.value = 0;
    isWorkoutActive.value = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds.value++;
    });

    Get.snackbar(
      'Mulai Latihan',
      'Sesi ${item.nama} telah dimulai. Semangat!',
      backgroundColor: Colors.green.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> finishWorkout() async {
    if (!isWorkoutActive.value) return;

    _timer?.cancel();
    isWorkoutActive.value = false;

    // Hitung menit
    final minutes = (elapsedSeconds.value / 60).ceil();
    final durationStr = '$minutes menit';
    final calStr = '${activeWorkoutCalories.value} kcal';

    // Munculkan loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await _service.addWorkoutLog(
        title: activeWorkoutName.value,
        category: activeWorkoutCategory.value,
        duration: durationStr,
        calories: calStr,
      );

      Get.back(); // Tutup loading
      
      Get.snackbar(
        'Kerja Bagus!',
        'Sesi latihan berhasil diselesaikan dan dicatat.',
        backgroundColor: Colors.blue.withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );

      // Refresh log
      fetchLogs();
    } catch (e) {
      Get.back(); // Tutup loading
      Get.snackbar(
        'Gagal Menyimpan',
        e.toString(),
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  void cancelWorkout() {
    _timer?.cancel();
    isWorkoutActive.value = false;
    elapsedSeconds.value = 0;
  }

  String get formattedTimer {
    final m = (elapsedSeconds.value ~/ 60).toString().padLeft(2, '0');
    final s = (elapsedSeconds.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
