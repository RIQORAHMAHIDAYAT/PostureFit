import json
# pyrefly: ignore [missing-import]
import cv2
# pyrefly: ignore [missing-import]
import numpy as np
import os
import uuid
# pyrefly: ignore [missing-import]
from fastapi import APIRouter, Depends, HTTPException, status, File, UploadFile, Form
# pyrefly: ignore [missing-import]
from sqlalchemy.orm import Session

# ── TAMBAHAN: Import YOLO langsung dari ultralytics ──
# pyrefly: ignore [missing-import]
from ultralytics import YOLO

from database import get_db
from models import User, CvAssessment
from schemas import (
    AssessmentResponse,
    AssessmentResult,
    AssessmentHistoryItem,
    ApiResponse,
)
from auth import get_current_user
from fitness_analysis import calculate_bmi, calculate_whtr
from saw_engine import calculate_saw
from workout_recommender import generate_workout_plan

router = APIRouter(prefix="/api/assessment", tags=["Vitality Assessment"])

# ── Inisialisasi MediaPipe Pose Engine (Safely loaded) ──
pose_engine = None
mp_pose = None
pose_error_msg = None

try:
    # pyrefly: ignore [missing-import]
    import mediapipe as mp
    mp_pose = mp.solutions.pose
    pose_engine = mp_pose.Pose(
        static_image_mode=True,
        model_complexity=1,
        min_detection_confidence=0.5,
    )
except Exception as e:
    pose_error_msg = str(e)
    print(f"\n[Warning] MediaPipe Pose Engine gagal dimuat: {e}")



PT_MODEL_PATH = "models/best.pt"
yolo_model = None

try:
    if os.path.exists(PT_MODEL_PATH):

        yolo_model = YOLO(PT_MODEL_PATH)
        print(f"✓ YOLOv8 Classifier (.pt) berhasil dimuat dari {PT_MODEL_PATH}")
    else:
        print(f"\n[Warning] File model tidak ditemukan di {PT_MODEL_PATH}.")
        print("Pastikan Anda sudah memindahkan file best.pt ke folder tersebut.\n")
except Exception as e:
    print(f"[Warning] Gagal memuat model YOLOv8 .pt: {e}")


UPLOAD_DIR = "static/uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

def _midpoint(a, b) -> np.ndarray:
    return np.array([(a.x + b.x) / 2, (a.y + b.y) / 2])


# ── MODIFIKASI: Gunakan model .pt untuk Klasifikasi Postur ──
def predict_posture_yolo(image_cv) -> tuple[str, float]:
    """Menggunakan model YOLOv8 .pt untuk memprediksi kelas gerakan tubuh.
    
    Returns:
        (posture_name, confidence) — nama postur dan confidence score top-1.
    """
    if yolo_model is None:
        return "standing", 0.0  # Fallback jika model gagal termuat
        
    results = yolo_model.predict(image_cv, verbose=False)
    
    # Ambil nama kelas dengan skor tertinggi beserta confidence-nya
    top1_idx  = results[0].probs.top1
    top1_conf = float(results[0].probs.top1conf)  # confidence score (0.0–1.0)
    posture_name = results[0].names[top1_idx]
    
    return posture_name, top1_conf


def extract_pose_metrics(image_bytes: bytes, bmi: float, save_path: str):
    """Proses bytes gambar dengan MediaPipe dan YOLOv8 .pt.
    
    Returns:
        (wsr_visual, posture_label, posture_confidence, annotated_save_path)
    """
    if pose_engine is None:
        raise ValueError(f"Fitur CV / MediaPipe Pose tidak aktif di server ini: '{pose_error_msg}'.")

    np_arr = np.frombuffer(image_bytes, np.uint8)
    image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

    if image is None:
        raise ValueError("Gambar tidak bisa dibaca / format tidak didukung.")

    # 1. Validasi Keberadaan Manusia Menggunakan MediaPipe
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    mp_results = pose_engine.process(image_rgb)

    if not mp_results.pose_landmarks:
        raise ValueError("Gagal mendeteksi tubuh. Pastikan seluruh badan terlihat di kamera dengan pencahayaan yang cukup.")

    # 2. Klasifikasi Postur Menggunakan Model YOLOv8 .pt
    posture, posture_confidence = predict_posture_yolo(image)

    # 3. Ekstraksi Metrik Koordinat MediaPipe
    landmarks = mp_results.pose_landmarks.landmark
    s_left = landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER]
    s_right = landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER]
    h_left = landmarks[mp_pose.PoseLandmark.LEFT_HIP]
    h_right = landmarks[mp_pose.PoseLandmark.RIGHT_HIP]

    sh_width = abs(s_left.x - s_right.x)
    hip_width = abs(h_left.x - h_right.x)

    visual_waist_score = hip_width
    if bmi > 25:
        visual_waist_score = hip_width * 1.3

    if sh_width == 0:
        raise ValueError("Deteksi lebar bahu tidak valid, coba ambil ulang foto.")

    # 4. Menggambar skeleton overlay pada salinan gambar tersendiri (annotated)
    annotated_image = image.copy()
    try:
        import mediapipe as mp
        mp_drawing = mp.solutions.drawing_utils
        h, w, _ = annotated_image.shape
        thickness = max(4, int(min(h, w) * 0.008))
        circle_radius = max(5, int(min(h, w) * 0.005))
        
        connection_spec = mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=thickness)
        landmark_spec = mp_drawing.DrawingSpec(color=(0, 0, 255), thickness=thickness, circle_radius=circle_radius)
        
        mp_drawing.draw_landmarks(
            annotated_image, mp_results.pose_landmarks, mp_pose.POSE_CONNECTIONS,
            landmark_drawing_spec=landmark_spec, connection_drawing_spec=connection_spec
        )
    except Exception as draw_err:
        print(f"[Warning] Gagal menggambar landmark: {draw_err}")

    # Simpan gambar asli (tanpa anotasi)
    cv2.imwrite(save_path, image)

    # Simpan gambar teranotasi (dengan skeleton) ke file terpisah
    base, ext = os.path.splitext(save_path)
    annotated_save_path = f"{base}_annotated{ext}"
    cv2.imwrite(annotated_save_path, annotated_image)

    wsr_visual = visual_waist_score / sh_width
    return wsr_visual, posture, posture_confidence, annotated_save_path


# ---------------------------------------------------------------------------
# POST /api/assessment/generate
# ---------------------------------------------------------------------------
@router.post(
    "/generate",
    response_model=AssessmentResponse,
    status_code=status.HTTP_200_OK,
)
async def generate_recommendation(
    file: UploadFile = File(...),
    umur: int = Form(...),
    tinggi: float = Form(...),
    berat: float = Form(...),
    lingkar: float = Form(...),
    fokus_pilihan: str = Form(None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    uid = current_user.id

    user = db.query(User).filter(User.id == uid).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User tidak ditemukan. Silakan login terlebih dahulu.",
        )

    try:
        file_content = await file.read()
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Gagal membaca file gambar: {e}"
        )

    ext = os.path.splitext(file.filename or "")[1] or ".jpg"
    filename = f"{uuid.uuid4()}{ext}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    try:
        with open(file_path, "wb") as f:
            f.write(file_content)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Gagal menyimpan file gambar di server: {e}"
        )

    image_url = f"/static/uploads/{filename}"

    bmi  = calculate_bmi(berat, tinggi)
    whtr = calculate_whtr(lingkar, tinggi)

    try:
        # Menangkap hasil WSR, jenis postur, confidence, dan path gambar teranotasi
        wsr_visual, postur_terdeteksi, postur_confidence, annotated_path = extract_pose_metrics(
            file_content, bmi, file_path
        )
        # URL gambar teranotasi (skeleton) — ditampilkan di hasil analisis Flutter
        annotated_filename = os.path.basename(annotated_path)
        annotated_image_url = f"/static/uploads/{annotated_filename}"
    except ValueError as ve:
        if os.path.exists(file_path):
            os.remove(file_path)
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(ve)
        )
    except Exception as e:
        if os.path.exists(file_path):
            os.remove(file_path)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error saat pose estimation: {e}"
        )

    # --- 3. SAW engine (Sekarang bisa menambahkan parameter postur_terdeteksi jika saw_engine mendukung) ---
    kategori_tubuh, rekomendasi_teks, saw_scores = calculate_saw(
        bmi=bmi,
        whtr=whtr,
        umur=umur,
        lingkar_perut_cm=lingkar,
        wsr_visual=wsr_visual,
        # postur=postur_terdeteksi  <── Jika kelak saw_engine butuh parameter string postur hasil YOLOv8
    )

    user.umur             = umur
    user.tinggi_cm        = tinggi
    user.berat_kg         = berat
    user.lingkar_perut_cm = lingkar
    user.bmi_terkini      = bmi
    user.fokus_utama      = kategori_tubuh
    if fokus_pilihan:
        user.fokus_pilihan = fokus_pilihan

    new_scan = CvAssessment(
        user_id=uid,
        image_url=image_url,
        tinggi_cm=tinggi,
        berat_kg=berat,
        lingkar_perut_cm=lingkar,
        umur=umur,
        bmi_kalkulasi=bmi,
        kategori_tubuh=kategori_tubuh,
        rekomendasi=rekomendasi_teks,
        saw_scores=json.dumps(saw_scores),
        postur_label=postur_terdeteksi,
        workout_json=json.dumps(
            generate_workout_plan(
                kategori_tubuh=kategori_tubuh,
                postur_label=postur_terdeteksi,
                lingkungan="Rumah",   # default; frontend bisa request ulang dengan lingkungan berbeda
            )
        ),
    )
    db.add(new_scan)
    db.commit()
    db.refresh(new_scan)

    return AssessmentResponse(
        data=AssessmentResult(
            bmi=bmi,
            kategori_tubuh=kategori_tubuh,
            rekomendasi=rekomendasi_teks,
            saw_scores=saw_scores,
            image_url=image_url,
            postur_label=postur_terdeteksi,          # Label postur dari YOLOv8
            postur_confidence=round(postur_confidence, 4),  # Confidence score YOLOv8
            annotated_image_url=annotated_image_url, # Foto + skeleton overlay MediaPipe
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