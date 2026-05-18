"""
cv_router.py — /api/assessment endpoints.

Receives a one-shot payload (image + form data), runs BMI calculation,
mock CV analysis, SAW-based recommendations, and persists results.

Payload field names aligned with Flutter ResultController.onAnalysis():
    tinggi  → tinggi_cm
    berat   → berat_kg
    umur    → umur
    lingkar → lingkar_perut_cm
"""

import json
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from models import User, CvAssessment
from schemas import (
    VitalityAssessmentRequest,
    AssessmentResponse,
    AssessmentResult,
    AssessmentHistoryItem,
    ApiResponse,
)
from auth import get_current_user
from fitness_analysis import analyze_body_image, calculate_bmi, calculate_whtr
from saw_engine import calculate_saw

router = APIRouter(prefix="/api/assessment", tags=["Vitality Assessment"])


# ---------------------------------------------------------------------------
# POST /api/assessment/generate
# ---------------------------------------------------------------------------
@router.post(
    "/generate",
    response_model=AssessmentResponse,
    status_code=status.HTTP_200_OK,
)
async def generate_recommendation(
    payload: VitalityAssessmentRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Full assessment pipeline:

    1. Calculate BMI and WHtR from form data.
    2. Run (mock) CV analysis on the uploaded image → WSR.
    3. Feed metrics into the SAW engine → body category + recommendation.
    4. Update user profile with latest measurements.
    5. Save a CvAssessment record (with rekomendasi).
    6. Return structured result.

    Flutter sends (from ResultController.onAnalysis):
        tinggi  (alias for tinggi_cm)
        berat   (alias for berat_kg)
        umur
        lingkar (alias for lingkar_perut_cm)
    """
    uid = current_user.id

    # --- Ensure user exists --------------------------------------------------
    user = db.query(User).filter(User.id == uid).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User tidak ditemukan. Silakan login terlebih dahulu.",
        )

    # --- 1. Calculate basic metrics ------------------------------------------
    bmi  = calculate_bmi(payload.berat_kg, payload.tinggi_cm)
    whtr = calculate_whtr(payload.lingkar_perut_cm, payload.tinggi_cm)

    # --- 2. Run mock CV analysis (async) -------------------------------------
    cv_result = await analyze_body_image(payload.image_url)
    wsr = cv_result["wsr"]

    # --- 3. SAW engine -------------------------------------------------------
    kategori_tubuh, rekomendasi_teks, saw_scores = calculate_saw(
        bmi=bmi,
        whtr=whtr,
        wsr=wsr,
        umur=payload.umur,
    )

    # --- 4. Update user profile -----------------------------------------------
    user.umur            = payload.umur
    user.tinggi_cm       = payload.tinggi_cm
    user.berat_kg        = payload.berat_kg
    user.lingkar_perut_cm = payload.lingkar_perut_cm
    user.bmi_terkini     = bmi
    user.fokus_utama     = kategori_tubuh
    if payload.gender:
        user.gender = payload.gender

    # --- 5. Save assessment record (with rekomendasi) -------------------------
    new_scan = CvAssessment(
        user_id=uid,
        image_url=payload.image_url or "",
        tinggi_cm=payload.tinggi_cm,
        berat_kg=payload.berat_kg,
        lingkar_perut_cm=payload.lingkar_perut_cm,
        umur=payload.umur,
        bmi_kalkulasi=bmi,
        kategori_tubuh=kategori_tubuh,
        rekomendasi=rekomendasi_teks,            # ← simpan rekomendasi
        saw_scores=json.dumps(saw_scores),       # ← simpan skor SAW
    )
    db.add(new_scan)
    db.commit()
    db.refresh(new_scan)

    # --- 6. Return result -----------------------------------------------------
    return AssessmentResponse(
        data=AssessmentResult(
            bmi=bmi,
            kategori_tubuh=kategori_tubuh,
            rekomendasi=rekomendasi_teks,
            saw_scores=saw_scores,
        )
    )


# ---------------------------------------------------------------------------
# GET /api/assessment/history — Fetch assessment history for current user
# ---------------------------------------------------------------------------
@router.get("/history", status_code=status.HTTP_200_OK)
def get_assessment_history(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Return all past assessments for the authenticated user, newest first."""
    uid = current_user.id

    assessments = (
        db.query(CvAssessment)
        .filter(CvAssessment.user_id == uid)
        .order_by(CvAssessment.tanggal_scan.desc())
        .all()
    )

    results = [
        AssessmentHistoryItem(
            id=a.id,
            tanggal_scan=a.tanggal_scan.isoformat() if a.tanggal_scan else None,
            image_url=a.image_url,
            tinggi_cm=float(a.tinggi_cm) if a.tinggi_cm else None,
            berat_kg=float(a.berat_kg) if a.berat_kg else None,
            bmi_kalkulasi=float(a.bmi_kalkulasi) if a.bmi_kalkulasi else None,
            kategori_tubuh=a.kategori_tubuh,
            rekomendasi=a.rekomendasi,
        ).model_dump()
        for a in assessments
    ]

    return ApiResponse(status="success", message="", data=results)


# ---------------------------------------------------------------------------
# GET /api/assessment/latest — Most recent assessment result
# ---------------------------------------------------------------------------
@router.get("/latest", status_code=status.HTTP_200_OK)
def get_latest_assessment(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Return the most recent CV assessment for the authenticated user."""
    uid = current_user.id

    latest = (
        db.query(CvAssessment)
        .filter(CvAssessment.user_id == uid)
        .order_by(CvAssessment.tanggal_scan.desc())
        .first()
    )

    if not latest:
        return ApiResponse(
            status="success",
            message="Belum ada hasil assessment.",
            data=None,
        )

    return ApiResponse(
        status="success",
        message="",
        data=AssessmentHistoryItem(
            id=latest.id,
            tanggal_scan=latest.tanggal_scan.isoformat() if latest.tanggal_scan else None,
            image_url=latest.image_url,
            tinggi_cm=float(latest.tinggi_cm) if latest.tinggi_cm else None,
            berat_kg=float(latest.berat_kg) if latest.berat_kg else None,
            bmi_kalkulasi=float(latest.bmi_kalkulasi) if latest.bmi_kalkulasi else None,
            kategori_tubuh=latest.kategori_tubuh,
            rekomendasi=latest.rekomendasi,
        ).model_dump(),
    )