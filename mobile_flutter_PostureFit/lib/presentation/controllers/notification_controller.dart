import 'package:get/get.dart';

/// Model satu item notifikasi
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      time: time,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType { posture, workout, education, system }

class NotificationController extends GetxController {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxBool isLoading = false.obs;

  /// Jumlah notif yang belum dibaca
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  void _loadNotifications() {
    isLoading.value = true;
    // TODO: Ganti dengan fetch dari API server saat sudah siap
    notifications.assignAll([
      const NotificationItem(
        id: '1',
        title: 'Cek Postur Hari Ini',
        message: 'Jangan lupa lakukan scan postur harian Anda untuk memantau perkembangan.',
        time: '5 menit lalu',
        type: NotificationType.posture,
        isRead: false,
      ),
      const NotificationItem(
        id: '2',
        title: 'Sesi Workout Siap',
        message: 'Program latihan hari ini sudah tersedia. Mulai sekarang!',
        time: '1 jam lalu',
        type: NotificationType.workout,
        isRead: false,
      ),
      const NotificationItem(
        id: '3',
        title: 'Artikel Baru: Ergonomic Workspace',
        message: 'Temukan tips mengatur meja kerja Anda agar postur tetap terjaga.',
        time: '3 jam lalu',
        type: NotificationType.education,
        isRead: true,
      ),
      const NotificationItem(
        id: '4',
        title: 'Selamat! Target Mingguan Tercapai',
        message: 'Anda telah menyelesaikan 5 sesi postur minggu ini. Pertahankan!',
        time: 'Kemarin',
        type: NotificationType.system,
        isRead: true,
      ),
    ]);
    isLoading.value = false;
  }

  /// Tandai satu notifikasi sebagai sudah dibaca
  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
    }
  }

  /// Tandai semua notifikasi sebagai sudah dibaca
  void markAllAsRead() {
    notifications.assignAll(
      notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }
}
