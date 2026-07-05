"""
workout_plan_router.py — Endpoint untuk Workout Plan dan DSS Analysis.

Routes:
    GET /api/workout-plan/latest    → rencana workout dari assessment terakhir
    GET /api/workout-plan/history   → riwayat workout plan semua assessment
    GET /api/dss/latest             → detail skor SAW + insight postur terbaru
    GET /api/dss/history            → riwayat DSS analysis
"""

import json
# pyrefly: ignore [missing-import]
from fastapi import APIRouter, Depends, status
# pyrefly: ignore [missing-import]
from sqlalchemy.orm import Session
from typing import Optional

from database import get_db
from models import User, CvAssessment
from schemas import ApiResponse, WorkoutPlanOut, WorkoutItemOut, DssDetailOut, DssScoreItem
from auth import get_current_user
from workout_recommender import generate_workout_plan, POSTUR_NOTES

workout_router = APIRouter(prefix="/api/workout-plan", tags=["Workout Plan"])
dss_router     = APIRouter(prefix="/api/dss",          tags=["DSS Analysis"])


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _parse_workout_plan(assessment: CvAssessment, lingkungan: str = "Rumah") -> Optional[WorkoutPlanOut]:
    """
    Mengambil atau membuat WorkoutPlanOut dari satu CvAssessment.
    Jika workout_json sudah tersimpan di DB, gunakan itu.
    Jika belum (data lama), generate on-the-fly dari kategori_tubuh.
    """
    kategori   = assessment.kategori_tubuh or "Normal"
    postur     = assessment.postur_label   or "standing"
    tanggal    = assessment.tanggal_scan.isoformat() if assessment.tanggal_scan else None

    if assessment.workout_json:
        try:
            raw = json.loads(assessment.workout_json)
            # Pastikan lingkungan yang diminta tersedia, jika tidak ambil default dari DB
            plan_lingkungan = raw.get("lingkungan", lingkungan)
            if plan_lingkungan != lingkungan:
                # Re-generate dengan lingkungan baru
                raw = generate_workout_plan(kategori, postur, lingkungan)
        except Exception:
            raw = generate_workout_plan(kategori, postur, lingkungan)
    else:
        raw = generate_workout_plan(kategori, postur, lingkungan)

    def _to_item(d: dict) -> WorkoutItemOut:
        return WorkoutItemOut(
            nama_latihan=d.get("nama_latihan", ""),
            target_otot=d.get("target_otot", ""),
            set_reps=d.get("set_reps", ""),
            kalori_estimasi=d.get("kalori_estimasi", 0),
            icon_key=d.get("icon_key", "fitness_center"),
        )

    utama_raw = raw.get("latihan_utama")
    return WorkoutPlanOut(
        kategori_tubuh=raw.get("kategori_tubuh", kategori),
        postur_label=raw.get("postur_label", postur),
        lingkungan=raw.get("lingkungan", lingkungan),
        postur_catatan=raw.get("postur_catatan", ""),
        latihan_utama=_to_item(utama_raw) if utama_raw else None,
        latihan_tambahan=[_to_item(w) for w in raw.get("latihan_tambahan", [])],
        latihan_koreksi_postur=[_to_item(w) for w in raw.get("latihan_koreksi_postur", [])],
        estimasi_kalori_total=raw.get("estimasi_kalori_total", 0),
        estimasi_durasi_menit=raw.get("estimasi_durasi_menit", 35),
        tanggal_assessment=tanggal,
    )


def _parse_dss(assessment: CvAssessment) -> Optional[DssDetailOut]:
    """Membangun DssDetailOut dari satu CvAssessment."""
    if not assessment:
        return None

    kategori   = assessment.kategori_tubuh or "Normal"
    postur     = assessment.postur_label   or "standing"
    rekomendasi = assessment.rekomendasi   or ""
    tanggal    = assessment.tanggal_scan.isoformat() if assessment.tanggal_scan else None
    bmi_val    = float(assessment.bmi_kalkulasi) if assessment.bmi_kalkulasi else None

    # Parse saw_scores JSON
    saw_detail: list[DssScoreItem] = []
    winner_score = 0.0
    try:
        if assessment.saw_scores:
            scores: dict = json.loads(assessment.saw_scores)
            for kat, skor in scores.items():
                saw_detail.append(DssScoreItem(
                    kategori=kat,
                    skor=round(float(skor), 4),
                    persentase=round(float(skor) * 100),
                ))
                if kat == kategori:
                    winner_score = float(skor)
    except Exception:
        pass

    # Skor kesehatan = skor SAW winner yang dinormalisasi ke 0-100
    # Max SAW score cenderung 0.90+, kita skalakan ke 100
    skor_kesehatan = min(100, round(winner_score * 110))

    # Kategori BMI
    bmi_kat = None
    if bmi_val:
        if bmi_val < 18.5:
            bmi_kat = "Kurus (Underweight)"
        elif bmi_val < 25.0:
            bmi_kat = "Normal"
        elif bmi_val < 30.0:
            bmi_kat = "Gemuk (Overweight)"
        else:
            bmi_kat = "Obesitas"

    postur_note = POSTUR_NOTES.get(postur.lower(), "")

    return DssDetailOut(
        tanggal_assessment=tanggal,
        kategori_terpilih=kategori,
        skor_kesehatan=skor_kesehatan,
        postur_label=postur,
        postur_catatan=postur_note,
        rekomendasi=rekomendasi,
        saw_detail=saw_detail,
        bmi=bmi_val,
        kategori_bmi=bmi_kat,
    )


# ---------------------------------------------------------------------------
# WORKOUT PLAN ENDPOINTS
# ---------------------------------------------------------------------------

@workout_router.get("/latest", response_model=ApiResponse, status_code=status.HTTP_200_OK)
def get_latest_workout_plan(
    lingkungan: str = "Rumah",
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Kembalikan rencana workout personal dari assessment postur terakhir.

    Query param:
        lingkungan: Rumah | Gym | Calisthenics  (default: Rumah)
    """
    latest = (
        db.query(CvAssessment)
        .filter(CvAssessment.user_id == current_user.id)
        .order_by(CvAssessment.tanggal_scan.desc())
        .first()
    )

    if not latest:
        return ApiResponse(
            status="success",
            message="Belum ada data assessment. Lakukan scan postur terlebih dahulu.",
            data=None,
        )

    plan = _parse_workout_plan(latest, lingkungan)
    return ApiResponse(status="success", message="", data=plan.model_dump() if plan else None)


@workout_router.get("/history", response_model=ApiResponse, status_code=status.HTTP_200_OK)
def get_workout_plan_history(
    lingkungan: str = "Rumah",
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Kembalikan riwayat workout plan dari semua assessment (terbaru duluan)."""
    assessments = (
        db.query(CvAssessment)
        .filter(CvAssessment.user_id == current_user.id)
        .order_by(CvAssessment.tanggal_scan.desc())
        .all()
    )

    result = []
    for a in assessments:
        plan = _parse_workout_plan(a, lingkungan)
        if plan:
            result.append(plan.model_dump())

    return ApiResponse(
        status="success",
        message=f"{len(result)} rencana workout ditemukan.",
        data=result,
    )


# ---------------------------------------------------------------------------
# DSS ENDPOINTS
# ---------------------------------------------------------------------------

@dss_router.get("/latest", response_model=ApiResponse, status_code=status.HTTP_200_OK)
def get_latest_dss(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Kembalikan detail DSS dari assessment postur terakhir."""
    latest = (
        db.query(CvAssessment)
        .filter(CvAssessment.user_id == current_user.id)
        .order_by(CvAssessment.tanggal_scan.desc())
        .first()
    )

    if not latest:
        return ApiResponse(
            status="success",
            message="Belum ada data assessment.",
            data=None,
        )

    dss = _parse_dss(latest)
    return ApiResponse(status="success", message="", data=dss.model_dump() if dss else None)


@dss_router.get("/history", response_model=ApiResponse, status_code=status.HTTP_200_OK)
def get_dss_history(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Kembalikan riwayat analisis DSS dari semua assessment (terbaru duluan)."""
    assessments = (
        db.query(CvAssessment)
        .filter(CvAssessment.user_id == current_user.id)
        .order_by(CvAssessment.tanggal_scan.desc())
        .all()
    )

    result = []
    for a in assessments:
        dss = _parse_dss(a)
        if dss:
            result.append(dss.model_dump())

    return ApiResponse(
        status="success",
        message=f"{len(result)} riwayat analisis DSS ditemukan.",
        data=result,
    )
