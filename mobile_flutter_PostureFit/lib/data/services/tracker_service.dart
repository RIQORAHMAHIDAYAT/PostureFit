import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/activity_entity.dart';

class TrackerService {
  static String get _baseUrl => AppConstants.baseUrl;

  Future<Map<String, String>> get _authHeaders async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken) ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': '69420',
    };
  }

  Future<ActivityEntity?> getDailyTracker() async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tracker/daily'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['data'] != null) {
          return _parseActivity(body['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<ActivityEntity?> updateDailyTracker(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders;
      // Tambahkan tanggal hari ini (format YYYY-MM-DD)
      final now = DateTime.now();
      payload['tanggal'] = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse('$_baseUrl/api/tracker/daily'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['data'] != null) {
          return _parseActivity(body['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Parse ActivityEntity dari response backend (DailyTrackerOut schema).
  /// Backend bisa kembalikan 2 format: key Python (snake_case dari DailyTrackerOut)
  /// atau key field DB asli. Fungsi ini handle keduanya.
  ActivityEntity _parseActivity(Map<String, dynamic> data) {
    return ActivityEntity(
      olahraga:         _parseInt(data['olahraga']),
      nutrisi:          _parseInt(data['nutrisi']),
      // tidur % — backend field name: 'tidur' (dari DailyTrackerOut) atau 'tidur_persen'
      tidur:            _parseInt(data['tidur'] ?? data['tidur_persen']),
      // durasi tidur jam — backend field: 'sleep_duration' atau 'tidur_jam'
      sleepDuration:    _parseDouble(data['sleep_duration'] ?? data['tidur_jam']),
      // hidrasi saat ini — backend field: 'hydration_current' atau 'hidrasi_ml'
      hydrationCurrent: _parseDouble(data['hydration_current'] ?? data['hidrasi_ml']),
      // target hidrasi — backend field: 'hydration_target' atau 'hydration_target_ml'
      hydrationTarget:  _parseDouble(data['hydration_target'] ?? data['hydration_target_ml']) == 0
                          ? 2000
                          : _parseDouble(data['hydration_target'] ?? data['hydration_target_ml']),
      // skor aktivitas — backend field: 'activity_score' atau 'skor_aktivitas'
      activityScore:    _parseInt(data['activity_score'] ?? data['skor_aktivitas']),
    );
  }

  int    _parseInt(dynamic v)    => (v == null) ? 0 : (v is int ? v : (v as num).toInt());
  double _parseDouble(dynamic v) => (v == null) ? 0.0 : (v is double ? v : (v as num).toDouble());
}

