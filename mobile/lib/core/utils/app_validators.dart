class AppValidators {
  AppValidators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email wajib diisi';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
    if (value != password) return 'Password tidak sama';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) return 'Nama wajib diisi';
    if (value.length < 2) return 'Nama terlalu pendek';
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName wajib diisi';
    return null;
  }
}
