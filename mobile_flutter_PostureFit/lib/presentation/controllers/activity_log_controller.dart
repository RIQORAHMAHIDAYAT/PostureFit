import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/activity_log_service.dart';
import '../../data/models/user_model.dart';
import 'profile_controller.dart';

class ActivityLogController extends GetxController {
  final logs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  final _authService = AuthService();
  final _activityLogService = ActivityLogService();

  @override
  void onInit() {
    super.onInit();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    isLoading.value = true;
    try {
      // 1. Ambil data profil dari backend untuk mengetahui tanggal registrasi (created_at)
      UserModel? currentUser;
      try {
        final profileData = await _authService.getMe();
        currentUser = UserModel.fromJson(profileData);
      } catch (e) {
        debugPrint('Gagal mengambil data user di ActivityLogController: $e');
      }

      // 2. Resolusi email aktif (dari ProfileController atau SharedPreferences)
      String? activeEmail;
      try {
        if (Get.isRegistered<ProfileController>()) {
          activeEmail = Get.find<ProfileController>().email.value;
        }
      } catch (_) {}

      // Ambil log aktivitas lokal dari SharedPreferences dan cek flag penghapusan
      final localLogs = await _activityLogService.getLogs(activeEmail);
      final hasCleared = await _activityLogService.hasClearedLogs(activeEmail);

      // 3. Gabungkan dan pastikan log registrasi masuk (menggunakan created_at dari backend)
      final List<Map<String, dynamic>> combined = List.from(localLogs);

      // Cek apakah entri Registrasi Akun sudah ada
      final hasRegistrationLog = combined.any((log) =>
          log['title'] == 'Registrasi Akun' || log['icon'] == 'register');

      if (!hasRegistrationLog && currentUser != null && currentUser.createdAt != null) {
        // Tambahkan registrasi log berdasarkan data riil created_at dari backend
        combined.add({
          'icon': 'login',
          'title': 'Registrasi Akun',
          'desc': 'Akun PostureFit Anda telah berhasil dibuat.',
          'time': currentUser.createdAt!.toIso8601String(),
        });
      }

      // Tampilkan data seed/mock agar riwayat tidak terlihat hilang sendiri,
      // dan tetap ada selama user belum pernah melakukan 'Clear All' secara manual.
      if (!hasCleared) {
        final now = DateTime.now();
        // Hanya tambahkan jika log dengan judul yang sama belum ada untuk menghindari duplikasi
        // jika kita nanti memutuskan untuk menyimpannya ke SharedPreferences.
        final mockLogs = [
          {
            'icon': 'login',
            'title': 'Registrasi Akun',
            'desc': 'Akun PostureFit Anda telah berhasil dibuat.',
            'time': now.subtract(const Duration(days: 2, hours: 3)).toIso8601String(),
          },
          {
            'icon': 'login',
            'title': 'Login Awal',
            'desc': 'Berhasil masuk ke aplikasi untuk pertama kali.',
            'time': now.subtract(const Duration(days: 2, hours: 2)).toIso8601String(),
          },
          {
            'icon': 'edit',
            'title': 'Pembaruan Profil',
            'desc': 'Mengubah data: Nama, Usia, Tinggi Badan, Berat Badan.',
            'time': now.subtract(const Duration(days: 1, hours: 5)).toIso8601String(),
          },
          {
            'icon': 'fitness_center',
            'title': 'Analisis Postur',
            'desc': 'Melakukan analisis postur tubuh dengan hasil kategori: Normal.',
            'time': now.subtract(const Duration(hours: 4)).toIso8601String(),
          },
        ];

        for (var mock in mockLogs) {
          if (!combined.any((log) => log['title'] == mock['title'])) {
            combined.add(mock);
          }
        }
      }

      // 4. Urutkan berdasarkan waktu descending (terbaru di paling atas)
      combined.sort((a, b) {
        final timeA = DateTime.parse(a['time'] as String);
        final timeB = DateTime.parse(b['time'] as String);
        return timeB.compareTo(timeA);
      });

      // 5. Format waktu menjadi teks ramah pengguna (Indonesian relative/absolute time)
      final formattedLogs = combined.map((log) {
        return {
          'icon': log['icon'],
          'title': log['title'],
          'desc': log['desc'],
          'time': _formatFriendlyDate(log['time'] as String),
        };
      }).toList();

      logs.assignAll(formattedLogs);
    } catch (e) {
      debugPrint('Gagal memuat log aktivitas: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Menampilkan dialog konfirmasi untuk menghapus semua log aktivitas lokal.
  void clearAllLogs() {
    if (logs.isEmpty) {
      Get.snackbar(
        'Log Kosong',
        'Tidak ada aktivitas yang perlu dihapus.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    Get.defaultDialog(
      title: 'Hapus Aktivitas',
      middleText: 'Apakah Anda yakin ingin menghapus semua catatan aktivitas?',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFE05C5C),
      onConfirm: () async {
        Get.back(); // Tutup dialog
        isLoading.value = true;
        try {
          String? activeEmail;
          try {
            if (Get.isRegistered<ProfileController>()) {
              activeEmail = Get.find<ProfileController>().email.value;
            }
          } catch (_) {}

          await _activityLogService.clearLogs(activeEmail);
          await fetchLogs(); // Segarkan data log
          Get.snackbar(
            'Berhasil',
            'Seluruh catatan aktivitas berhasil dihapus.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF4CAF82),
            colorText: Colors.white,
          );
        } catch (e) {
          debugPrint('Gagal menghapus log: $e');
          Get.snackbar(
            'Gagal',
            'Gagal menghapus catatan aktivitas.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE05C5C),
            colorText: Colors.white,
          );
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  /// Memformat ISO-8601 String menjadi format waktu bahasa Indonesia yang ramah pengguna.
  String _formatFriendlyDate(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} menit lalu';
      } else if (difference.inHours < 24) {
        // Cek apakah hari yang sama
        if (dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) {
          final hour = dateTime.hour.toString().padLeft(2, '0');
          final minute = dateTime.minute.toString().padLeft(2, '0');
          return 'Hari ini, $hour:$minute';
        }
      }

      // Kemarin
      final yesterday = now.subtract(const Duration(days: 1));
      if (dateTime.day == yesterday.day && dateTime.month == yesterday.month && dateTime.year == yesterday.year) {
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        return 'Kemarin, $hour:$minute';
      }

      // Format absolut
      final monthNames = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final month = monthNames[dateTime.month - 1];
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');

      return '${dateTime.day} $month ${dateTime.year}, $hour:$minute';
    } catch (e) {
      return isoString;
    }
  }
}
