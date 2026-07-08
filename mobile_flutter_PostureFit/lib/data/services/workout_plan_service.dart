// workout_plan_service.dart — HTTP client untuk endpoint /api/workout-plan dan /api/dss.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class WorkoutPlanService {
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
  // GET /api/workout-plan/latest?lingkungan=Rumah|Gym|Calisthenics
  // Mengembalikan rencana workout personal dari assessment postur terakhir.
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>?> getLatestWorkoutPlan({String lingkungan = 'Rumah'}) async {
    final headers = await _authHeaders;
    final response = await http.get(
      Uri.parse('$_baseUrl/api/workout-plan/latest?lingkungan=$lingkungan'),
      headers: headers,
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return body['data'] as Map<String, dynamic>?;
    }
    throw Exception(body['detail'] ?? 'Gagal mengambil workout plan.');
  }

  // -------------------------------------------------------------------------
  // GET /api/dss/latest
  // Mengembalikan detail analisis DSS (skor SAW, postur, rekomendasi).
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>?> getLatestDss() async {
    final headers = await _authHeaders;
    final response = await http.get(
      Uri.parse('$_baseUrl/api/dss/latest'),
      headers: headers,
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return body['data'] as Map<String, dynamic>?;
    }
    throw Exception(body['detail'] ?? 'Gagal mengambil data DSS.');
  }

  // -------------------------------------------------------------------------
  // GET /api/dss/history
  // -------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getDssHistory() async {
    final headers = await _authHeaders;
    final response = await http.get(
      Uri.parse('$_baseUrl/api/dss/history'),
      headers: headers,
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      final data = body['data'];
      if (data is List) return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
