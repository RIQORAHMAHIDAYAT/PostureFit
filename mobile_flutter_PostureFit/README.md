# PostureFit - Indonesia Atletis Health App 🏃‍♂️

PostureFit adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu pengguna menganalisis, memantau, dan meningkatkan postur tubuh mereka melalui teknologi AI dan fitur workout planning yang terintegrasi.

## 📋 Daftar Isi

- [Fitur Utama](#fitur-utama)
- [Prasyarat](#prasyarat)
- [Setup & Instalasi](#setup--instalasi)
- [Struktur Proyek](#struktur-proyek)
- [Deskripsi Fitur](#deskripsi-fitur)
- [Teknologi yang Digunakan](#teknologi-yang-digunakan)
- [Panduan Pengembangan](#panduan-pengembangan)
- [Struktur Direktori](#struktur-direktori)

---

## 🎯 Fitur Utama

1. **Analisis Postur** - Menangkap dan menganalisis postur tubuh menggunakan kamera
2. **Hasil Analisis Real-time** - Menampilkan hasil deteksi postur dengan detail
3. **Rencana Workout** - Program latihan yang dipersonalisasi berdasarkan analisis postur
4. **Edukasi** - Konten edukatif tentang postur yang benar dan kesehatan
5. **Profil Pengguna** - Manajemen data pengguna dan history analisis
6. **Autentikasi** - Sistem login dan registrasi pengguna
7. **Mode Gelap/Terang** - Dark mode dan light mode support

---

## ✅ Prasyarat

Sebelum memulai, pastikan Anda telah menginstall:

- **Flutter SDK**: versi 3.0.0 atau lebih tinggi ([Download](https://flutter.dev/docs/get-started/install))
- **Dart SDK**: sudah disertakan dengan Flutter
- **Android Studio** atau **Xcode** (untuk emulator/device)
- **Git** (untuk version control)
- **IDE**: VS Code, Android Studio, atau IntelliJ IDEA

Verifikasi instalasi:
```bash
flutter --version
dart --version
```

---

## 🚀 Setup & Instalasi

### Step 1: Clone Repository
```bash
cd path/to/your/projects
git clone https://github.com/RIQORAHMAHIDAYAT/PostureFit.git
cd Posturefit
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Configure Platform-Specific Requirements

#### Android Setup
```bash
cd android
./gradlew clean
cd ..
```

#### iOS Setup (Mac only)
```bash
cd ios
pod install
cd ..
```

### Step 4: Generate Code (jika diperlukan)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 5: Jalankan Aplikasi

**Untuk Android Emulator:**
```bash
flutter emulators --launch <emulator_name>
flutter run
```

**Untuk Physical Device (USB Debugging enabled):**
```bash
flutter run
```

**Untuk iOS Simulator (Mac):**
```bash
open -a Simulator
flutter run
```

**Jalankan dengan mode release:**
```bash
flutter run --release
```

---

## 📁 Struktur Proyek

```
posturefit/
├── lib/
│   ├── main.dart                          # Entry point aplikasi
│   ├── bindings/                          # GetX Dependency Injection
│   │   ├── login_binding.dart
│   │   ├── home_binding.dart
│   │   ├── scan_binding.dart
│   │   ├── analysis_result_binding.dart
│   │   ├── workout_plan_binding.dart
│   │   ├── education_binding.dart
│   │   ├── profile_binding.dart
│   │   └── ...
│   ├── core/                              # Core utilities & constants
│   │   ├── constants/                     # App constants
│   │   ├── theme/                         # Theme & styling
│   │   └── utils/                         # Utility functions
│   ├── data/                              # Data layer (API, local storage)
│   ├── domain/                            # Domain layer (business logic)
│   ├── presentation/                      # Presentation layer (UI)
│   │   ├── pages/                         # Halaman aplikasi
│   │   │   ├── login/
│   │   │   ├── register/
│   │   │   ├── home/
│   │   │   ├── scan/
│   │   │   ├── analysis_result/
│   │   │   ├── workout_plan/
│   │   │   ├── education/
│   │   │   ├── profile/
│   │   │   └── main/
│   │   ├── controllers/                   # GetX Controllers
│   │   └── widgets/                       # Reusable widgets
│   └── routes/                            # Navigation & routing
├── assets/                                # Images, icons, fonts
│   ├── images/
│   └── icons/
├── android/                               # Android native code
├── ios/                                   # iOS native code
├── test/                                  # Unit & widget tests
├── web/                                   # Web platform
├── windows/                               # Windows platform
├── linux/                                 # Linux platform
├── macos/                                 # macOS platform
├── pubspec.yaml                           # Dependencies configuration
├── pubspec.lock                           # Lock file untuk reproducible builds
└── analysis_options.yaml                  # Linting rules
```

---

## 📱 Deskripsi Fitur

### 1. **Autentikasi (Login & Register)**
- Sistem login dengan validasi
- Registrasi akun baru
- Input validation dan error handling
- Password security

### 2. **Home Page**
- Dashboard utama aplikasi
- Navigation ke fitur lain
- Quick access menu

### 3. **Fitur Scan Postur**
- Akses kamera untuk capture postur
- Real-time posture detection
- Visual feedback untuk postur analysis

### 4. **Hasil Analisis (Analysis Result)**
- Tampilan detail hasil scan
- Metrik postur lengkap
- Historical data tracking
- Rekomendasi perbaikan

### 5. **Rencana Workout**
- Program latihan yang dipersonalisasi
- Exercise guidelines dengan deskripsi
- Progress tracking
- Integrasi dengan hasil analisis postur

### 6. **Edukasi**
- Konten edukatif tentang postur
- Tips kesehatan
- Video tutorials (jika ada)
- Best practices

### 7. **Profil Pengguna**
- Edit data pribadi
- Settings aplikasi
- History analisis
- Logout functionality

---

## 🛠️ Teknologi yang Digunakan

### Frontend Framework
- **Flutter**: 3.0.0+ - Cross-platform mobile framework
- **Dart**: 3.0.0+ - Programming language

### State Management
- **GetX**: ^4.6.6 - Powerful state management & navigation

### UI & Design
- **google_fonts**: ^8.1.0 - Google Fonts integration
- **flutter_svg**: ^2.0.9 - SVG support
- **iconsax**: ^0.0.8 - Icon library
- **percent_indicator**: ^4.2.3 - Progress indicators
- **cupertino_icons**: ^1.0.6 - iOS style icons

### Data & Storage
- **shared_preferences**: ^2.3.5 - Local data persistence

### Development Tools
- **flutter_lints**: ^6.0.0 - Linting rules
- **flutter_test**: - Widget & unit testing

### Architecture
- **Clean Architecture** - Separation of concerns
  - Presentation Layer (UI)
  - Domain Layer (Business Logic)
  - Data Layer (API & Local Storage)

---

## 💻 Panduan Pengembangan

### Running in Development Mode
```bash
flutter run -d <device-id>
flutter run -d all  # Run di semua devices
```

### Hot Reload & Hot Restart
```bash
r             # Hot reload (faster)
R             # Full restart
q             # Quit
```

### Build APK (Android)
```bash
flutter build apk --release
flutter build apk --split-per-abi  # Split per ABI untuk ukuran lebih kecil
```

### Build App Bundle (Android)
```bash
flutter build appbundle --release
```

### Build IPA (iOS)
```bash
flutter build ipa --release
```

### Running Tests
```bash
flutter test
flutter test --coverage
```

### Check Code Quality
```bash
flutter analyze
```

### Format Code
```bash
dart format lib/
flutter format lib/
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📂 Struktur Direktori Lengkap

```
lib/
├── bindings/                              # GetX Bindings untuk DI
│   ├── analysis_result_binding.dart
│   ├── education_binding.dart
│   ├── home_binding.dart
│   ├── login_binding.dart
│   ├── main_binding.dart
│   ├── profile_binding.dart
│   ├── register_binding.dart
│   ├── result_binding.dart
│   ├── scan_binding.dart
│   └── workout_plan_binding.dart
│
├── core/                                  # Core utilities
│   ├── constants/                         # Konstanta aplikasi
│   ├── theme/                             # Tema & styling
│   └── utils/                             # Utility functions
│
├── data/                                  # Data Layer
│   ├── datasources/
│   ├── models/
│   ├── repositories/
│   └── services/
│
├── domain/                                # Domain Layer
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── presentation/                          # Presentation Layer
│   ├── controllers/
│   │   ├── analysis_result_controller.dart
│   │   ├── education_controller.dart
│   │   ├── home_controller.dart
│   │   ├── login_controller.dart
│   │   ├── main_controller.dart
│   │   ├── profile_controller.dart
│   │   ├── register_controller.dart
│   │   ├── result_controller.dart
│   │   ├── scan_controller.dart
│   │   ├── theme_controller.dart
│   │   └── workout_plan_controller.dart
│   │
│   ├── pages/
│   │   ├── analysis_result/
│   │   ├── education/
│   │   ├── home/
│   │   ├── login/
│   │   ├── main/
│   │   ├── profile/
│   │   ├── register/
│   │   ├── scan/
│   │   └── workout_plan/
│   │
│   └── widgets/                           # Reusable widgets
│
├── routes/                                # Navigation
│   ├── app_pages.dart
│   └── app_routes.dart
│
└── main.dart                              # App entry point

assets/
├── images/                                # Image assets
└── icons/                                 # Icon assets

test/                                      # Unit & Widget Tests
```

---

## 🔧 Troubleshooting

### Masalah Umum

**1. Build Error:**
```bash
flutter clean
flutter pub get
flutter run
```

**2. Dependency Conflict:**
```bash
flutter pub upgrade
flutter pub get
```

**3. Android Build Issues:**
```bash
cd android
./gradlew clean
cd ..
flutter run
```

**4. iOS Pod Issues (Mac):**
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
```

**5. Hot Reload Tidak Bekerja:**
- Lakukan full restart: `R`
- Atau jalankan ulang: `flutter run`

---

## 📚 Resources & References

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [GetX Documentation](https://github.com/jonataslaw/getx/wiki)
- [Clean Architecture](https://resocoder.com/flutter-clean-architecture)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)

---

## 👥 Tim Pengembang

PostureFit dikembangkan sebagai proyek Capstone tahun 2026.

---

## 📄 Lisensi

Proyek ini dilisensi di bawah [Lisensi Anda] - lihat file LICENSE untuk detail.

---

## 🤝 Kontribusi

Untuk berkontribusi pada proyek ini:

1. Fork repository
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buka Pull Request

---

## 📧 Kontak & Support

Untuk pertanyaan atau dukungan, silakan hubungi tim pengembang melalui:
- Email: [contact@posturefit.com]
- GitHub Issues: [repository-issues-url]

---

**Dibuat dengan ❤️ untuk kesehatan postur Indonesia**
