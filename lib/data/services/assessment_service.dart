// assessment_service.dart — HTTP client untuk endpoint /api/assessment.
//
// Menangani: generate assessment (POST /api/assessment/generate),
//            history (GET /api/assessment/history),
//            latest (GET /api/assessment/latest).

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class AssessmentService {
  static String get _baseUrl => AppConstants.baseUrl;

  // -------------------------------------------------------------------------
  // Auth headers — menyertakan JWT token
  // -------------------------------------------------------------------------
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
  // -------------------------------------------------------------------------
  // POST /api/assessment/generate
  // Kirim data form vitality ke backend menggunakan MultipartRequest:
  //   - file: berkas gambar hasil scan postur
  //   - tinggi, berat, umur, lingkar → diproses SAW engine
  //   - fokus_pilihan               → disimpan sebagai pilihan user
  // Return: {bmi, kategori_tubuh, rekomendasi, saw_scores}
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> generateAssessment({
    required double tinggi,
    required double berat,
    required int umur,
    required double lingkar,
    String imagePath = '',
    List<int>? imageBytes,
    String? fokusPilihan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken) ?? '';

    final uri = Uri.parse('$_baseUrl/api/assessment/generate');
    final request = http.MultipartRequest('POST', uri);

    // Set Authorization header
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.headers['ngrok-skip-browser-warning'] = '69420';

    // Tambahkan form fields
    request.fields['tinggi'] = tinggi.toString();
    request.fields['berat'] = berat.toString();
    request.fields['umur'] = umur.toString();
    request.fields['lingkar'] = lingkar.toString();
    if (fokusPilihan != null && fokusPilihan.isNotEmpty) {
      request.fields['fokus_pilihan'] = fokusPilihan;
    }

    // Tambahkan file gambar
    if (imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    } else if (imageBytes != null && imageBytes.isNotEmpty) {
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: 'scan.jpg'));
    } else {
      throw Exception('Berkas gambar scan tidak ditemukan.');
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    // Tangani error spesifik
    if (response.statusCode == 401) {
      throw Exception('Sesi telah berakhir. Silakan login ulang.');
    }
    throw Exception(
      responseBody['detail'] ?? 'Analisis gagal. Periksa koneksi dan coba lagi.',
    );
  }

  // -------------------------------------------------------------------------
  // GET /api/assessment/history
  // Ambil riwayat semua scan assessment milik user yang login.
  // -------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getHistory() async {
    final headers = await _authHeaders;
    final response = await http.get(
      Uri.parse('$_baseUrl/api/assessment/history'),
      headers: headers,
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      final data = responseBody['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    }

    throw Exception(responseBody['detail'] ?? 'Gagal mengambil riwayat assessment.');
  }

  // -------------------------------------------------------------------------
  // GET /api/assessment/latest
  // Ambil hasil assessment terbaru milik user yang login.
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>?> getLatest() async {
    final headers = await _authHeaders;
    final response = await http.get(
      Uri.parse('$_baseUrl/api/assessment/latest'),
      headers: headers,
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return responseBody['data'] as Map<String, dynamic>?;
    }

    throw Exception(responseBody['detail'] ?? 'Gagal mengambil assessment terbaru.');
  }
}
