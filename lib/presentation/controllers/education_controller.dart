import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Model data edukasi yang diisi dari scraper (MongoDB/JSON).
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

  /// Factory dari JSON response
  factory EducationItem.fromJson(Map<String, dynamic> json) {
    return EducationItem(
      id: json['id']?.toString() ?? '',
      title: json['judul'] ?? json['title'] ?? '',
      summary: json['ringkasan'] ?? json['summary'] ?? json['description'] ?? '',
      imageUrl: json['gambar'] ?? json['image_url'] ?? '',
      category: json['kategori'] ?? 'umum',
      source: json['sumber'] ?? 'Unknown',
      publishedAt: json['updated_at'] ?? '',
      tips: List<String>.from(json['tips'] ?? []),
      directLink: json['link_direct'] ?? '',
    );
  }
}

class EducationController extends GetxController {
  final RxList<EducationItem> educationList = <EducationItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // URL data edukasi (bisa dari GitHub Raw JSON atau API Server)
  // Contoh: 'https://raw.githubusercontent.com/USER/REPO/main/data_edukasi.json'
  static const String _dataSourceUrl = ''; 

  @override
  void onInit() {
    super.onInit();
    fetchEducation();
  }

  /// Fetch daftar edukasi.
  Future<void> fetchEducation() async {
    if (_dataSourceUrl.isEmpty) {
      // Jika URL kosong, kita bisa isi dengan data dummy agar UI tidak kosong melulu
      _loadDummyData();
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await http.get(Uri.parse(_dataSourceUrl));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        educationList.assignAll(data.map((e) => EducationItem.fromJson(e)));
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDummyData() {
    // Placeholder jika URL belum dikonfigurasi
    educationList.assignAll([
      const EducationItem(
        id: '1',
        title: 'Pentingnya Postur Saat Bekerja',
        summary: 'Menjaga postur tubuh saat duduk di depan komputer sangat penting untuk mencegah nyeri punggung.',
        imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
        category: 'postur',
        source: 'Healthline',
        publishedAt: '2026-05-11',
        directLink: '',
      ),
      const EducationItem(
        id: '2',
        title: 'Tips Stretching Ringan',
        summary: 'Lakukan peregangan setiap 2 jam sekali untuk menjaga fleksibilitas otot Anda.',
        imageUrl: 'https://images.unsplash.com/photo-1518622358185-e211d6c54209',
        category: 'fleksibilitas',
        source: 'Verywell Fit',
        publishedAt: '2026-05-11',
        directLink: '',
      ),
    ]);
  }
}
