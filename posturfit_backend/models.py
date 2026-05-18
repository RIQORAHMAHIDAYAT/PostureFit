"""
models.py — SQLAlchemy ORM models for the PostureFit database.

Field names are aligned with the Flutter frontend expectations.
"""

import uuid
from datetime import datetime, date

from sqlalchemy import (
    Column, String, Integer, Float, DateTime, Date, Text,
    ForeignKey, Boolean, UniqueConstraint, DECIMAL
)
from sqlalchemy.orm import relationship

from database import Base


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------
def _generate_uuid() -> str:
    return str(uuid.uuid4())


# ---------------------------------------------------------------------------
# User
# ---------------------------------------------------------------------------
class User(Base):
    __tablename__ = "users"

    id                = Column(String(50), primary_key=True, default=_generate_uuid)
    nama_lengkap      = Column(String(100), nullable=False)           # → frontend: name
    email             = Column(String(100), unique=True, nullable=False)
    password_hash     = Column(String(255), nullable=False)
    gender            = Column(String(20), nullable=True)             # Laki-laki / Perempuan
    fokus_utama       = Column(String(50), nullable=True)             # → frontend: goal
    umur              = Column(Integer, nullable=True)                 # → frontend: age
    tinggi_cm         = Column(DECIMAL(5, 2), nullable=True)          # → frontend: height
    berat_kg          = Column(DECIMAL(5, 2), nullable=True)          # → frontend: weight
    lingkar_perut_cm  = Column(DECIMAL(5, 2), nullable=True)
    bmi_terkini       = Column(DECIMAL(4, 2), nullable=True)          # → frontend: bmi
    created_at        = Column(DateTime, default=datetime.utcnow)

    # Relationships
    assessments   = relationship("CvAssessment",     back_populates="user", cascade="all, delete-orphan")
    trackers      = relationship("DailyTracker",     back_populates="user", cascade="all, delete-orphan")
    workout_plans = relationship("DailyWorkoutPlan", back_populates="user", cascade="all, delete-orphan")
    workout_logs  = relationship("WorkoutLog",       back_populates="user", cascade="all, delete-orphan")
    notifications = relationship("Notification",     back_populates="user", cascade="all, delete-orphan")


# ---------------------------------------------------------------------------
# CvAssessment
# ---------------------------------------------------------------------------
class CvAssessment(Base):
    __tablename__ = "cv_assessments"

    id              = Column(String(50), primary_key=True, default=_generate_uuid)
    user_id         = Column(String(50), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    tanggal_scan    = Column(DateTime, default=datetime.utcnow)
    image_url       = Column(String(500), nullable=True)
    tinggi_cm       = Column(DECIMAL(5, 2), nullable=True)
    berat_kg        = Column(DECIMAL(5, 2), nullable=True)
    lingkar_perut_cm= Column(DECIMAL(5, 2), nullable=True)
    umur            = Column(Integer, nullable=True)
    bmi_kalkulasi   = Column(DECIMAL(4, 2), nullable=True)
    kategori_tubuh  = Column(String(50), nullable=True)
    rekomendasi     = Column(Text, nullable=True)                     # ← BARU: teks rekomendasi SAW
    saw_scores      = Column(Text, nullable=True)                     # ← BARU: JSON string skor SAW

    # Relationships
    user = relationship("User", back_populates="assessments")


# ---------------------------------------------------------------------------
# DailyTracker  —  Aligned with Flutter ActivityEntity
# ---------------------------------------------------------------------------
class DailyTracker(Base):
    __tablename__ = "daily_trackers"

    id                  = Column(String(50), primary_key=True, default=_generate_uuid)
    user_id             = Column(String(50), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    tanggal             = Column(Date, nullable=False)
    # Hidration
    hidrasi_ml          = Column(Integer, nullable=True, default=0)   # → hydrationCurrent
    hydration_target_ml = Column(Integer, nullable=True, default=2000) # → hydrationTarget
    # Sleep
    tidur_jam           = Column(DECIMAL(4, 2), nullable=True, default=0)  # → sleepDuration
    # Activity percentages (0-100)
    olahraga            = Column(Integer, nullable=True, default=0)   # → olahraga (%)
    nutrisi             = Column(Integer, nullable=True, default=0)   # → nutrisi (%)
    tidur_persen        = Column(Integer, nullable=True, default=0)   # → tidur (%)
    skor_aktivitas      = Column(Integer, nullable=True, default=0)   # → activityScore (0-100)

    __table_args__ = (
        UniqueConstraint("user_id", "tanggal", name="uq_user_tanggal"),
    )

    # Relationships
    user = relationship("User", back_populates="trackers")


# ---------------------------------------------------------------------------
# DailyWorkoutPlan
# ---------------------------------------------------------------------------
class DailyWorkoutPlan(Base):
    __tablename__ = "daily_workout_plans"

    id               = Column(String(50), primary_key=True, default=_generate_uuid)
    user_id          = Column(String(50), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    tanggal_rencana  = Column(Date, nullable=False)
    tema_latihan     = Column(String(150), nullable=True)
    target_kalori    = Column(Integer, nullable=True)
    estimasi_menit   = Column(Integer, nullable=True)

    # Relationships
    user  = relationship("User", back_populates="workout_plans")
    tasks = relationship("WorkoutTask", back_populates="plan", cascade="all, delete-orphan")


# ---------------------------------------------------------------------------
# WorkoutTask
# ---------------------------------------------------------------------------
class WorkoutTask(Base):
    __tablename__ = "workout_tasks"

    id             = Column(String(50), primary_key=True, default=_generate_uuid)
    plan_id        = Column(String(50), ForeignKey("daily_workout_plans.id", ondelete="CASCADE"), nullable=False)
    nama_latihan   = Column(String(100), nullable=False)
    target_otot    = Column(String(100), nullable=True)
    set_reps       = Column(String(50), nullable=True)
    is_completed   = Column(Boolean, default=False)

    # Relationships
    plan = relationship("DailyWorkoutPlan", back_populates="tasks")


# ---------------------------------------------------------------------------
# WorkoutLog  —  Riwayat sesi workout yang diselesaikan
# Fields aligned with Flutter WorkoutLogController
# ---------------------------------------------------------------------------
class WorkoutLog(Base):
    __tablename__ = "workout_logs"

    id          = Column(String(50), primary_key=True, default=_generate_uuid)
    user_id     = Column(String(50), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title       = Column(String(150), nullable=False)       # → frontend: title
    category    = Column(String(100), nullable=True)        # → frontend: category
    duration    = Column(String(50), nullable=True)         # → frontend: duration (e.g. "15 menit")
    calories    = Column(String(50), nullable=True)         # → frontend: calories (e.g. "85 kcal")
    image       = Column(String(500), nullable=True)        # → frontend: image (URL/asset path)
    logged_at   = Column(DateTime, default=datetime.utcnow) # → frontend: date

    # Relationships
    user = relationship("User", back_populates="workout_logs")


# ---------------------------------------------------------------------------
# EducationArticle  —  Artikel edukasi postur & kebugaran
# Fields aligned with Flutter EducationController / EducationItem.fromJson
# ---------------------------------------------------------------------------
class EducationArticle(Base):
    __tablename__ = "education_articles"

    id          = Column(String(50), primary_key=True, default=_generate_uuid)
    judul       = Column(String(255), nullable=False)       # → frontend: judul / title
    ringkasan   = Column(Text, nullable=True)               # → frontend: ringkasan / summary
    gambar      = Column(String(500), nullable=True)        # → frontend: gambar / image_url
    kategori    = Column(String(100), nullable=True)        # → frontend: kategori
    sumber      = Column(String(150), nullable=True)        # → frontend: sumber
    tips        = Column(Text, nullable=True)               # JSON array string → frontend: tips
    link_direct = Column(String(500), nullable=True)        # → frontend: link_direct
    updated_at  = Column(DateTime, default=datetime.utcnow) # → frontend: updated_at


# ---------------------------------------------------------------------------
# Notification  —  Notifikasi per-user
# Fields aligned with Flutter NotificationController / NotificationItem
# ---------------------------------------------------------------------------
class Notification(Base):
    __tablename__ = "notifications"

    id         = Column(String(50), primary_key=True, default=_generate_uuid)
    user_id    = Column(String(50), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title      = Column(String(200), nullable=False)        # → frontend: title
    message    = Column(Text, nullable=False)               # → frontend: message
    type       = Column(String(50), nullable=True)          # posture/workout/education/system
    is_read    = Column(Boolean, default=False)             # → frontend: isRead
    created_at = Column(DateTime, default=datetime.utcnow) # → frontend: time

    # Relationships
    user = relationship("User", back_populates="notifications")


# ---------------------------------------------------------------------------
# AdminUser  —  Akun admin untuk dashboard backend
# Password di-hash dengan bcrypt, dikelola via script create_admin.py
# ---------------------------------------------------------------------------
class AdminUser(Base):
    __tablename__ = "admin_users"

    id            = Column(Integer, primary_key=True, autoincrement=True)
    username      = Column(String(50), unique=True, nullable=False)
    email         = Column(String(100), unique=True, nullable=True)
    password_hash = Column(String(255), nullable=False)
    is_active     = Column(Boolean, default=True)
    created_at    = Column(DateTime, default=datetime.utcnow)