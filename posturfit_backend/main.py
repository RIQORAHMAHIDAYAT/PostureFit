"""
main.py — FastAPI application entry point.

- Initializes the app with metadata.
- Configures CORS for the Flutter frontend.
- Mounts the sqladmin dashboard (protected by login).
- Includes all API routers.
- Creates database tables on startup.
"""

import os
import asyncio
from contextlib import asynccontextmanager

# Muat file .env SEBELUM import lainnya agar os.getenv() bisa membaca nilainya
# pyrefly: ignore [missing-import]
from dotenv import load_dotenv
load_dotenv()

# pyrefly: ignore [missing-import]
from fastapi import FastAPI
# pyrefly: ignore [missing-import]
from fastapi.middleware.cors import CORSMiddleware
# pyrefly: ignore [missing-import]
from fastapi.responses import RedirectResponse
# pyrefly: ignore [missing-import]
from fastapi.staticfiles import StaticFiles
# pyrefly: ignore [missing-import]
from sqladmin import Admin
# pyrefly: ignore [missing-import]
from starlette.middleware.sessions import SessionMiddleware
# pyrefly: ignore [missing-import]
from apscheduler.schedulers.asyncio import AsyncIOScheduler
# pyrefly: ignore [missing-import]
from apscheduler.triggers.interval import IntervalTrigger

from database import engine, Base
from admin_auth import AdminAuthBackend
from admin_change_password import router as change_password_router
from sync_service import sync_education_from_mongo
from admin_panel import (
    UserAdmin, CvAssessmentAdmin, DailyTrackerAdmin,
    DailyWorkoutPlanAdmin, WorkoutTaskAdmin,
    WorkoutLogAdmin, EducationArticleAdmin, NotificationAdmin,
    AdminUserAdmin,
    admin_api_router,
)
from routers import (
    auth_router,
    cv_router,
    tracker_router,
    home_router,
    workout_log_router,
    education_router,
    notification_router,
    progress_router,
)

# Secret key untuk menandatangani session cookie — WAJIB ada di .env
_SESSION_SECRET = os.getenv("SESSION_SECRET")
if not _SESSION_SECRET:
    raise RuntimeError("SESSION_SECRET belum diatur di file .env!")


# ---------------------------------------------------------------------------
# Lifespan — create tables on startup
# ---------------------------------------------------------------------------
# Scheduler untuk sinkronisasi otomatis
_scheduler = AsyncIOScheduler()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: pastikan semua tabel MySQL sudah ada
    Base.metadata.create_all(bind=engine)

    # Jalankan sinkronisasi pertama kali saat server start
    try:
        result = await sync_education_from_mongo()
        print(f"[Startup] Sinkronisasi awal MongoDB->MySQL: {result['added']} baru, {result['updated']} diperbarui.")
    except Exception as e:
        print(f"[Startup] Sinkronisasi awal gagal (MONGO_URI mungkin belum diatur): {e}")

    # Jadwalkan sinkronisasi otomatis setiap 6 jam
    _scheduler.add_job(
        sync_education_from_mongo,
        trigger=IntervalTrigger(hours=6),
        id="sync_education",
        name="Sync Education MongoDB->MySQL",
        replace_existing=True,
    )
    _scheduler.start()
    print("[Scheduler] Sinkronisasi edukasi otomatis aktif (setiap 6 jam).")

    yield

    # Shutdown
    _scheduler.shutdown(wait=False)
    print("[Scheduler] Scheduler dihentikan.")


# ---------------------------------------------------------------------------
# App Initialization
# ---------------------------------------------------------------------------
app = FastAPI(
    title="PostureFit API",
    description=(
        "Backend API for PostureFit — a fitness application that uses "
        "Computer Vision and the SAW (Simple Additive Weighting) method "
        "for personalized workout recommendations.\n\n"
        "All response fields are aligned with Flutter frontend field names."
    ),
    version="2.0.0",
    lifespan=lifespan,
)


# ---------------------------------------------------------------------------
# CORS — allow Flutter web/mobile to call the API
# ---------------------------------------------------------------------------
# Session middleware — MUST be added before Admin so sessions work in auth backend
app.add_middleware(
    SessionMiddleware,
    secret_key=_SESSION_SECRET,
    session_cookie="pf_admin_session",
    max_age=60 * 60 * 8,        # 8 hours
    https_only=False,           # Set True in production with HTTPS
    same_site="lax",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],           # Restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# Admin Dashboard  —  accessible at /admin
# ---------------------------------------------------------------------------
authentication_backend = AdminAuthBackend(secret_key=_SESSION_SECRET)
admin = Admin(
    app,
    engine,
    title="PostureFit Admin",
    templates_dir="templates",
    authentication_backend=authentication_backend,
)
admin.add_view(UserAdmin)
admin.add_view(CvAssessmentAdmin)
admin.add_view(DailyTrackerAdmin)
admin.add_view(DailyWorkoutPlanAdmin)
admin.add_view(WorkoutTaskAdmin)
admin.add_view(WorkoutLogAdmin)
admin.add_view(EducationArticleAdmin)
admin.add_view(NotificationAdmin)
admin.add_view(AdminUserAdmin)

# ---------------------------------------------------------------------------
# Custom Admin Routes  —  HARUS di-include SEBELUM static mount
# ---------------------------------------------------------------------------
app.include_router(change_password_router)

# Mount static files — must come AFTER admin mount so /static doesn't shadow /admin
app.mount("/static", StaticFiles(directory="static"), name="static")



# ---------------------------------------------------------------------------
# API Routers
# ---------------------------------------------------------------------------
app.include_router(auth_router.router)
app.include_router(cv_router.router)
app.include_router(tracker_router.router)
app.include_router(home_router.router)
app.include_router(workout_log_router.router)
app.include_router(education_router.router)
app.include_router(notification_router.router)
app.include_router(progress_router.router)
app.include_router(admin_api_router)


# ---------------------------------------------------------------------------
# Root — redirect straight to the admin dashboard (login page if not authed)
# ---------------------------------------------------------------------------
@app.get("/", tags=["Root"], include_in_schema=False)
def root():
    """Redirect root URL to the admin login page."""
    return RedirectResponse(url="/admin", status_code=302)


# ---------------------------------------------------------------------------
# Health-check endpoint (explicit path so it doesn't conflict with redirect)
# ---------------------------------------------------------------------------
@app.get("/health", tags=["Health"])
def health_check():
    return {
        "status": "success",
        "message": "PostureFit Backend Engine v2.0.0 beroperasi penuh.",
        "endpoints": {
            "auth":         "/api/auth",
            "assessment":   "/api/assessment",
            "tracker":      "/api/tracker",
            "home":         "/api/home",
            "workout_log":  "/api/workout-log",
            "education":    "/api/education",
            "notifications":"/api/notifications",
            "progress":     "/api/progress",
            "admin":        "/admin",
            "docs":         "/docs",
        },
    }