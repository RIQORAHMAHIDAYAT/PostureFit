import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: Column(
        children: [
          _PrivacyAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingLG,
                AppDimensions.paddingLG,
                AppDimensions.paddingLG,
                AppDimensions.paddingXXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCard(context),
                  const SizedBox(height: AppDimensions.paddingLG),
                  ..._policySections(context),
                  const SizedBox(height: AppDimensions.paddingXL),
                  _FooterNote(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _policySections(BuildContext context) {
    final sections = [
      _PolicySection(
        icon: Icons.info_outline_rounded,
        iconColor: AppColors.primary,
        title: '1. Informasi yang Kami Kumpulkan',
        content:
            'PostureFit mengumpulkan beberapa jenis informasi untuk memberikan layanan terbaik kepada Anda:\n\n'
            '• Data Pribadi: Nama lengkap, alamat email, dan nomor telepon yang Anda berikan saat mendaftar.\n\n'
            '• Data Kesehatan & Fisik: Tinggi badan, berat badan, usia, jenis kelamin, lingkar perut, dan indeks massa tubuh (BMI) yang Anda masukkan secara sukarela.\n\n'
            '• Data Analisis Postur: Gambar atau hasil analisis postur tubuh yang diproses menggunakan teknologi Computer Vision.\n\n'
            '• Data Aktivitas: Riwayat workout, log aktivitas harian, dan progres kebugaran Anda di dalam aplikasi.',
      ),
      _PolicySection(
        icon: Icons.security_rounded,
        iconColor: AppColors.accent,
        title: '2. Bagaimana Kami Menggunakan Informasi Anda',
        content:
            'Informasi yang dikumpulkan digunakan untuk tujuan berikut:\n\n'
            '• Memberikan rekomendasi rencana latihan yang dipersonalisasi menggunakan metode SAW (Simple Additive Weighting).\n\n'
            '• Menganalisis postur tubuh Anda untuk menghasilkan saran kesehatan yang akurat.\n\n'
            '• Melacak perkembangan dan progres kebugaran Anda dari waktu ke waktu.\n\n'
            '• Mengirimkan notifikasi relevan terkait artikel edukasi kesehatan dan pengingat aktivitas.\n\n'
            '• Meningkatkan kualitas layanan dan fitur aplikasi PostureFit.',
      ),
      _PolicySection(
        icon: Icons.share_rounded,
        iconColor: AppColors.warning,
        title: '3. Berbagi Data dengan Pihak Ketiga',
        content:
            'PostureFit berkomitmen untuk tidak menjual atau menyewakan data pribadi Anda kepada pihak ketiga. Data Anda hanya dapat dibagikan dalam kondisi berikut:\n\n'
            '• Layanan infrastruktur (seperti penyedia server dan database) yang mendukung operasional aplikasi, dengan kewajiban kerahasiaan yang ketat.\n\n'
            '• Jika diwajibkan oleh hukum atau peraturan yang berlaku di wilayah Indonesia.\n\n'
            '• Dengan persetujuan eksplisit dari Anda terlebih dahulu.',
      ),
      _PolicySection(
        icon: Icons.camera_alt_rounded,
        iconColor: const Color(0xFF9B59B6),
        title: '4. Data Kamera & Gambar Postur',
        content:
            'Fitur analisis postur memerlukan akses kamera perangkat Anda. Harap diperhatikan:\n\n'
            '• Gambar yang diambil hanya diproses untuk keperluan analisis postur dan tidak disimpan secara permanen di server kami tanpa izin Anda.\n\n'
            '• Hasil analisis disimpan dalam akun Anda sebagai riwayat untuk memantau perkembangan.\n\n'
            '• Anda dapat menghapus riwayat scan kapan saja melalui pengaturan akun.',
      ),
      _PolicySection(
        icon: Icons.lock_rounded,
        iconColor: AppColors.success,
        title: '5. Keamanan Data',
        content:
            'Kami mengambil langkah-langkah teknis dan organisasi yang wajar untuk melindungi data Anda:\n\n'
            '• Password disimpan dalam bentuk terenkripsi (bcrypt hash) dan tidak dapat dibaca oleh siapa pun.\n\n'
            '• Semua komunikasi antara aplikasi dan server dienkripsi menggunakan protokol HTTPS.\n\n'
            '• Autentikasi menggunakan JSON Web Token (JWT) dengan masa berlaku terbatas untuk menjaga keamanan sesi.\n\n'
            '• Akses ke data pengguna dibatasi hanya untuk personel yang memerlukan akses tersebut.',
      ),
      _PolicySection(
        icon: Icons.manage_accounts_rounded,
        iconColor: AppColors.primary,
        title: '6. Hak-Hak Anda',
        content:
            'Sebagai pengguna PostureFit, Anda memiliki hak untuk:\n\n'
            '• Mengakses dan melihat data pribadi Anda melalui halaman Profil.\n\n'
            '• Memperbarui atau mengoreksi informasi pribadi Anda kapan saja.\n\n'
            '• Meminta penghapusan akun dan seluruh data terkait dengan menghubungi kami.\n\n'
            '• Menarik persetujuan penggunaan data Anda (dengan catatan beberapa fitur mungkin tidak dapat berfungsi).',
      ),
      _PolicySection(
        icon: Icons.child_care_rounded,
        iconColor: AppColors.warning,
        title: '7. Pengguna di Bawah Umur',
        content:
            'PostureFit tidak ditujukan untuk pengguna yang berusia di bawah 13 tahun. Kami tidak secara sengaja mengumpulkan data pribadi dari anak-anak. Jika Anda adalah orang tua dan yakin bahwa anak Anda telah memberikan informasi pribadi kepada kami, segera hubungi kami untuk menghapus data tersebut.',
      ),
      _PolicySection(
        icon: Icons.update_rounded,
        iconColor: AppColors.accent,
        title: '8. Perubahan Kebijakan Privasi',
        content:
            'Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Setiap perubahan yang signifikan akan diberitahukan melalui notifikasi di dalam aplikasi atau email yang terdaftar. Kami mendorong Anda untuk meninjau kebijakan ini secara berkala.\n\nTanggal terakhir diperbarui: 21 Juni 2025.',
      ),
      _PolicySection(
        icon: Icons.contact_support_rounded,
        iconColor: AppColors.error,
        title: '9. Hubungi Kami',
        content:
            'Jika Anda memiliki pertanyaan, kekhawatiran, atau permintaan terkait Kebijakan Privasi ini atau data pribadi Anda, silakan hubungi tim PostureFit:\n\n'
            '• Email: posturefit.official@gmail.com\n\n'
            '• Aplikasi: Melalui menu Bantuan di dalam aplikasi PostureFit\n\n'
            'Kami berkomitmen untuk merespons pertanyaan Anda dalam waktu 3–5 hari kerja.',
      ),
    ];

    return sections
        .map((s) => Column(children: [s, const SizedBox(height: AppDimensions.paddingMD)]))
        .toList();
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _PrivacyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top,
        AppDimensions.paddingLG,
        AppDimensions.paddingLG,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryAppBarGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: AppColors.primaryAppBarShadow,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingXS),
          Expanded(
            child: Text(
              'Kebijakan Privasi',
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

// ── Header Card ───────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final BuildContext ctx;
  const _HeaderCard(this.ctx);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF183B6B), Color(0xFF4A90D9)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.privacy_tip_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: AppDimensions.paddingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PostureFit',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Kebijakan Privasi',
                      style: AppTextStyles.captionStyle.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMD),
          Text(
            'Privasi Anda adalah prioritas kami. Kebijakan ini menjelaskan bagaimana PostureFit mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda.',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMD),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Berlaku sejak: 21 Juni 2025',
              style: AppTextStyles.captionStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _PolicySection extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _PolicySection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  State<_PolicySection> createState() => _PolicySectionState();
}

class _PolicySectionState extends State<_PolicySection>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _animCtrl;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: _expanded
                ? widget.iconColor.withValues(alpha: 0.3)
                : AppTheme.borderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _expanded
                  ? widget.iconColor.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: _expanded ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.paddingMD),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textPrimary(context),
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _expanded ? widget.iconColor : AppTheme.textSecondary(context),
                      size: 22,
                    ),
                  ),
                ],
              ),
              SizeTransition(
                sizeFactor: _expandAnim,
                child: Column(
                  children: [
                    const SizedBox(height: AppDimensions.paddingMD),
                    Divider(
                      color: widget.iconColor.withValues(alpha: 0.2),
                      height: 1,
                    ),
                    const SizedBox(height: AppDimensions.paddingMD),
                    Text(
                      widget.content,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textSecondary(context),
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Footer Note ───────────────────────────────────────────────────────────────

class _FooterNote extends StatelessWidget {
  final BuildContext ctx;
  const _FooterNote(this.ctx);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: AppDimensions.paddingSM),
          Expanded(
            child: Text(
              'Dengan menggunakan PostureFit, Anda menyetujui Kebijakan Privasi ini. Kami berkomitmen untuk menjaga kepercayaan Anda.',
              style: AppTextStyles.captionStyle.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
