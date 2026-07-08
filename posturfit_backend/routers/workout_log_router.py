# pyrefly: ignore [missing-import]
from fastapi import APIRouter, Depends, HTTPException, status
# pyrefly: ignore [missing-import]
from sqlalchemy.orm import Session

from database import get_db
from models import WorkoutLog, User, DailyTracker
from schemas import WorkoutLogCreate, WorkoutLogOut, ApiResponse
from auth import get_current_user
from datetime import date
import re

router = APIRouter(prefix="/api/workout-log", tags=["Workout Log"])


# ---------------------------------------------------------------------------
# GET /api/workout-log  —  Get all workout logs for current user
# ---------------------------------------------------------------------------
@router.get("", response_model=ApiResponse, status_code=status.HTTP_200_OK)
def get_workout_logs(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Return workout history for the authenticated user, newest first.

    Response matches Flutter WorkoutLogController format:
        title, category, duration, calories, date, image
    """
    uid = current_user.id

    logs = (
        db.query(WorkoutLog)
        .filter(WorkoutLog.user_id == uid)
        .order_by(WorkoutLog.logged_at.desc())
        .all()
    )

    data = [WorkoutLogOut.from_db(log).model_dump() for log in logs]

    return ApiResponse(
        status="success",
        message=f"{len(data)} sesi latihan ditemukan.",
        data=data,
    )


# ---------------------------------------------------------------------------
# POST /api/workout-log  —  Add a new workout log entry
# ---------------------------------------------------------------------------
@router.post("", response_model=ApiResponse, status_code=status.HTTP_201_CREATED)
def add_workout_log(
    payload: WorkoutLogCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Log a completed workout session.

    Accepts Flutter WorkoutLogController fields:
        title, category, duration, calories, image
    """
    uid = current_user.id

    user = db.query(User).filter(User.id == uid).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User tidak ditemukan.",
        )

    new_log = WorkoutLog(
        user_id=uid,
        title=payload.title,
        category=payload.category,
        duration=payload.duration,
        calories=payload.calories,
        image=payload.image,
    )
    db.add(new_log)
    db.commit()
    db.refresh(new_log)

    # ---------------------------------------------------------
    # Auto-update DailyTracker (olahraga)
    # ---------------------------------------------------------
    # Ambil durasi sesi baru ini (misal "15 menit" -> 15)
    durasi_baru = 0
    if payload.duration:
        match = re.search(r'\d+', payload.duration)
        if match:
            durasi_baru = int(match.group())

    if durasi_baru > 0:
        today = date.today()
        tracker = (
            db.query(DailyTracker)
            .filter(
                DailyTracker.user_id == uid,
                DailyTracker.tanggal == today,
            )
            .first()
        )
        if not tracker:
            tracker = DailyTracker(user_id=uid, tanggal=today)
            db.add(tracker)
            
        # Target 60 menit olahraga sehari = 100%
        # Ambil nilai olahraga sebelumnya, hitung ulang
        # Atau increment
        # Jika increment:
        increment_pct = int((durasi_baru / 60.0) * 100)
        current_olahraga = tracker.olahraga or 0
        
        # Skor aktivitas juga kita naikkan
        current_skor = tracker.skor_aktivitas or 0
        increment_skor = int((durasi_baru / 60.0) * 30) # Misal bobot max 30 untuk olahraga
        
        tracker.olahraga = min(100, current_olahraga + increment_pct)
        tracker.skor_aktivitas = min(100, current_skor + increment_skor)
        db.commit()

    return ApiResponse(
        status="success",
        message="Sesi latihan berhasil dicatat.",
        data=WorkoutLogOut.from_db(new_log).model_dump(),
    )


# ---------------------------------------------------------------------------
# GET /api/workout-log/stats  —  Get stats for Progress Report
# ---------------------------------------------------------------------------
@router.get("/stats", response_model=ApiResponse, status_code=status.HTTP_200_OK)
def get_workout_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Return total stats (calories, duration, sessions) for the user."""
    uid = current_user.id
    logs = db.query(WorkoutLog).filter(WorkoutLog.user_id == uid).all()
    
    total_sesi = len(logs)
    total_kalori = 0
    total_durasi = 0
    
    for log in logs:
        # Parse kalori ("150 kcal" -> 150)
        if log.calories:
            match = re.search(r'\d+', log.calories)
            if match:
                total_kalori += int(match.group())
                
        # Parse durasi ("15 menit" -> 15)
        if log.duration:
            match = re.search(r'\d+', log.duration)
            if match:
                total_durasi += int(match.group())
                
    # Format kalori with comma if large, or just return int. We'll return strings formatted or just ints.
    # Return as dict for frontend
    return ApiResponse(
        status="success",
        message="Statistik berhasil diambil.",
        data={
            "total_sesi": total_sesi,
            "total_kalori": total_kalori,
            "total_durasi": total_durasi,
        }
    )


# ---------------------------------------------------------------------------
# DELETE /api/workout-log/{log_id}  —  Delete a workout log entry
# ---------------------------------------------------------------------------
@router.delete("/{log_id}", response_model=ApiResponse, status_code=status.HTTP_200_OK)
def delete_workout_log(
    log_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Delete a workout log entry."""
    uid = current_user.id

    log = (
        db.query(WorkoutLog)
        .filter(WorkoutLog.id == log_id, WorkoutLog.user_id == uid)
        .first()
    )

    if not log:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Log tidak ditemukan.",
        )

    db.delete(log)
    db.commit()

    return ApiResponse(status="success", message="Log latihan dihapus.")
