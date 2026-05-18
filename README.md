# PostureFit - Integrated AI Health & Posture Tracker 🏃‍♂️

PostureFit adalah platform pemantauan postur tubuh berbasis Kecerdasan Buatan (AI) yang terintegrasi dengan Rencana Latihan (Workout Planning). Proyek ini dirancang menggunakan arsitektur **Monorepo** untuk menyatukan seluruh subsistem (Mobile & Backend) dalam satu repository demi memudahkan kolaborasi tim dan sinkronisasi kode.

---

## 🏗️ Arsitektur Proyek (Monorepo)

Repository ini disusun dengan struktur **Monorepo Terpisah (Opsi A)** yang sangat rapi dan profesional:

```text
posturefit/
├── mobile_flutter_PostureFit/  # Aplikasi Mobile Client (Flutter)
│   ├── lib/                    # Logika bisnis & Presentasi (GetX)
│   ├── android/                # Native Android code
│   ├── ios/                    # Native iOS code
│   ├── assets/                 # Gambar, Icon, & Font
│   ├── pubspec.yaml            # Konfigurasi dependensi Flutter
│   └── ...
├── PostureFit_backend/         # Server API & Scraping Service
│   ├── src/                    # Source code backend
│   ├── .env.example            # Template Environment Variables
│   └── ...
├── docs/                       # Folder dokumentasi proyek
│   └── panduan_kolaborasi_git.md
├── .gitignore                  # Gitignore global untuk Monorepo
└── README.md                   # README utama ini
```

---

## 🛠️ Teknologi & Prasyarat

### 📱 Mobile Client (Flutter)
* **Framework**: Flutter SDK >= 3.0.0 (Dart SDK >= 3.0.0)
* **State Management**: GetX (^4.6.6)
* **Prerequisites**: Android Studio (Android SDK) / Xcode (untuk macOS/iOS), VS Code.

### 🔌 Backend API & Database
* **Database**: MongoDB Atlas (Cloud Database)
* **Runtime**: Node.js >= 18.x (atau Python >= 3.10)

---

## 🚀 Setup & Cara Menjalankan Aplikasi

### 1. Clone Repository & Masuk ke Folder
```bash
git clone https://github.com/RIQORAHMAHIDAYAT/PostureFit.git
cd Posturefit
```

### 2. Konfigurasi & Jalankan Mobile App (Flutter)
Untuk mengerjakan bagian mobile, masuk ke subdirektori `mobile_flutter_PostureFit`:
```bash
# Pindah ke folder Flutter
cd mobile_flutter_PostureFit

# Ambil dependencies
flutter pub get

# Jalankan aplikasi (pastikan Emulator/Device sudah aktif)
flutter run
```

### 3. Konfigurasi & Jalankan Backend API
Untuk menjalankan backend (setelah folder `PostureFit_backend` dibuat oleh rekan tim Anda):
```bash
# Pindah ke folder Backend
cd PostureFit_backend

# Install dependencies (Node.js)
npm install

# Jalankan server dalam mode development
npm run dev
```

---

## 📂 Struktur Direktori Mobile Client

Di dalam folder [mobile_flutter_PostureFit](file:///d:/SEMESTER%206%202026/CAPTONE%202026/Projeck%20Captone/Posturefit/mobile_flutter_PostureFit), kode disusun menggunakan **Clean Architecture** & **GetX Pattern**:

```text
mobile_flutter_PostureFit/
├── lib/
│   ├── bindings/       # Dependency Injection via GetX Bindings
│   ├── core/           # Tema, Konstanta, & Utilities global
│   ├── data/           # Layer Data (API providers, repositories impl, local storage)
│   ├── domain/         # Layer Domain (Entities, Usecases, & Interface Repository)
│   ├── presentation/   # Layer UI (Controllers, Pages/Views, & Reusable Widgets)
│   ├── routes/         # Manajemen Routing & Navigasi Halaman
│   └── main.dart       # Entrypoint Utama Aplikasi
```

---

## 🌿 Alur Kolaborasi Tim (Git & Branching)

Kami menerapkan **Git Flow Sederhana** untuk menghindari konflik kode dan menjaga kualitas branch utama (`main`):

1. **`main`**: Hanya untuk kode yang sudah 100% stabil dan siap diuji/dideploy.
2. **`development`**: Branch utama untuk integrasi fitur harian dari Mobile maupun Backend.
3. **`feat/...`** (Fitur Baru) & **`fix/...`** (Perbaikan Bug): Branch sementara untuk bekerja secara lokal.

### Cara Berkontribusi:
1. Tarik pembaruan terbaru:
   ```bash
   git checkout development
   git pull origin development
   ```
2. Buat branch fitur baru:
   ```bash
   git checkout -b feat/mobile-nama-fitur
   ```
3. Commit secara terstruktur dengan format **Conventional Commits**:
   * `feat(mobile): add dss health status analysis page with GetX`
   * `fix(mobile): resolve bottom navigation bar black rendering issue`
4. Push branch ke GitHub dan ajukan **Pull Request (PR)** ke branch `development` untuk ditinjau oleh rekan tim.

---

## 👥 Tim Pengembang

Platform **PostureFit** dikembangkan sebagai proyek Capstone tahun 2026.

---

*Dibuat dengan ❤️ untuk meningkatkan kesehatan postur tubuh masyarakat Indonesia.*
