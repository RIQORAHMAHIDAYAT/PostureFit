import 'dart:async';
import 'dart:convert';
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
class NotificationController extends GetxController {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxBool isLoading = false.obs;
  
  // Tick counter untuk memaksa update label waktu relatif di UI secara eksplisit
  final RxInt _tick = 0.obs;

  Timer? _timer;

  static String get _baseUrl => AppConstants.baseUrl;

  /// Jumlah notif yang belum dibaca
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  int get tickValue => _tick.value;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
    // Refresh tick setiap 30 detik agar timeLabel terupdate
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _tick.value++;
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> _loadNotifications() async {
    isLoading.value = true;
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
      } else {
        _loadDummyData();
      }
    } catch (e) {
      print('Error loading notifications: $e');
      _loadDummyData();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDummyData() {
    final now = DateTime.now().toUtc();
    notifications.assignAll([
      NotificationItem(
        id: '1',
        title: 'Cek Postur Hari Ini',
        message: 'Jangan lupa lakukan scan postur harian Anda untuk memantau perkembangan.',
        createdAt: now.subtract(const Duration(minutes: 5)),
        type: NotificationType.posture,
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Sesi Workout Siap',
        message: 'Program latihan hari ini sudah tersedia. Mulai sekarang!',
        createdAt: now.subtract(const Duration(hours: 1)),
        type: NotificationType.workout,
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'Artikel Baru: Ergonomic Workspace',
        message: 'Temukan tips mengatur meja kerja Anda agar postur tetap terjaga.',
        createdAt: now.subtract(const Duration(hours: 3)),
        type: NotificationType.education,
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: 'Selamat! Target Mingguan Tercapai',
        message: 'Anda telah menyelesaikan 5 sesi postur minggu ini. Pertahankan!',
        createdAt: now.subtract(const Duration(days: 1)),
        type: NotificationType.system,
        isRead: true,
      ),
    ]);
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

