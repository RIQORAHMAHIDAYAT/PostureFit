# pyrefly: ignore [missing-import]
from fastapi import APIRouter, Depends
# pyrefly: ignore [missing-import]
from sqlalchemy.orm import Session
# pyrefly: ignore [missing-import]
from sqlalchemy import func
from markupsafe import Markup
from database import get_db
# pyrefly: ignore [missing-import]
from sqladmin import ModelView
from sync_service import sync_education_from_mongo
from models import (
    User, CvAssessment, DailyTracker,
    DailyWorkoutPlan, WorkoutTask,
    WorkoutLog, EducationArticle, Notification, AdminUser,
)


class UserAdmin(ModelView, model=User):
    column_list = [
        User.id,
        User.nama_lengkap,
        User.email,
        User.gender,
        User.umur,
        User.tinggi_cm,
        User.berat_kg,
        User.lingkar_perut_cm,
        User.bmi_terkini,
        User.fokus_utama,
        User.created_at,
    ]
    column_searchable_list = [User.nama_lengkap, User.email]
    column_sortable_list   = [User.created_at, User.bmi_terkini]
    column_default_sort    = ("created_at", True)
    name        = "Data Pengguna"
    name_plural = "Data Pengguna"
    icon        = "fa-solid fa-users"


class CvAssessmentAdmin(ModelView, model=CvAssessment):
    column_list = [
        CvAssessment.id,
        CvAssessment.user_id,
        CvAssessment.kategori_tubuh,
        CvAssessment.bmi_kalkulasi,
        CvAssessment.rekomendasi,
        CvAssessment.tanggal_scan,
    ]
    column_searchable_list = [CvAssessment.kategori_tubuh]
    column_sortable_list   = [CvAssessment.tanggal_scan, CvAssessment.bmi_kalkulasi]
    column_default_sort    = ("tanggal_scan", True)
    name        = "Hasil Scan CV"
    name_plural = "Hasil Scan CV"
    icon        = "fa-solid fa-camera"


class DailyTrackerAdmin(ModelView, model=DailyTracker):
    column_list = [
        DailyTracker.id,
        DailyTracker.user_id,
        DailyTracker.tanggal,
        DailyTracker.olahraga,
        DailyTracker.nutrisi,
        DailyTracker.tidur_persen,
        DailyTracker.hidrasi_ml,
        DailyTracker.hydration_target_ml,
        DailyTracker.tidur_jam,
        DailyTracker.skor_aktivitas,
    ]
    column_sortable_list = [DailyTracker.tanggal, DailyTracker.skor_aktivitas]
    column_default_sort  = ("tanggal", True)
    name        = "Aktivitas Harian"
    name_plural = "Aktivitas Harian"
    icon        = "fa-solid fa-chart-line"


class DailyWorkoutPlanAdmin(ModelView, model=DailyWorkoutPlan):
    column_list = [
        DailyWorkoutPlan.id,
        DailyWorkoutPlan.user_id,
        DailyWorkoutPlan.tanggal_rencana,
        DailyWorkoutPlan.tema_latihan,
        DailyWorkoutPlan.target_kalori,
        DailyWorkoutPlan.estimasi_menit,
    ]
    name        = "Rencana Latihan"
    name_plural = "Rencana Latihan"
    icon        = "fa-solid fa-dumbbell"


class WorkoutTaskAdmin(ModelView, model=WorkoutTask):
    column_list = [
        WorkoutTask.id,
        WorkoutTask.plan_id,
        WorkoutTask.nama_latihan,
        WorkoutTask.target_otot,
        WorkoutTask.set_reps,
        WorkoutTask.is_completed,
    ]
    name        = "Detail Latihan"
    name_plural = "Detail Latihan"
    icon        = "fa-solid fa-list-check"


class WorkoutLogAdmin(ModelView, model=WorkoutLog):
    column_list = [
        WorkoutLog.id,
        WorkoutLog.user_id,
        WorkoutLog.title,
        WorkoutLog.category,
        WorkoutLog.duration,
        WorkoutLog.calories,
        WorkoutLog.logged_at,
    ]
    column_searchable_list = [WorkoutLog.title, WorkoutLog.category]
    column_sortable_list   = [WorkoutLog.logged_at]
    column_default_sort    = ("logged_at", True)
    name        = "Riwayat Workout"
    name_plural = "Riwayat Workout"
    icon        = "fa-solid fa-person-running"


class EducationArticleAdmin(ModelView, model=EducationArticle):
    column_list = [
        EducationArticle.id,
        EducationArticle.judul,
        EducationArticle.kategori,
        EducationArticle.sumber,
        EducationArticle.updated_at,
    ]
    column_searchable_list = [EducationArticle.judul, EducationArticle.kategori]
    column_sortable_list   = [EducationArticle.updated_at]
    column_default_sort    = ("updated_at", True)
    name        = "Artikel Edukasi"
    name_plural = "Artikel Edukasi"
    icon        = "fa-solid fa-book"


class NotificationAdmin(ModelView, model=Notification):
    # ── Tabel daftar notifikasi ──────────────────────────────────────────────
    column_list = [
        Notification.id,
        Notification.user_id,
        Notification.title,
        Notification.type,
        Notification.is_read,
        Notification.created_at,
    ]
    column_searchable_list = [Notification.title, Notification.type]
    column_sortable_list   = [Notification.created_at]
    column_default_sort    = ("created_at", True)

    # ── Form buat notifikasi — tanpa field user (broadcast otomatis) ─────────
    # Sembunyikan semua kolom yang tidak perlu diisi admin
    form_excluded_columns  = ["user_id", "created_at", "user"]
    form_include_pk        = False   # Jangan tampilkan kolom ID

    name        = "Notifikasi"
    name_plural = "Notifikasi"
    icon        = "fa-solid fa-bell"

    # ── Override insert — kirim ke SEMUA user otomatis ───────────────────────
    async def insert_model(self, request, data: dict):
        from database import SessionLocal
        db = SessionLocal()
        try:
            all_user_ids = [row[0] for row in db.query(User.id).all()]
            title      = data.get("title", "Notifikasi")
            message    = data.get("message", "")
            notif_type = data.get("type", "system")
            is_read    = False   # selalu unread saat baru dibuat

            last_notif = None
            if all_user_ids:
                for uid in all_user_ids:
                    n = Notification(
                        user_id=uid,
                        title=title,
                        message=message,
                        type=notif_type,
                        is_read=is_read,
                    )
                    db.add(n)
                    last_notif = n
            else:
                # Tidak ada user terdaftar — buat 1 entri sistem sebagai placeholder
                last_notif = Notification(
                    user_id="SYSTEM",
                    title=title,
                    message=message,
                    type=notif_type,
                    is_read=is_read,
                )
                db.add(last_notif)

            db.commit()
            db.refresh(last_notif)
            db.expunge(last_notif)
            return last_notif
        except Exception as e:
            db.rollback()
            raise e
        finally:
            db.close()


class AdminUserAdmin(ModelView, model=AdminUser):
    # Sembunyikan password_hash dari tampilan & form
    column_list = [
        AdminUser.id,
        AdminUser.username,
        AdminUser.email,
        AdminUser.is_active,
        AdminUser.created_at,
        "change_password",
    ]
    column_searchable_list  = [AdminUser.username, AdminUser.email]
    column_sortable_list    = [AdminUser.created_at, AdminUser.username]
    column_default_sort     = ("created_at", True)
    form_excluded_columns   = ["password_hash"]   # jangan tampilkan hash password
    can_create              = False                # buat admin via create_admin.py
    can_edit                = True                 # bisa toggle is_active
    can_delete              = True
    name        = "Admin Users"
    name_plural = "Admin Users"
    icon        = "fa-solid fa-user-shield"

    # Kolom virtual: tombol ganti password
    column_formatters = {
        "change_password": lambda m, a: Markup(
            '<a href="/admin-cp/change-password" '
            'style="display:inline-flex;align-items:center;gap:5px;'
            'padding:4px 11px;border-radius:6px;font-size:12px;font-weight:600;'
            'color:#fff;background:linear-gradient(135deg,#6366f1,#4f46e5);'
            'text-decoration:none;white-space:nowrap;'
            'box-shadow:0 1px 4px rgba(99,102,241,.4);'
            'transition:opacity .18s;" '
            'onmouseover="this.style.opacity=\'0.85\'" '
            'onmouseout="this.style.opacity=\'1\'">'
            '🔑 Ganti Password'
            '</a>'
        ),
    }
    column_labels = {"change_password": "Password"}


# ---------------------------------------------------------------------------
# Admin Dashboard Stats API
# ---------------------------------------------------------------------------
admin_api_router = APIRouter(prefix="/admin-api", tags=["Admin API"])


@admin_api_router.get("/stats")
def get_admin_stats(db: Session = Depends(get_db)):
    total_users          = db.query(User).count()
    total_scans          = db.query(CvAssessment).count()
    total_plans          = db.query(DailyWorkoutPlan).count()
    total_workout_logs   = db.query(WorkoutLog).count()
    total_articles       = db.query(EducationArticle).count()
    total_notifications  = db.query(Notification).count()

    categories = (
        db.query(CvAssessment.kategori_tubuh, func.count(CvAssessment.id))
        .group_by(CvAssessment.kategori_tubuh)
        .all()
    )
    cat_data = {(c[0] if c[0] else "Belum Diketahui"): c[1] for c in categories}

    # Registrations per day (last 7 days), ordered ascending for the chart
    regs = (
        db.query(func.date(User.created_at), func.count(User.id))
        .group_by(func.date(User.created_at))
        .order_by(func.date(User.created_at).desc())
        .limit(7)
        .all()
    )
    reg_data = {str(r[0]): r[1] for r in reversed(regs)}

    avg_bmi = db.query(func.avg(User.bmi_terkini)).scalar() or 0

    return {
        "total_users":          total_users,
        "total_scans":          total_scans,
        "total_plans":          total_plans,
        "total_workout_logs":   total_workout_logs,
        "total_articles":       total_articles,
        "total_notifications":  total_notifications,
        "kategori_tubuh":       cat_data,
        "registrations":        reg_data,
        "avg_bmi":              round(float(avg_bmi), 2),
    }


@admin_api_router.post("/sync-education")
async def admin_sync_education():
    """
    Endpoint trigger sinkronisasi manual MongoDB → MySQL.
    Dipanggil dari tombol di Admin Dashboard.
    """
    try:
        result = await sync_education_from_mongo()
        return {
            "status": "success",
            "message": f"Sinkronisasi selesai! {result['added']} artikel baru, {result['updated']} diperbarui.",
            "detail": result,
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Sinkronisasi gagal: {str(e)}",
        }


@admin_api_router.post("/broadcast-notification")
def admin_broadcast_notification(
    payload: dict,
    db: Session = Depends(get_db),
):
    """
    Kirim notifikasi broadcast ke SEMUA user yang terdaftar.
    Dipanggil dari Admin Dashboard tanpa perlu token user biasa.
    Body: { "title": "...", "message": "...", "type": "system|education|posture|workout" }
    """
    title      = payload.get("title", "").strip()
    message    = payload.get("message", "").strip()
    notif_type = payload.get("type", "system")

    if not title or not message:
        return {"status": "error", "message": "title dan message tidak boleh kosong."}

    all_user_ids = [row[0] for row in db.query(User.id).all()]
    if not all_user_ids:
        return {"status": "error", "message": "Tidak ada user terdaftar."}

    try:
        for uid in all_user_ids:
            db.add(Notification(
                user_id=uid,
                title=title,
                message=message,
                type=notif_type,
                is_read=False,
            ))
        db.commit()
        return {
            "status": "success",
            "message": f"Notifikasi berhasil dikirim ke {len(all_user_ids)} user.",
            "recipients": len(all_user_ids),
        }
    except Exception as e:
        db.rollback()
        return {"status": "error", "message": str(e)}