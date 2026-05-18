import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

/// Model data satu artikel edukasi dari backend PostureFit.
class EducationItem {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String category;
  final String source;
  final String publishedAt;
  final List<String> tips;
  final String directLink;

  const EducationItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.category,
    required this.source,
    required this.publishedAt,
    this.tips = const [],
    required this.directLink,
  });

  /// Factory dari JSON response backend (field: judul, ringkasan, gambar, dst.)
  factory EducationItem.fromJson(Map<String, dynamic> json) {
    // Tips bisa berupa List<dynamic> atau sudah String JSON
    List<String> parsedTips = [];
    final rawTips = json['tips'];
    if (rawTips is List) {
      parsedTips = rawTips.map((e) => e.toString()).toList();
    } else if (rawTips is String && rawTips.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawTips);
        if (decoded is List) {
          parsedTips = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        parsedTips = [rawTips];
      }
    }

    return EducationItem(
      id:          json['id']?.toString() ?? '',
      title:       json['judul']       ?? json['title']       ?? '',
      summary:     json['ringkasan']   ?? json['summary']     ?? '',
      imageUrl:    json['gambar']      ?? json['image_url']   ?? '',
      category:    json['kategori']    ?? json['category']    ?? 'umum',
      source:      json['sumber']      ?? json['source']      ?? 'Unknown',
      publishedAt: json['updated_at']  ?? json['published_at'] ?? '',
      tips:        parsedTips,
      directLink:  json['link_direct'] ?? json['link']        ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────

class EducationController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────────────
  final RxList<EducationItem>  educationList    = <EducationItem>[].obs;
  final RxBool                 isLoading        = false.obs;
  final RxString               errorMessage     = ''.obs;
  final RxString               selectedCategory = ''.obs; // '' = semua kategori
  final RxInt                  totalArticles    = 0.obs;

  // ── Config ─────────────────────────────────────────────────────────────────
  /// Ganti sesuai environment:
  /// Web / Chrome dev  → http://localhost:8000
  /// Emulator Android  → http://10.0.2.2:8000
  /// Perangkat fisik   → http://<IP_LAPTOP>:8000
  /// Produksi          → https://api.posturfit.com
  static const String _baseUrl = 'http://10.0.2.2:8000';

  static const int _pageLimit = 20;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchEducation();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Ambil daftar artikel dari backend.
  /// [kategori] opsional — kosong berarti semua kategori.
  Future<void> fetchEducation({String? kategori}) async {
    isLoading.value   = true;
    errorMessage.value = '';

    // Simpan kategori yang dipilih
    if (kategori != null) selectedCategory.value = kategori;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Bangun URL dengan query params
      final queryParams = <String, String>{
        'limit': _pageLimit.toString(),
        'offset': '0',
      };
      if (selectedCategory.value.isNotEmpty) {
        queryParams['kategori'] = selectedCategory.value;
      }

      final uri = Uri.parse('$_baseUrl/api/education')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;

        // Response: { status, message, data: { total, limit, offset, items: [...] } }
        final data = body['data'];

        List<dynamic> items = [];
        if (data is Map && data.containsKey('items')) {
          // Format baru: { total, limit, offset, items }
          items = data['items'] as List<dynamic>? ?? [];
          totalArticles.value = (data['total'] as num?)?.toInt() ?? items.length;
        } else if (data is List) {
          // Fallback: response lama berupa list langsung
          items = data;
          totalArticles.value = items.length;
        }

        educationList.assignAll(
          items.map((e) => EducationItem.fromJson(e as Map<String, dynamic>)),
        );

        // Jika server mengembalikan list kosong, tampilkan dummy agar UI tidak blank
        if (educationList.isEmpty) {
          _loadDummyData();
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        _loadDummyData();
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat data: $e';
      _loadDummyData();
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter berdasarkan kategori tertentu.
  void filterByCategory(String kategori) {
    fetchEducation(kategori: kategori);
  }

  /// Reset filter dan tampilkan semua artikel.
  void clearFilter() {
    selectedCategory.value = '';
    fetchEducation();
  }

  // ── Private ────────────────────────────────────────────────────────────────

  /// Data placeholder jika server tidak bisa dihubungi.
  void _loadDummyData() {
    educationList.assignAll([
      const EducationItem(
        id:          'dummy-1',
        title:       'Pentingnya Postur Saat Bekerja',
        summary:     'Menjaga postur tubuh saat duduk di depan komputer sangat penting untuk mencegah nyeri punggung dan leher yang kronis.',
        imageUrl:    'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
        category:    'postur',
        source:      'PostureFit',
        publishedAt: '2026-05-11',
        tips:        ['Duduk tegak dengan punggung menempel sandaran', 'Layar sejajar dengan mata', 'Istirahat setiap 45 menit'],
        directLink:  '',
      ),
      const EducationItem(
        id:          'dummy-2',
        title:       'Tips Stretching Ringan Setiap Hari',
        summary:     'Lakukan peregangan setiap 2 jam sekali untuk menjaga fleksibilitas otot dan melancarkan sirkulasi darah.',
        imageUrl:    'https://images.unsplash.com/photo-1518622358185-e211d6c54209?w=800',
        category:    'kebugaran',
        source:      'PostureFit',
        publishedAt: '2026-05-10',
        tips:        ['Regangkan leher perlahan ke kiri dan kanan', 'Putar bahu 10 kali ke depan dan belakang'],
        directLink:  '',
      ),
      const EducationItem(
        id:          'dummy-3',
        title:       'Pentingnya Hidrasi untuk Performa Olahraga',
        summary:     'Tubuh yang terhidrasi baik mampu mempertahankan performa otot 20% lebih lama dibandingkan kondisi dehidrasi.',
        imageUrl:    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=800',
        category:    'hidrasi',
        source:      'PostureFit',
        publishedAt: '2026-05-09',
        tips:        ['Minum 250ml air setiap 30 menit saat berolahraga', 'Perhatikan warna urin sebagai indikator hidrasi'],
        directLink:  '',
      ),
    ]);
    totalArticles.value = educationList.length;
  }
}
