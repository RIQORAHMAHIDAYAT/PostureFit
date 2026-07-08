"""
saw_engine.py — Simple Additive Weighting (SAW) method for personalized
workout recommendations.

The SAW method works as follows:
    1. Define criteria and their weights.
    2. Build a decision matrix from user metrics.
    3. Normalize the matrix (benefit = max, cost = min).
    4. Multiply each normalized value by its weight.
    5. Sum across criteria to get the final score per alternative.
    6. The alternative with the highest score wins.

Alternatives (body categories):
    - Obesitas
    - Skinnyfat
    - Kurus
    - Normal

Criteria (TANPA WSR — MediaPipe CV diintegrasikan nanti):
    - C1: BMI               (benefit → tinggi = cenderung Obesitas)
    - C2: WHtR              (benefit → tinggi = risiko metabolik tinggi)
    - C3: Lingkar Perut cm  (benefit → tinggi = cenderung Obesitas/Skinnyfat)
    - C4: Umur              (cost   → muda = kapasitas program lebih intens)

NOTE: Saat MediaPipe/model CV sudah siap, tambahkan kembali WSR sebagai
      kriteria C5 dengan bobot ~0.20 dan kurangi bobot kriteria lain.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple


# ---------------------------------------------------------------------------
# Weights — sum must equal 1.0
# ---------------------------------------------------------------------------
CRITERIA_WEIGHTS: Dict[str, float] = {
    "bmi":     0.30,   # C1: BMI
    "whtr":    0.25,   # C2: WHtR pinggang/tinggi
    "lingkar": 0.15,   # C3: Lingkar perut
    "umur":    0.10,   # C4: Usia (cost)
    "wsr":     0.20,   # C5: Waist-to-Shoulder Ratio (dari MediaPipe)
}

# Criteria type: "benefit" (higher is better) or "cost" (lower is better)
CRITERIA_TYPE: Dict[str, str] = {
    "bmi":     "benefit",
    "whtr":    "benefit",
    "lingkar": "benefit",
    "umur":    "cost",
    "wsr":     "benefit",
}


# ---------------------------------------------------------------------------
# Recommendation catalog per body category
# ---------------------------------------------------------------------------
RECOMMENDATIONS: Dict[str, str] = {
    "Obesitas": (
        "Fokus pada defisit kalori (500–700 kkal/hari). "
        "Latihan low-impact: jalan cepat 30 menit/hari, swimming, atau cycling. "
        "Kurangi karbohidrat olahan, perbanyak serat dan protein tanpa lemak."
    ),
    "Skinnyfat": (
        "Body recomposition: latihan beban 3–4×/minggu (compound movements). "
        "Asupan protein tinggi (1.6–2.2 g/kg BB). "
        "Cardio ringan 2×/minggu untuk menjaga kesehatan kardiovaskular."
    ),
    "Kurus": (
        "Surplus kalori 300–500 kkal/hari dengan makanan padat nutrisi. "
        "Latihan beban progresif 3×/minggu (fokus compound lifts). "
        "Tidur cukup 7–9 jam untuk pemulihan optimal."
    ),
    "Normal": (
        "Maintenance & hipertrofi: latihan beban 4×/minggu. "
        "Pertahankan asupan protein 1.4–1.8 g/kg BB. "
        "Cardio moderat 2–3×/minggu untuk kesehatan jantung."
    ),
}


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------
@dataclass
class SawAlternative:
    """A single alternative (body category) in the decision matrix."""
    name: str
    raw_scores: Dict[str, float] = field(default_factory=dict)
    norm_scores: Dict[str, float] = field(default_factory=dict)
    final_score: float = 0.0


# ---------------------------------------------------------------------------
# Main SAW function
# ---------------------------------------------------------------------------
def calculate_saw(
    bmi: float,
    whtr: float,
    umur: int,
    lingkar_perut_cm: float,
    wsr_visual: float = 0.70,
) -> Tuple[str, str, Dict[str, float]]:
    """Run the SAW calculation and return the winning category.

    Args:
        bmi:              Body Mass Index.
        whtr:             Waist-to-Height Ratio.
        umur:             User age in years.
        lingkar_perut_cm: Waist circumference in cm.
        wsr_visual:       Waist-to-Shoulder Ratio from MediaPipe CV scan.

    Returns:
        Tuple of (kategori_tubuh, rekomendasi_text, scores_dict).
    """

    # ----- 1. Build the decision matrix (one row per alternative) ----------
    alternatives: List[SawAlternative] = [
        SawAlternative(
            name="Obesitas",
            raw_scores={
                "bmi":     _suitability(bmi,             30.0, 50.0),
                "whtr":    _suitability(whtr,             0.60, 1.00),
                "lingkar": _suitability(lingkar_perut_cm, 90.0, 150.0),
                "umur":    1.0,
                "wsr":     _suitability(wsr_visual,       0.85, 1.50),
            },
        ),
        SawAlternative(
            name="Skinnyfat",
            raw_scores={
                "bmi":     _suitability(bmi,             18.5, 24.9),
                "whtr":    _suitability(whtr,             0.50, 0.59),
                "lingkar": _suitability(lingkar_perut_cm, 75.0, 89.9),
                "umur":    1.0,
                "wsr":     _suitability(wsr_visual,       0.75, 0.95),
            },
        ),
        SawAlternative(
            name="Kurus",
            raw_scores={
                "bmi":     _suitability(bmi,             10.0, 18.4),
                "whtr":    _suitability(whtr,             0.30, 0.49),
                "lingkar": _suitability(lingkar_perut_cm, 40.0, 74.9),
                "umur":    1.0,
                "wsr":     _suitability(wsr_visual,       0.40, 0.69),
            },
        ),
        SawAlternative(
            name="Normal",
            raw_scores={
                "bmi":     _suitability(bmi,             18.5, 24.9),
                "whtr":    _suitability(whtr,             0.40, 0.49),
                "lingkar": _suitability(lingkar_perut_cm, 60.0, 89.9),
                "umur":    1.0,
                "wsr":     _suitability(wsr_visual,       0.60, 0.74),
            },
        ),
    ]

    # ----- 2. Determine max and min per criterion across alternatives ------
    criteria = list(CRITERIA_WEIGHTS.keys())
    max_vals = {c: max(a.raw_scores[c] for a in alternatives) for c in criteria}

    # ----- 3. Normalize -------------------------------------------------------
    for alt in alternatives:
        for c in criteria:
            if max_vals[c] != 0:
                alt.norm_scores[c] = alt.raw_scores[c] / max_vals[c]
            else:
                alt.norm_scores[c] = 0.0

    # ----- 4. Weighted sum ----------------------------------------------------
    for alt in alternatives:
        alt.final_score = round(
            sum(alt.norm_scores[c] * CRITERIA_WEIGHTS[c] for c in criteria), 4
        )

    # ----- 5. Pick the winner -------------------------------------------------
    winner = max(alternatives, key=lambda a: a.final_score)
    scores_dict = {alt.name: alt.final_score for alt in alternatives}

    return winner.name, RECOMMENDATIONS[winner.name], scores_dict


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def _suitability(value: float, lo: float, hi: float) -> float:
    """
    Menghitung seberapa cocok 'value' masuk ke dalam rentang [lo, hi].
    Return 1.0 jika masuk rentang. Jika di luar, nilainya berkurang mendekati 0.
    """
    if lo <= value <= hi:
        return 1.0
    
    dist = min(abs(value - lo), abs(value - hi))
    range_span = max(hi - lo, 5.0) # minimal span 5 agar penalti tidak terlalu ekstrem
    
    # Skor berkurang seiring jauhnya jarak dari rentang ideal
    return max(0.0, 1.0 - (dist / range_span))

