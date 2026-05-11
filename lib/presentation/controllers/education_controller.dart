import 'package:get/get.dart';

/// Model data edukasi yang akan diisi dari API server via IP address.
/// Field [imageUrl] adalah URL gambar dari server (e.g. http://192.168.x.x:PORT/image.jpg).
class EducationItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl; // URL gambar dari server

  const EducationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  /// Factory dari JSON response server
  factory EducationItem.fromJson(Map<String, dynamic> json) {
    return EducationItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class EducationController extends GetxController {
  final RxList<EducationItem> educationList = <EducationItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // TODO: Ganti dengan IP server yang sebenarnya
  // Contoh: 'http://192.168.1.100:5000/api/education'
  static const String _apiBaseUrl = '';

  @override
  void onInit() {
    super.onInit();
    // Data akan kosong sampai API dikonfigurasi
    // fetchEducation(); // Uncomment setelah IP server dikonfigurasi
  }

  /// Dipanggil setelah IP server dikonfigurasi.
  /// Fetch daftar edukasi dari server.
  Future<void> fetchEducation() async {
    if (_apiBaseUrl.isEmpty) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // TODO: Implementasi HTTP request ke server
      // final response = await http.get(Uri.parse('$_apiBaseUrl/education'));
      // final List data = jsonDecode(response.body);
      // educationList.assignAll(data.map((e) => EducationItem.fromJson(e)));
    } catch (e) {
      errorMessage.value = 'Gagal memuat data: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
