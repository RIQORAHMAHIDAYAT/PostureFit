import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

// ---------------------------------------------------------------------------
// Model satu item notifikasi
// ---------------------------------------------------------------------------
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime? createdAt; // timestamp asli dari backend (UTC)
  final NotificationType type;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.createdAt,
    required this.type,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      createdAt: createdAt,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Waktu relatif dihitung secara lokal berdasarkan waktu perangkat (WIB-aware).
  String get timeLabel {
    if (createdAt == null) return '';
    // createdAt adalah UTC; jadikan aware lalu bandingkan dengan now()
    final createdUtc = createdAt!.isUtc ? createdAt! : createdAt!.toUtc();
    final now = DateTime.now().toUtc();
    final diff = now.difference(createdUtc);

    final totalSeconds = diff.inSeconds;
    if (totalSeconds < 60) return 'Baru saja';
    if (totalSeconds < 3600) {
      final m = diff.inMinutes;
      return '$m menit lalu';
    }
    if (totalSeconds < 86400) {
      final h = diff.inHours;
      return '$h jam lalu';
    }
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    NotificationType parsedType;
    switch (json['type']) {
      case 'posture':
        parsedType = NotificationType.posture;
        break;
      case 'workout':
        parsedType = NotificationType.workout;
        break;
      case 'education':
        parsedType = NotificationType.education;
        break;
      case 'system':
      default:
        parsedType = NotificationType.system;
        break;
    }

    // Coba parse created_at (ISO 8601 UTC) dari backend
    DateTime? createdAt;
    final rawCreatedAt = json['created_at'];
    if (rawCreatedAt != null && rawCreatedAt is String && rawCreatedAt.isNotEmpty) {
      createdAt = DateTime.tryParse(rawCreatedAt)?.toUtc();
    }

    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: createdAt,
      type: parsedType,
      isRead: json['is_read'] ?? json['isRead'] ?? false,
    );
  }
}

enum NotificationType { posture, workout, education, system }

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------
class NotificationController extends GetxController with WidgetsBindingObserver {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxBool isLoading = false.obs;
  
  // Tick counter untuk memaksa update label waktu relatif di UI secara eksplisit
  final RxInt _tick = 0.obs;

  Timer? _timer;
  Timer? _pollingTimer;

  static String get _baseUrl => AppConstants.baseUrl;

  /// Jumlah notif yang belum dibaca
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  int get tickValue => _tick.value;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadNotifications();
    // Refresh tick setiap 30 detik agar timeLabel terupdate
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _tick.value++;
    });
    // Polling setiap 5 menit — silent agar tidak muncul spinner
    _pollingTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      loadNotifications(silent: true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Silent refresh saat app kembali ke foreground
      loadNotifications(silent: true);
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pollingTimer?.cancel();
    super.onClose();
  }

  /// [silent] = true → tidak tampilkan loading spinner (untuk polling & app resume)
  /// [silent] = false (default) → tampilkan loading spinner (untuk load awal & pull-to-refresh)
  Future<void> loadNotifications({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyToken) ?? '';

      final response = await http.get(
        Uri.parse('$_baseUrl/api/notifications'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': '69420',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];

        List<dynamic> items = [];
        if (data is Map && data.containsKey('notifications')) {
          items = data['notifications'] as List<dynamic>? ?? [];
        } else if (data is List) {
          items = data;
        }

        notifications.assignAll(
          items.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)),
        );
      }
    } catch (e) {
      // Error koneksi: pertahankan data yang sudah ada, jangan tampilkan dummy
      print('[NotificationController] Gagal fetch notifikasi: $e');
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  /// Tandai satu notifikasi sebagai sudah dibaca
  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppConstants.keyToken) ?? '';

        final response = await http.patch(
          Uri.parse('$_baseUrl/api/notifications/$id/read'),
          headers: {
            'Content-Type': 'application/json',
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': '69420',
          },
        );
        if (response.statusCode != 200) {
          print('Failed to mark as read on backend: ${response.statusCode}');
        }
      } catch (e) {
        print('Error marking notification as read: $e');
      }
    }
  }

  /// Tandai semua notifikasi sebagai sudah dibaca
  Future<void> markAllAsRead() async {
    notifications.assignAll(
      notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyToken) ?? '';

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': '69420',
        },
      );
      if (response.statusCode != 200) {
        print('Failed to mark all as read on backend: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
}
