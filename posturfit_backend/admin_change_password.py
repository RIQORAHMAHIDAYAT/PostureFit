"""
admin_change_password.py — Halaman ganti password untuk admin user.

Route:
  GET  /admin-cp/change-password  — tampilkan form
  POST /admin-cp/change-password  — proses ganti password

Catatan: path sengaja TIDAK di bawah /admin/ karena sqladmin me-mount
         dirinya sebagai sub-aplikasi di prefix /admin/*, sehingga request
         ke /admin/* dicegat sqladmin sebelum FastAPI router dieksekusi.
"""

import os
from pathlib import Path

from fastapi import APIRouter, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from passlib.context import CryptContext

from database import SessionLocal
from models import AdminUser
from admin_auth import _SESSION_TOKEN, _BOOT_TOKEN

_pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Gunakan path absolut agar template ditemukan apapun working directory-nya
_BASE_DIR  = Path(__file__).resolve().parent
templates  = Jinja2Templates(directory=str(_BASE_DIR / "templates"))
router     = APIRouter()


def _is_authenticated(request: Request) -> bool:
    """Cek session yang sama seperti AdminAuthBackend.authenticate()."""
    return (
        request.session.get("token")      == _SESSION_TOKEN and
        request.session.get("boot_token") == _BOOT_TOKEN
    )


@router.get("/admin-cp/change-password", response_class=HTMLResponse, include_in_schema=False)
async def change_password_page(request: Request):
    """Tampilkan form ganti password."""
    if not _is_authenticated(request):
        return RedirectResponse(url="/admin/login", status_code=302)

    username = request.session.get("admin_username", "")
    return templates.TemplateResponse(
        request=request,
        name="sqladmin/change_password.html",
        context={"username": username, "error": None, "success": None},
    )


@router.post("/admin-cp/change-password", response_class=HTMLResponse, include_in_schema=False)
async def change_password_action(
    request: Request,
    current_password:  str = Form(...),
    new_password:      str = Form(...),
    confirm_password:  str = Form(...),
):
    """Proses ganti password admin."""
    if not _is_authenticated(request):
        return RedirectResponse(url="/admin/login", status_code=302)

    username = request.session.get("admin_username", "")

    def render(error=None, success=None):
        return templates.TemplateResponse(
            request=request,
            name="sqladmin/change_password.html",
            context={"username": username, "error": error, "success": success},
        )

    # Validasi input
    if not current_password or not new_password or not confirm_password:
        return render(error="Semua field wajib diisi.")

    if new_password != confirm_password:
        return render(error="Password baru dan konfirmasi tidak cocok.")

    if len(new_password) < 8:
        return render(error="Password baru minimal 8 karakter.")

    db = SessionLocal()
    try:
        admin = db.query(AdminUser).filter(AdminUser.username == username).first()
        if not admin:
            return render(error="Akun admin tidak ditemukan.")

        if not _pwd_context.verify(current_password, admin.password_hash):
            return render(error="Password saat ini tidak benar.")

        admin.password_hash = _pwd_context.hash(new_password)
        db.commit()
    finally:
        db.close()

    return render(success="Password berhasil diubah!")
