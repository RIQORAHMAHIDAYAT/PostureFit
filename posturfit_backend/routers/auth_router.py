"""
auth_router.py — /api/auth endpoints.
JWT Authentication (No Firebase).
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from models import User
from auth import hash_password, verify_password, create_access_token, get_current_user
from schemas import (
    ApiResponse, UserOut, ProfileUpdateRequest, 
    LoginRequest, RegisterRequest, Token
)

router = APIRouter(prefix="/api/auth", tags=["Authentication"])


# ---------------------------------------------------------------------------
# POST /api/auth/register — Register new user
# ---------------------------------------------------------------------------
@router.post("/register", response_model=ApiResponse, status_code=status.HTTP_201_CREATED)
def register_user(payload: RegisterRequest, db: Session = Depends(get_db)):
    """Register a new user with email and password."""
    # Check if email exists
    existing_user = db.query(User).filter(User.email == payload.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email sudah terdaftar.",
        )
        
    new_user = User(
        nama_lengkap=payload.name,
        email=payload.email,
        password_hash=hash_password(payload.password)
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return ApiResponse(
        status="success",
        message="Registrasi berhasil. Silakan login.",
        data=UserOut.from_db(new_user).model_dump()
    )


# ---------------------------------------------------------------------------
# POST /api/auth/login — Login with email/password
# ---------------------------------------------------------------------------
@router.post("/login", response_model=Token, status_code=status.HTTP_200_OK)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    """Login and get an access token."""
    user = db.query(User).filter(User.email == payload.email).first()
    
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email atau password salah.",
        )
        
    access_token = create_access_token(data={"sub": user.id})
    
    return Token(
        access_token=access_token,
        token_type="bearer",
        user=UserOut.from_db(user)
    )


# ---------------------------------------------------------------------------
# GET /api/auth/me — Fetch current user profile
# ---------------------------------------------------------------------------
@router.get("/me", response_model=ApiResponse, status_code=status.HTTP_200_OK)
def get_me(current_user: User = Depends(get_current_user)):
    """Return the profile of the currently authenticated user."""
    return ApiResponse(
        status="success",
        message="Data profil berhasil diambil.",
        data=UserOut.from_db(current_user).model_dump(),
    )


# ---------------------------------------------------------------------------
# PUT /api/auth/profile — Update user profile
# ---------------------------------------------------------------------------
@router.put("/profile", response_model=ApiResponse, status_code=status.HTTP_200_OK)
def update_profile(
    payload: ProfileUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update profile data."""
    if payload.name is not None:
        current_user.nama_lengkap = payload.name.strip()
    if payload.age is not None:
        current_user.umur = payload.age
    if payload.height is not None:
        current_user.tinggi_cm = payload.height
    if payload.weight is not None:
        current_user.berat_kg = payload.weight
    if payload.gender is not None:
        current_user.gender = payload.gender

    # Recalculate BMI
    h = float(current_user.tinggi_cm) if current_user.tinggi_cm else 0
    w = float(current_user.berat_kg) if current_user.berat_kg else 0
    if h > 0 and w > 0:
        current_user.bmi_terkini = round(w / ((h / 100) ** 2), 1)

    db.commit()
    db.refresh(current_user)

    return ApiResponse(
        status="success",
        message="Profil berhasil diperbarui.",
        data=UserOut.from_db(current_user).model_dump(),
    )
