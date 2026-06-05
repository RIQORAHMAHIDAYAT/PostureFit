from datetime import datetime, timedelta

# pyrefly: ignore [missing-import]
from fastapi import APIRouter, Depends, HTTPException, status
# pyrefly: ignore [missing-import]
from sqlalchemy.orm import Session

from database import get_db
from models import User, OtpRequest
from auth import hash_password, verify_password, create_access_token, get_current_user
from otp_service import generate_otp, send_otp_email, OTP_EXPIRE_MINUTES
from schemas import (
    ApiResponse, UserOut, ProfileUpdateRequest,
    LoginRequest, GoogleLoginRequest, RegisterRequest, Token,
    SendOtpRequest, VerifyOtpRequest, ResendOtpRequest,
)

router = APIRouter(prefix="/api/auth", tags=["Authentication"])


# ---------------------------------------------------------------------------
# POST /api/auth/send-otp — Langkah 1 Register: Kirim kode OTP ke email
# ---------------------------------------------------------------------------
@router.post("/send-otp", response_model=ApiResponse, status_code=status.HTTP_200_OK)
def send_otp(payload: SendOtpRequest, db: Session = Depends(get_db)):

    # Cek apakah email sudah terdaftar sebagai akun aktif
    existing_user = db.query(User).filter(User.email == payload.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email sudah terdaftar. Silakan login.",
        )

    # Hapus OTP lama yang belum digunakan untuk email ini
    db.query(OtpRequest).filter(
        OtpRequest.email == payload.email,
        OtpRequest.is_used == False
    ).delete()
    db.commit()

    # Buat OTP baru
    otp_code  = generate_otp()
    expires_at = datetime.utcnow() + timedelta(minutes=OTP_EXPIRE_MINUTES)

    otp_record = OtpRequest(
        email=payload.email,
        name=payload.name,
        password_hash=hash_password(payload.password),
        otp_code=otp_code,
        is_used=False,
        expires_at=expires_at,
    )
    db.add(otp_record)
    db.commit()

    # Kirim email OTP
    sent = send_otp_email(
        to_email=payload.email,
        otp_code=otp_code,
        user_name=payload.name,
    )

    if not sent:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Gagal mengirim email verifikasi. Coba lagi.",
        )

    return ApiResponse(
        status="success",
        message=f"Kode OTP telah dikirim ke {payload.email}. Berlaku {OTP_EXPIRE_MINUTES} menit.",
        data={"email": payload.email, "expires_minutes": OTP_EXPIRE_MINUTES},
    )


# ---------------------------------------------------------------------------
# POST /api/auth/verify-otp — Langkah 2 Register: Verifikasi OTP & buat akun
# ---------------------------------------------------------------------------
@router.post("/verify-otp", response_model=Token, status_code=status.HTTP_201_CREATED)
def verify_otp(payload: VerifyOtpRequest, db: Session = Depends(get_db)):
    """
    Langkah 2 registrasi: Verifikasi kode OTP.
    Jika valid → akun User dibuat → JWT token dikembalikan (langsung login).
    """
    otp_record = (
        db.query(OtpRequest)
        .filter(
            OtpRequest.email == payload.email,
            OtpRequest.is_used == False,
        )
        .order_by(OtpRequest.created_at.desc())
        .first()
    )

    if not otp_record:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="OTP tidak ditemukan. Silakan daftar ulang.",
        )

    if datetime.utcnow() > otp_record.expires_at:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Kode OTP sudah kadaluarsa. Silakan minta ulang.",
        )

    if otp_record.otp_code != payload.otp_code.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Kode OTP tidak valid.",
        )

    # Tandai OTP sebagai sudah digunakan
    otp_record.is_used = True
    db.commit()

    # Cek apakah email sudah terdaftar (race condition guard)
    existing_user = db.query(User).filter(User.email == payload.email).first()
    if existing_user:
        access_token = create_access_token(data={"sub": existing_user.id})
        return Token(
            access_token=access_token,
            token_type="bearer",
            user=UserOut.from_db(existing_user),
        )

    # Buat akun User baru
    new_user = User(
        nama_lengkap=otp_record.name,
        email=otp_record.email,
        phone_number=payload.phone_number or "-",
        password_hash=otp_record.password_hash,
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # Kirim email selamat datang
    from otp_service import _build_welcome_email, send_html_email
    try:
        html_body = _build_welcome_email(otp_record.name)
        send_html_email(otp_record.email, "Selamat Datang di PostureFit!", html_body)
    except Exception as e:
        print(f"Failed to send welcome email: {e}")

    # Buat JWT token langsung — user tidak perlu login manual lagi
    access_token = create_access_token(data={"sub": new_user.id})

    return Token(
        access_token=access_token,
        token_type="bearer",
        user=UserOut.from_db(new_user),
    )


# ---------------------------------------------------------------------------
# POST /api/auth/resend-otp — Kirim ulang OTP
# ---------------------------------------------------------------------------
@router.post("/resend-otp", response_model=ApiResponse, status_code=status.HTTP_200_OK)
def resend_otp(payload: ResendOtpRequest, db: Session = Depends(get_db)):
    """Kirim ulang OTP ke email yang sama (untuk kasus email tidak masuk)."""
    # Ambil data OTP terakhir yang belum digunakan
    old_otp = (
        db.query(OtpRequest)
        .filter(OtpRequest.email == payload.email, OtpRequest.is_used == False)
        .order_by(OtpRequest.created_at.desc())
        .first()
    )

    if not old_otp:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Tidak ada permintaan registrasi aktif untuk email ini. Silakan daftar ulang.",
        )

    # Buat OTP baru & perbarui record lama
    new_otp_code = generate_otp()
    old_otp.otp_code   = new_otp_code
    old_otp.expires_at = datetime.utcnow() + timedelta(minutes=OTP_EXPIRE_MINUTES)
    db.commit()

    sent = send_otp_email(
        to_email=payload.email,
        otp_code=new_otp_code,
        user_name=old_otp.name or "Pengguna",
    )

    if not sent:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Gagal mengirim ulang email. Coba lagi.",
        )

    return ApiResponse(
        status="success",
        message=f"Kode OTP baru telah dikirim ke {payload.email}.",
        data={"email": payload.email, "expires_minutes": OTP_EXPIRE_MINUTES},
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
# POST /api/auth/google — Login/Register with Google
# ---------------------------------------------------------------------------
@router.post("/google", response_model=Token, status_code=status.HTTP_200_OK)
def google_login(payload: GoogleLoginRequest, db: Session = Depends(get_db)):
    """
    Endpoint untuk autentikasi via Google.
    Jika email belum ada, otomatis buat User baru dengan password acak.
    """
    user = db.query(User).filter(User.email == payload.email).first()

    if not user:
        # User belum terdaftar, buat akun baru (Upsert)
        # Generate random password hash (karena login pake google)
        import secrets
        random_password = secrets.token_urlsafe(16)
        
        user = User(
            nama_lengkap=payload.name,
            email=payload.email,
            phone_number="-", # default kosongan
            password_hash=hash_password(random_password),
        )
        db.add(user)
        db.commit()
        db.refresh(user)

        # Bisa juga kirim email welcome di sini jika mau
        from otp_service import _build_welcome_email, send_html_email
        try:
            html_body = _build_welcome_email(user.nama_lengkap)
            send_html_email(user.email, "Selamat Datang di PostureFit (Google Sign In)!", html_body)
        except Exception as e:
            print(f"Failed to send welcome email: {e}")

    # Generate JWT Token untuk user (baik lama maupun baru)
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
