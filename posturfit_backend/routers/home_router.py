"""
home_router.py — /api/home endpoints.

Returns dashboard summary with fields aligned to Flutter's:
    - UserOut        (name, height, weight, bmi, goal, age)
    - DailyTrackerOut (olahraga, nutrisi, tidur, sleep_duration,
                       hydration_current, hydration_target, activity_score)
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import date

from database import get_db
from models import User, DailyTracker
from schemas import HomeResponse, HomeSummary, UserOut, DailyTrackerOut
from auth import get_current_user

router = APIRouter(prefix="/api/home", tags=["Home Dashboard"])


# ---------------------------------------------------------------------------
# GET /api/home/summary
# ---------------------------------------------------------------------------
@router.get("/summary", response_model=HomeResponse, status_code=status.HTTP_200_OK)
def get_home_summary(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Build the dashboard summary for the authenticated user.

    Returns:
        - user: UserOut — profile snapshot with Flutter field names.
        - indikator_harian: DailyTrackerOut — today's activity data
          matching Flutter ActivityEntity (olahraga, nutrisi, tidur,
          sleep_duration, hydration_current, hydration_target, activity_score).
    """
    uid     = current_user.id
    hari_ini = date.today()

    # --- 1. User profile -------------------------------------------------------
    user = db.query(User).filter(User.id == uid).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User tidak ditemukan. Silakan login ulang.",
        )

    # --- 2. Today's tracker ---------------------------------------------------
    tracker = (
        db.query(DailyTracker)
        .filter(DailyTracker.user_id == uid, DailyTracker.tanggal == hari_ini)
        .first()
    )

    # --- 3. Build response ----------------------------------------------------
    return HomeResponse(
        data=HomeSummary(
            user=UserOut.from_db(user),
            indikator_harian=DailyTrackerOut.from_db(tracker, hari_ini),
        )
    )