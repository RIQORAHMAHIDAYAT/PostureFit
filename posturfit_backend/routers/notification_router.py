# pyrefly: ignore [missing-import]
from fastapi import APIRouter, Depends, HTTPException, status
# pyrefly: ignore [missing-import]
from sqlalchemy.orm import Session

from database import get_db
from models import Notification, User
from schemas import NotificationOut, ApiResponse
from auth import get_current_user

router = APIRouter(prefix="/api/notifications", tags=["Notifications"])


# ---------------------------------------------------------------------------
# GET /api/notifications  —  Get all notifications globally
# ---------------------------------------------------------------------------
@router.get("", response_model=ApiResponse)
def get_notifications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all global notifications."""
    notifications = (
        db.query(Notification)
        .order_by(Notification.created_at.desc())
        .all()
    )

    data = [NotificationOut.from_db(n).model_dump() for n in notifications]

    # If no notifications in DB, return welcome notification as seed
    if not data:
        data = _get_seed_notifications()

    return ApiResponse(
        status="success",
        message="Daftar notifikasi global berhasil diambil.",
        data={
            "unread_count": sum(1 for n in data if not n.get("is_read", False)),
            "notifications": data,
        }
    )


# ---------------------------------------------------------------------------
# PATCH /api/notifications/{notif_id}/read  —  Mark as read
# ---------------------------------------------------------------------------
@router.patch("/{notif_id}/read", response_model=ApiResponse)
def mark_notification_read(
    notif_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Mark a single global notification as read."""
    notif = (
        db.query(Notification)
        .filter(Notification.id == notif_id)
        .first()
    )

    if not notif:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notifikasi tidak ditemukan.",
        )

    notif.is_read = True
    db.commit()

    return ApiResponse(status="success", message="Notifikasi ditandai sudah dibaca.")


# ---------------------------------------------------------------------------
# PATCH /api/notifications/read-all  —  Mark all as read
# ---------------------------------------------------------------------------
@router.patch("/read-all", response_model=ApiResponse)
def mark_all_read(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Mark all global notifications as read."""
    db.query(Notification).filter(
        Notification.is_read == False,
    ).update({"is_read": True})
    db.commit()

    return ApiResponse(status="success", message="Semua notifikasi telah dibaca.")


# ---------------------------------------------------------------------------
# POST /api/notifications  —  Create a notification (internal/admin use)
# ---------------------------------------------------------------------------
@router.post("", response_model=ApiResponse, status_code=status.HTTP_201_CREATED)
def create_notification(
    payload: dict,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a global notification."""
    notif = Notification(
        title=payload.get("title", ""),
        message=payload.get("message", ""),
        type=payload.get("type", "system"),
        is_read=False,
    )
    db.add(notif)
    db.commit()
    db.refresh(notif)

    return ApiResponse(
        status="success",
        message="Notifikasi berhasil dibuat.",
        data=NotificationOut.from_db(notif).model_dump(),
    )


# ---------------------------------------------------------------------------
# Seed notifications — when DB has no data yet
# ---------------------------------------------------------------------------
def _get_seed_notifications():
    """Static welcome notification matching Flutter NotificationItem format."""
    return [
        {
            "id": "seed-1",
            "title": "Selamat Datang di PostureFit!",
            "message": "Mulai perjalanan kebugaran Anda. Coba scan postur hari ini untuk mendapatkan rekomendasi personal.",
            "time": "Baru saja",
            "type": "system",
            "is_read": False,
        },
        {
            "id": "seed-2",
            "title": "Cek Postur Hari Ini",
            "message": "Jangan lupa lakukan scan postur harian Anda untuk memantau perkembangan.",
            "time": "Hari ini",
            "type": "posture",
            "is_read": False,
        },
    ]
