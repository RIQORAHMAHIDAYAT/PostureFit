// workout_log_service.dart — HTTP client untuk endpoint /api/workout-log

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class WorkoutLogService {
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

  // -------------------------------------------------------------------------
  // GET /api/workout-log
  // Ambil semua riwayat workout log
  // -------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getWorkoutLogs() async {
    final headers = await _authHeaders;
    final response = await http.get(
      Uri.parse('$_baseUrl/api/workout-log'),
      headers: headers,
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      final data = body['data'];
      if (data is List) return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // -------------------------------------------------------------------------
  // POST /api/workout-log
  // Simpan sesi latihan yang sudah selesai
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> addWorkoutLog({
    required String title,
    String? category,
    String? duration,
    String? calories,
    String? image,
  }) async {
    final headers = await _authHeaders;
    final payload = {
      'title': title,
      if (category != null) 'category': category,
      if (duration != null) 'duration': duration,
      if (calories != null) 'calories': calories,
      if (image != null) 'image': image,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/api/workout-log'),
      headers: headers,
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201 || response.statusCode == 200) {
      return body['data'] as Map<String, dynamic>;
    }
    throw Exception(body['detail'] ?? 'Gagal menyimpan sesi latihan.');
  }

  // -------------------------------------------------------------------------
  // GET /api/workout-log/stats
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> getWorkoutStats() async {
    final headers = await _authHeaders;
    final response = await http.get(
      Uri.parse('$_baseUrl/api/workout-log/stats'),
      headers: headers,
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return body['data'] as Map<String, dynamic>;
    }
    return {'total_sesi': 0, 'total_kalori': 0, 'total_durasi': 0};
  }
}
