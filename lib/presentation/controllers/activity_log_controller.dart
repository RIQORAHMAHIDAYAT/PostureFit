import 'package:get/get.dart';

class ActivityLogController extends GetxController {
  // Mock data for activity logs
  final logs = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchLogs();
  }

  void _fetchLogs() {
    // In a real app, fetch from repository/API
    // For now, dummy data
    logs.assignAll([
      {
        'title': 'Login Berhasil',
        'desc': 'Anda login melalui perangkat Android.',
        'time': '12:05 PM, Hari ini',
        'icon': 'login',
      },
      {
        'title': 'Profil Diperbarui',
        'desc': 'Anda mengubah tinggi dan berat badan.',
        'time': '10:30 AM, Hari ini',
        'icon': 'edit',
      },
      {
        'title': 'Sesi Latihan Selesai',
        'desc': 'Menyelesaikan modul Neck Stretches.',
        'time': '08:00 AM, Kemarin',
        'icon': 'fitness_center',
      },
      {
        'title': 'Ubah Password',
        'desc': 'Kata sandi berhasil diperbarui.',
        'time': '15:20 PM, 2 Hari lalu',
        'icon': 'lock',
      },
    ]);
  }
}
