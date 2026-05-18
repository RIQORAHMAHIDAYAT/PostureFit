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
    - Normal
    - Obesitas
    - Kurus
    - Skinnyfat

Criteria:
    - C1: BMI                (benefit → higher BMI leans toward Obesitas)
    - C2: WHtR               (benefit → higher waist-to-height leans toward Obesitas)
    - C3: Visual WSR (mock)  (benefit → higher visual score leans toward Skinnyfat)
    - C4: Umur               (cost   → younger = more capacity for intense programs)
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple


# ---------------------------------------------------------------------------
# Weights — sum must equal 1.0
# ---------------------------------------------------------------------------
CRITERIA_WEIGHTS: Dict[str, float] = {
    "bmi":  0.35,
    "whtr": 0.30,
    "wsr":  0.20,
    "umur": 0.15,
}

# Criteria type: "benefit" (higher is better) or "cost" (lower is better)
CRITERIA_TYPE: Dict[str, str] = {
    "bmi":  "benefit",
    "whtr": "benefit",
    "wsr":  "benefit",
    "umur": "cost",
}


# ---------------------------------------------------------------------------
# Recommendation catalog per body category
# ---------------------------------------------------------------------------
RECOMMENDATIONS: Dict[str, str] = {
    "Obesitas": (
        "Fokus pada defisit kalori (500–700 kkal/hari). "
        "Latihan low-impact: jalan cepat 30 menit/hari, swimming, atau cycling. "
        "Kurangi karbohidrat olahan dan perbanyak serat."
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
    wsr: float,
    umur: int,
) -> Tuple[str, str, Dict[str, float]]:
    """Run the SAW calculation and return the winning category.

    Args:
        bmi:  Body Mass Index.
        whtr: Waist-to-Height Ratio.
        wsr:  Waist-Shoulder Ratio (from CV/mock).
        umur: User age in years.

    Returns:
        Tuple of (kategori_tubuh, rekomendasi_text, scores_dict).
    """

    # ----- 1. Build the decision matrix (one row per alternative) ----------
    # These reference profiles represent "ideal" metric patterns for each
    # body category.  The user's actual metrics are compared against them.
    alternatives: List[SawAlternative] = [
        SawAlternative(name="Obesitas",  raw_scores={"bmi": _clamp(bmi, 30, 50),   "whtr": _clamp(whtr, 0.60, 1.0), "wsr": _clamp(wsr, 0.3, 0.5),  "umur": float(umur)}),
        SawAlternative(name="Skinnyfat", raw_scores={"bmi": _clamp(bmi, 18.5, 29.9), "whtr": _clamp(whtr, 0.50, 0.59), "wsr": _clamp(wsr, 0.8, 1.0), "umur": float(umur)}),
        SawAlternative(name="Kurus",     raw_scores={"bmi": _clamp(bmi, 10, 18.4),   "whtr": _clamp(whtr, 0.30, 0.49), "wsr": _clamp(wsr, 0.3, 0.6),  "umur": float(umur)}),
        SawAlternative(name="Normal",    raw_scores={"bmi": _clamp(bmi, 18.5, 24.9), "whtr": _clamp(whtr, 0.40, 0.50), "wsr": _clamp(wsr, 0.5, 0.7),  "umur": float(umur)}),
    ]

    # ----- 2. Determine max and min per criterion across alternatives ------
    criteria = list(CRITERIA_WEIGHTS.keys())
    max_vals = {c: max(a.raw_scores[c] for a in alternatives) for c in criteria}
    min_vals = {c: min(a.raw_scores[c] for a in alternatives) for c in criteria}

    # ----- 3. Normalize -------------------------------------------------------
    for alt in alternatives:
        for c in criteria:
            if CRITERIA_TYPE[c] == "benefit":
                # Benefit: r = x / max(x)
                alt.norm_scores[c] = alt.raw_scores[c] / max_vals[c] if max_vals[c] != 0 else 0
            else:
                # Cost: r = min(x) / x
                alt.norm_scores[c] = min_vals[c] / alt.raw_scores[c] if alt.raw_scores[c] != 0 else 0

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
def _clamp(value: float, lo: float, hi: float) -> float:
    """Clamp *value* to lie within [lo, hi]."""
    return max(lo, min(hi, value))
