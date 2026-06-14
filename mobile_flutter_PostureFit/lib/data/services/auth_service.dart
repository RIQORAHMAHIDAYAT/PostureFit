// auth_service.dart — HTTP client untuk semua endpoint /api/auth.
//
// Menangani: login, send-otp, verify-otp, resend-otp, get-me.
// Token JWT disimpan di SharedPreferences.

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  static String get _baseUrl => AppConstants.baseUrl;

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': '69420',
      };

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

  /// Simpan token & data user ke SharedPreferences.
  Future<void> _saveSession(Map<String, dynamic> tokenData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyToken, tokenData['access_token'] ?? '');
    final user = tokenData['user'] as Map<String, dynamic>?;
    if (user != null) {
      await prefs.setString(AppConstants.keyUserId,    user['id'] ?? '');
      await prefs.setString(AppConstants.keyUserName,  user['name'] ?? '');
      await prefs.setString(AppConstants.keyUserEmail, user['email'] ?? '');
    }
  }

  // -----------------------------------------------------------------------
  // POST /api/auth/login
  // -----------------------------------------------------------------------
  /// Login dengan email & password.
  /// Mengembalikan Map berisi `access_token` dan `user`.
  /// Melempar [Exception] jika gagal.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      await _saveSession(body);
      return body;
    }

    throw Exception(body['detail'] ?? 'Login gagal. Periksa email dan password Anda.');
  }

  // -----------------------------------------------------------------------
  // POST /api/auth/google
  // -----------------------------------------------------------------------
  /// Login via Google (membuat akun jika belum ada atau login jika sudah ada).
  /// Mengembalikan Map berisi `access_token` dan `user`.
  Future<Map<String, dynamic>> loginWithGoogle({
    required String email,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/google'),
      headers: _headers,
      body: jsonEncode({'email': email, 'name': name}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      await _saveSession(body);
      return body;
    }

    throw Exception(body['detail'] ?? 'Login dengan Google gagal. Coba lagi.');
  }

  // -----------------------------------------------------------------------
  // POST /api/auth/send-otp  (Langkah 1 Register)
  // -----------------------------------------------------------------------
  /// Kirim OTP ke email untuk verifikasi sebelum akun dibuat.
  Future<void> sendOtp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/send-otp'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) return;

    throw Exception(body['detail'] ?? 'Gagal mengirim OTP. Coba lagi.');
  }

  // -----------------------------------------------------------------------
  // POST /api/auth/verify-otp  (Langkah 2 Register)
  // -----------------------------------------------------------------------
  /// Verifikasi kode OTP dan selesaikan pembuatan akun.
  /// Mengembalikan Map `access_token` + `user` (langsung login).
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
    String phone = '-',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/verify-otp'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'otp_code': otpCode,
        'phone_number': phone,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      await _saveSession(body);
      return body;
    }

    throw Exception(body['detail'] ?? 'Kode OTP tidak valid atau sudah kadaluarsa.');
  }



  // -----------------------------------------------------------------------
  // POST /api/auth/resend-otp
  // -----------------------------------------------------------------------
  /// Kirim ulang OTP ke email yang sama.
  Future<void> resendOtp({required String email}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/resend-otp'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) return;

    throw Exception(body['detail'] ?? 'Gagal mengirim ulang OTP.');
  }

  // -----------------------------------------------------------------------
  // POST /api/auth/forgot-password/send-otp
  // -----------------------------------------------------------------------
  /// Minta OTP untuk reset password (email harus sudah terdaftar).
  Future<void> sendForgotPasswordOtp({required String email}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/forgot-password/send-otp'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) return;

    throw Exception(body['detail'] ?? 'Gagal mengirim OTP. Periksa email Anda.');
  }

  // -----------------------------------------------------------------------
  // POST /api/auth/forgot-password/verify-otp
  // -----------------------------------------------------------------------
  /// Verifikasi OTP untuk reset password. Mengembalikan reset_token sementara.
  Future<void> verifyForgotPasswordOtp({
    required String email,
    required String otpCode,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/forgot-password/verify-otp'),
      headers: _headers,
      body: jsonEncode({'email': email, 'otp_code': otpCode}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) return;

    throw Exception(body['detail'] ?? 'Kode OTP tidak valid atau sudah kadaluarsa.');
  }

  // -----------------------------------------------------------------------
  // POST /api/auth/forgot-password/reset
  // -----------------------------------------------------------------------
  /// Reset password setelah OTP terverifikasi.
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/forgot-password/reset'),
      headers: _headers,
      body: jsonEncode({'email': email, 'new_password': newPassword}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) return;

    throw Exception(body['detail'] ?? 'Gagal mereset password. Coba lagi.');
  }

  // -----------------------------------------------------------------------
  // GET /api/auth/me
  // -----------------------------------------------------------------------
  /// Ambil profil user yang sedang login.
  Future<Map<String, dynamic>> getMe() async {
    final headers = await _authHeaders;
    final response = await http.get(
      Uri.parse('$_baseUrl/api/auth/me'),
      headers: headers,
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return body['data'] as Map<String, dynamic>;
    }

    throw Exception(body['detail'] ?? 'Sesi tidak valid. Silakan login ulang.');
  }

  // -----------------------------------------------------------------------
  // PUT /api/auth/profile
  // -----------------------------------------------------------------------
  /// Update profil user yang sedang login (nama, usia, tinggi, berat, gender).
  /// Mengembalikan Map data user yang sudah diperbarui.
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    int? age,
    double? height,
    double? weight,
    String? gender,
  }) async {
    final headers = await _authHeaders;
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (age != null) body['age'] = age;
    if (height != null) body['height'] = height;
    if (weight != null) body['weight'] = weight;
    if (gender != null) body['gender'] = gender;

    final response = await http.put(
      Uri.parse('$_baseUrl/api/auth/profile'),
      headers: headers,
      body: jsonEncode(body),
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return responseBody['data'] as Map<String, dynamic>;
    }

    throw Exception(responseBody['detail'] ?? 'Gagal memperbarui profil. Coba lagi.');
  }

  // -----------------------------------------------------------------------
  // POST /api/auth/profile-picture
  // -----------------------------------------------------------------------
  Future<Map<String, dynamic>> uploadProfilePicture(File imageFile) async {
    final headers = await _authHeaders;
    final uri = Uri.parse('$_baseUrl/api/auth/profile-picture');
    
    final request = http.MultipartRequest('POST', uri);
    
    // We can't use application/json for multipart, so we keep only the token and ngrok header
    final multipartHeaders = {
      if (headers.containsKey('Authorization')) 'Authorization': headers['Authorization']!,
      if (headers.containsKey('ngrok-skip-browser-warning')) 'ngrok-skip-browser-warning': headers['ngrok-skip-browser-warning']!,
    };
    request.headers.addAll(multipartHeaders);
    
    final multipartFile = await http.MultipartFile.fromPath('file', imageFile.path);
    request.files.add(multipartFile);
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    
    if (response.statusCode == 200) {
      return responseBody['data'] as Map<String, dynamic>;
    }
    
    throw Exception(responseBody['detail'] ?? 'Gagal mengunggah foto profil. Coba lagi.');
  }

  // -----------------------------------------------------------------------
  // Logout
  // -----------------------------------------------------------------------
  /// Hapus token dari penyimpanan lokal.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyToken);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserName);
    await prefs.remove(AppConstants.keyUserEmail);
  }

  // -----------------------------------------------------------------------
  // Cek apakah user sudah login
  // -----------------------------------------------------------------------
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);
    return token != null && token.isNotEmpty;
  }

  /// Ambil token yang tersimpan.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyToken);
  }
}
