"""
workout_recommender.py — Menghasilkan rencana latihan personal berdasarkan:
    - kategori_tubuh: hasil SAW engine (Obesitas / Skinnyfat / Kurus / Normal)
    - postur_label  : hasil klasifikasi best.pt (standing / bending / sitting / dll.)
    - lingkungan    : preferensi lingkungan latihan (Rumah / Gym / Calisthenics)

Setiap WorkoutItem berisi:
    nama_latihan, target_otot, set_reps, kalori_estimasi (kcal/sesi), icon_key
"""

from typing import List, Dict, Any

# ---------------------------------------------------------------------------
# Data types
# ---------------------------------------------------------------------------

def _item(nama: str, target: str, set_reps: str, kalori: int, icon: str = "fitness_center") -> Dict[str, Any]:
    return {
        "nama_latihan": nama,
        "target_otot": target,
        "set_reps": set_reps,
        "kalori_estimasi": kalori,
        "icon_key": icon,
    }


# ---------------------------------------------------------------------------
# CATALOG: Latihan Utama per (kategori, lingkungan)
# ---------------------------------------------------------------------------

MAIN_WORKOUT: Dict[str, Dict[str, Dict[str, Any]]] = {
    "Kurus": {
        "Rumah": _item("Wall Squats", "Paha & Betis", "4 Set × 12 Rep", 80, "sports_gymnastics"),
        "Gym":   _item("Barbell Squat", "Paha, Gluteus & Core", "5 Set × 8 Rep", 140, "fitness_center"),
        "Calisthenics": _item("Pistol Squat", "Paha Tunggal & Keseimbangan", "4 Set × 6 Rep", 90, "sports_gymnastics"),
    },
    "Normal": {
        "Rumah": _item("Push-Up Circuit", "Dada, Trisep & Core", "3 Set × 15 Rep", 100, "fitness_center"),
        "Gym":   _item("Bench Press", "Dada & Trisep", "4 Set × 10 Rep", 150, "fitness_center"),
        "Calisthenics": _item("Muscle-Up", "Seluruh Tubuh Bagian Atas", "3 Set × 5 Rep", 120, "sports_gymnastics"),
    },
    "Skinnyfat": {
        "Rumah": _item("Bodyweight Circuit (Squat+Push-Up+Plank)", "Full Body Rekomposisi", "3 Set × 12 Rep", 110, "accessibility_new"),
        "Gym":   _item("Dumbbell Full Body", "Rekomposisi Tubuh", "4 Set × 12 Rep", 160, "fitness_center"),
        "Calisthenics": _item("Ring Dips", "Dada, Trisep & Stabilitas", "3 Set × 8 Rep", 100, "sports_gymnastics"),
    },
    "Obesitas": {
        "Rumah": _item("Wall Squats Low Impact", "Paha & Betis (Aman Sendi)", "2 Set × 10 Rep", 60, "sports_gymnastics"),
        "Gym":   _item("Elliptical Cardio", "Kardiovaskular & Pembakaran Lemak", "30 Menit", 280, "directions_run"),
        "Calisthenics": _item("Chair Dips", "Trisep & Bahu", "2 Set × 8 Rep", 50, "fitness_center"),
    },
}

# ---------------------------------------------------------------------------
# CATALOG: Latihan Tambahan per (kategori, lingkungan)
# ---------------------------------------------------------------------------

SUPPLEMENTARY_WORKOUT: Dict[str, Dict[str, List[Dict[str, Any]]]] = {
    "Kurus": {
        "Rumah": [
            _item("Diamond Push-Up", "Trisep & Dada", "3 Set × 10 Rep", 60, "fitness_center"),
            _item("Plank Hold", "Core & Stabilitas", "3 Set × 45 Detik", 40, "self_improvement"),
            _item("Cat-Cow Stretch", "Mobilitas Tulang Belakang", "2 Set × 60 Detik", 20, "accessibility_new"),
            _item("Glute Bridge", "Gluteus & Hamstring", "3 Set × 15 Rep", 50, "sports_gymnastics"),
        ],
        "Gym": [
            _item("Dumbbell Row", "Punggung & Bisep", "4 Set × 10 Rep", 90, "fitness_center"),
            _item("Leg Press", "Paha & Betis", "4 Set × 12 Rep", 110, "sports_gymnastics"),
            _item("Cable Fly", "Dada Tengah", "3 Set × 12 Rep", 70, "fitness_center"),
            _item("Lat Pulldown", "Punggung Atas & Bisep", "3 Set × 10 Rep", 80, "self_improvement"),
        ],
        "Calisthenics": [
            _item("Pull-Up", "Punggung & Bisep", "4 Set × 6 Rep", 90, "fitness_center"),
            _item("Dip", "Trisep & Dada", "3 Set × 8 Rep", 70, "sports_gymnastics"),
            _item("Hollow Hold", "Core Stability", "3 Set × 30 Detik", 30, "self_improvement"),
            _item("L-Sit", "Core & Hip Flexor", "3 Set × 15 Detik", 40, "accessibility_new"),
        ],
    },
    "Normal": {
        "Rumah": [
            _item("Diamond Push-Up", "Trisep & Dada", "3 Set × 12 Rep", 65, "fitness_center"),
            _item("Plank Shoulder Tap", "Core & Bahu", "3 Set × 20 Rep", 45, "self_improvement"),
            _item("Cat-Cow Stretch", "Mobilitas Tulang Belakang", "2 Set × 60 Detik", 20, "accessibility_new"),
            _item("Glute Bridge", "Gluteus & Hamstring", "3 Set × 15 Rep", 50, "sports_gymnastics"),
        ],
        "Gym": [
            _item("Incline Dumbbell Press", "Dada Atas", "4 Set × 10 Rep", 100, "fitness_center"),
            _item("Romanian Deadlift", "Hamstring & Punggung Bawah", "4 Set × 8 Rep", 130, "sports_gymnastics"),
            _item("Cable Crunch", "Core & Perut", "3 Set × 15 Rep", 60, "self_improvement"),
            _item("Shoulder Press", "Bahu & Trisep", "3 Set × 10 Rep", 85, "accessibility_new"),
        ],
        "Calisthenics": [
            _item("Archer Push-Up", "Dada & Trisep Unilateral", "3 Set × 6 Rep", 80, "fitness_center"),
            _item("Australian Pull-Up", "Punggung Tengah", "3 Set × 10 Rep", 70, "sports_gymnastics"),
            _item("Plank Shoulder Tap", "Core & Bahu", "3 Set × 20 Rep", 45, "self_improvement"),
            _item("Jump Squat", "Paha & Kardio Eksplosif", "3 Set × 10 Rep", 90, "directions_run"),
        ],
    },
    "Skinnyfat": {
        "Rumah": [
            _item("Slow Push-Up", "Dada & Kontrol Otot", "3 Set × 8 Rep", 55, "fitness_center"),
            _item("Plank Hold", "Core & Postur", "3 Set × 45 Detik", 35, "self_improvement"),
            _item("Hip Hinge", "Hamstring & Punggung Bawah", "3 Set × 12 Rep", 45, "sports_gymnastics"),
            _item("Band Pull-Apart", "Bahu & Punggung Atas", "3 Set × 15 Rep", 30, "accessibility_new"),
        ],
        "Gym": [
            _item("Cable Row", "Punggung Tengah", "4 Set × 10 Rep", 85, "fitness_center"),
            _item("Goblet Squat", "Paha & Core", "4 Set × 12 Rep", 95, "sports_gymnastics"),
            _item("Dumbbell Curl", "Bisep", "3 Set × 12 Rep", 50, "fitness_center"),
            _item("Tricep Pushdown", "Trisep", "3 Set × 12 Rep", 50, "self_improvement"),
        ],
        "Calisthenics": [
            _item("Negative Pull-Up", "Punggung & Bisep (Eksentrik)", "3 Set × 5 Rep", 70, "fitness_center"),
            _item("Pike Push-Up", "Bahu & Trisep", "3 Set × 8 Rep", 60, "sports_gymnastics"),
            _item("Hollow Body Hold", "Core", "3 Set × 30 Detik", 30, "self_improvement"),
            _item("Step-Up", "Paha & Gluteus", "3 Set × 10 Rep", 65, "directions_run"),
        ],
    },
    "Obesitas": {
        "Rumah": [
            _item("Seated Marching", "Kardio Ringan & Hip Flexor", "3 Set × 30 Detik", 40, "directions_run"),
            _item("Wall Push-Up", "Dada & Trisep (Aman Sendi)", "2 Set × 10 Rep", 35, "fitness_center"),
            _item("Cat-Cow Stretch", "Mobilitas Tulang Belakang", "3 Set × 60 Detik", 20, "accessibility_new"),
            _item("Seated Leg Raise", "Core & Hip Flexor", "2 Set × 10 Rep", 30, "self_improvement"),
        ],
        "Gym": [
            _item("Seated Row Machine", "Punggung Tengah", "3 Set × 12 Rep", 70, "fitness_center"),
            _item("Leg Press (Ringan)", "Paha & Gluteus", "3 Set × 12 Rep", 80, "sports_gymnastics"),
            _item("Cable Pulldown", "Punggung Atas & Bisep", "3 Set × 10 Rep", 65, "self_improvement"),
            _item("Standing Calf Raise", "Betis", "3 Set × 15 Rep", 40, "accessibility_new"),
        ],
        "Calisthenics": [
            _item("Wall Push-Up", "Dada & Trisep", "3 Set × 12 Rep", 40, "fitness_center"),
            _item("Seated Leg Raise", "Core", "3 Set × 10 Rep", 35, "self_improvement"),
            _item("Neck & Shoulder Stretch", "Leher, Bahu & Punggung Atas", "3 Set × 60 Detik", 15, "accessibility_new"),
            _item("Ankle Circles", "Mobilitas Pergelangan Kaki", "2 Set × 30 Detik", 10, "sports_gymnastics"),
        ],
    },
}

# ---------------------------------------------------------------------------
# POSTUR ADJUSTMENT: Tambahan khusus jika postur bermasalah
# ---------------------------------------------------------------------------
# Jika best.pt mendeteksi posisi bukan "standing" (bending/sitting/squatting/lying),
# kita tambahkan catatan dan workout korektif di bagian paling atas.

POSTUR_NOTES: Dict[str, str] = {
    "standing": "",
    "bending":  "⚠️ Terdeteksi kebiasaan membungkuk. Tambahkan latihan penguatan punggung atas dan peregangan dada.",
    "sitting":  "⚠️ Postur duduk terlalu lama terdeteksi. Prioritaskan peregangan hip flexor dan penguatan glute.",
    "squatting": "⚠️ Posisi jongkok terdeteksi. Perhatikan keseimbangan dan kekuatan betis saat berlatih.",
    "lying":    "⚠️ Posisi rebah terdeteksi saat scan. Pastikan Anda berdiri tegak saat scan postur berikutnya.",
}

POSTUR_CORRECTIVE: Dict[str, List[Dict[str, Any]]] = {
    "bending": [
        _item("Face Pull", "Punggung Atas & Bahu Posterior", "3 Set × 15 Rep", 40, "fitness_center"),
        _item("Chest Doorway Stretch", "Pektoralis & Bahu Anterior", "3 Set × 60 Detik", 15, "accessibility_new"),
        _item("Superman Hold", "Erector Spinae & Gluteus", "3 Set × 10 Rep", 35, "self_improvement"),
    ],
    "sitting": [
        _item("Hip Flexor Lunge Stretch", "Psoas & Hip Flexor", "3 Set × 60 Detik", 20, "accessibility_new"),
        _item("Glute Bridge", "Gluteus & Hamstring", "3 Set × 15 Rep", 50, "sports_gymnastics"),
        _item("Cat-Cow Stretch", "Mobilitas Tulang Belakang Penuh", "3 Set × 60 Detik", 20, "accessibility_new"),
    ],
    "squatting": [
        _item("Ankle Mobility Drill", "Pergelangan Kaki & Betis", "2 Set × 60 Detik", 15, "directions_run"),
        _item("Goblet Squat Corrective", "Paha & Core (Form Fix)", "2 Set × 10 Rep", 50, "sports_gymnastics"),
    ],
}


# ---------------------------------------------------------------------------
# Main function
# ---------------------------------------------------------------------------

def generate_workout_plan(
    kategori_tubuh: str,
    postur_label: str,
    lingkungan: str = "Rumah",
    durasi_target_menit: int = 35,
) -> Dict[str, Any]:
    """
    Menghasilkan rencana workout personal.

    Args:
        kategori_tubuh:       Hasil SAW engine (Obesitas/Normal/Kurus/Skinnyfat)
        postur_label:         Hasil best.pt (standing/bending/sitting/squatting/lying)
        lingkungan:           Preferensi latihan (Rumah/Gym/Calisthenics)
        durasi_target_menit:  Estimasi total durasi latihan

    Returns:
        Dict berisi latihan_utama, latihan_tambahan, koreksi_postur, ringkasan
    """
    import random

    # Normalize inputs
    kategori = _normalize_kategori(kategori_tubuh)
    lingkungan = lingkungan if lingkungan in ["Rumah", "Gym", "Calisthenics"] else "Rumah"
    postur = postur_label.lower() if postur_label else "standing"

    # Ambil pool latihan utama & tambahan
    main_pool = MAIN_WORKOUT.get(kategori, MAIN_WORKOUT["Normal"]).get(
        lingkungan, MAIN_WORKOUT["Normal"]["Rumah"]
    )
    supp_pool = SUPPLEMENTARY_WORKOUT.get(kategori, SUPPLEMENTARY_WORKOUT["Normal"]).get(
        lingkungan, SUPPLEMENTARY_WORKOUT["Normal"]["Rumah"]
    )

    # Randomisasi (Pseudo-AI behavior) agar tidak pernah sama persis 
    # (mengambil 3-4 latihan tambahan secara acak)
    main = main_pool if isinstance(main_pool, dict) else random.choice(supp_pool)
    
    # Ambil 3-4 latihan secara acak (jika pool cukup besar)
    num_supp = min(len(supp_pool), random.randint(3, 4))
    supp = random.sample(supp_pool, num_supp)

    # Posture corrective
    corrective = POSTUR_CORRECTIVE.get(postur, [])
    
    # Dynamic posture note (AI-like text generation)
    postur_note = POSTUR_NOTES.get(postur, "")
    if postur_note:
        postur_note += f" Rencana ini telah disesuaikan khusus untuk memperbaiki postur {postur} Anda."
    else:
        postur_note = f"Postur Anda terdeteksi normal (standing). Kami merancang set {lingkungan} ini khusus untuk memaksimalkan hasil pada tubuh {kategori} Anda."

    # Calculate estimated calories
    total_kalori = main.get("kalori_estimasi", 100) + sum(w.get("kalori_estimasi", 50) for w in supp) + sum(w.get("kalori_estimasi", 30) for w in corrective)

    return {
        "kategori_tubuh": kategori,
        "postur_label": postur,
        "lingkungan": lingkungan,
        "postur_catatan": postur_note,
        "latihan_utama": main,
        "latihan_tambahan": supp,
        "latihan_koreksi_postur": corrective,
        "estimasi_kalori_total": total_kalori,
        "estimasi_durasi_menit": durasi_target_menit,
    }


def _normalize_kategori(raw: str) -> str:
    """Normalize kategori string dari SAW / DB ke key yang konsisten."""
    mapping = {
        "obesitas": "Obesitas",
        "skinnyfat": "Skinnyfat",
        "skinny fat": "Skinnyfat",
        "kurus": "Kurus",
        "normal": "Normal",
        "gemuk": "Obesitas",   # fallback
    }
    return mapping.get(raw.lower().strip(), "Normal")
