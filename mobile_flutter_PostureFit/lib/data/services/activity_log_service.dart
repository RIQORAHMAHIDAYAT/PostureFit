import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class ActivityLogService {
  // Singleton pattern
  static final ActivityLogService _instance = ActivityLogService._internal();
  factory ActivityLogService() => _instance;
  ActivityLogService._internal();

  /// Ambil key khusus log aktivitas user berdasarkan email.
  Future<String> _getLogKey([String? customEmail]) async {
    if (customEmail != null && customEmail.isNotEmpty) {
      return 'activity_logs_$customEmail';
    }
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(AppConstants.keyUserEmail) ?? 'guest';
    return 'activity_logs_$email';
  }

  /// Ambil semua log aktivitas terdaftar untuk user.
  Future<List<Map<String, dynamic>>> getLogs([String? email]) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getLogKey(email);
    final jsonStr = prefs.getString(key);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (e) {
      debugPrint('Gagal men-decode log aktivitas: $e');
      return [];
    }
  }

  /// Tambahkan log aktivitas baru.
  Future<void> saveLog({
    required String icon,
    required String title,
    required String desc,
    DateTime? time,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getLogKey(email);
    final logs = await getLogs(email);

    // Reset flag has_cleared_logs ketika ada aktivitas baru yang dicatat
    final emailKey = email ?? prefs.getString(AppConstants.keyUserEmail) ?? 'guest';
    final clearFlagKey = 'has_cleared_logs_$emailKey';
    await prefs.remove(clearFlagKey);

    final newLog = {
      'icon': icon,
      'title': title,
      'desc': desc,
      'time': (time ?? DateTime.now()).toIso8601String(),
    };

    // Cek apakah log yang persis sama sudah ada di waktu yang sangat berdekatan (menghindari duplicate log)
    if (logs.isNotEmpty) {
      final lastLog = logs.last;
      if (lastLog['title'] == title && lastLog['desc'] == desc) {
        final lastTime = DateTime.parse(lastLog['time'] as String);
        final diff = (time ?? DateTime.now()).difference(lastTime).inSeconds;
        if (diff.abs() < 5) {
          // Terlalu dekat, abaikan duplicate log
          return;
        }
      }
    }

    logs.add(newLog);

    // Batasi log maksimal 50 entri demi efisiensi storage
    if (logs.length > 50) {
      logs.removeRange(0, logs.length - 50);
    }

    await prefs.setString(key, jsonEncode(logs));
  }

  /// Hapus semua log aktivitas user.
  Future<void> clearLogs([String? email]) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getLogKey(email);
    await prefs.remove(key);

    // Tandai bahwa log dihapus secara sengaja agar data mock tidak tampil kembali
    final emailKey = email ?? prefs.getString(AppConstants.keyUserEmail) ?? 'guest';
    final clearFlagKey = 'has_cleared_logs_$emailKey';
    await prefs.setBool(clearFlagKey, true);
  }

  /// Mengecek apakah user pernah secara sengaja menghapus seluruh log aktivitas mereka.
  Future<bool> hasClearedLogs([String? email]) async {
    final prefs = await SharedPreferences.getInstance();
    final emailKey = email ?? prefs.getString(AppConstants.keyUserEmail) ?? 'guest';
    final clearFlagKey = 'has_cleared_logs_$emailKey';
    return prefs.getBool(clearFlagKey) ?? false;
  }
}
