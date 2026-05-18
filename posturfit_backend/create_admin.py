"""
create_admin.py — Script CLI untuk membuat dan mengelola akun admin.

Jalankan dengan:
    python create_admin.py              → buat admin baru (interactive)
    python create_admin.py --list       → tampilkan semua admin
    python create_admin.py --delete <username>   → hapus admin
    python create_admin.py --reset <username>    → reset password admin
"""

import sys
import getpass
import argparse
from datetime import datetime

from passlib.context import CryptContext
from sqlalchemy.exc import IntegrityError

from database import Base, engine, SessionLocal
from models import AdminUser

# Pastikan tabel admin_users sudah dibuat
Base.metadata.create_all(bind=engine)

_pwd = CryptContext(schemes=["bcrypt"], deprecated="auto")


def _get_db():
    return SessionLocal()


# ── Buat admin baru ──────────────────────────────────────────────────────────
def cmd_create():
    print("\n=== Buat Akun Admin Baru ===\n")

    username = input("Username  : ").strip()
    if not username:
        print("[ERROR] Username tidak boleh kosong.")
        sys.exit(1)

    email = input("Email (opsional, Enter untuk skip): ").strip() or None

    while True:
        password = getpass.getpass("Password  : ")
        confirm  = getpass.getpass("Konfirmasi: ")
        if password == confirm:
            break
        print("[!] Password tidak cocok. Coba lagi.\n")

    if len(password) < 6:
        print("[ERROR] Password minimal 6 karakter.")
        sys.exit(1)

    db = _get_db()
    try:
        admin = AdminUser(
            username      = username,
            email         = email,
            password_hash = _pwd.hash(password),
            is_active     = True,
            created_at    = datetime.utcnow(),
        )
        db.add(admin)
        db.commit()
        print(f"\n[OK] Admin '{username}' berhasil dibuat!\n")
    except IntegrityError:
        db.rollback()
        print(f"[ERROR] Username '{username}' atau email sudah dipakai.")
        sys.exit(1)
    finally:
        db.close()


# ── List semua admin ─────────────────────────────────────────────────────────
def cmd_list():
    db = _get_db()
    try:
        admins = db.query(AdminUser).order_by(AdminUser.created_at).all()
        if not admins:
            print("\n[INFO] Belum ada akun admin.\n")
            return
        print(f"\n{'ID':<5} {'Username':<20} {'Email':<30} {'Aktif':<8} Dibuat")
        print("-" * 80)
        for a in admins:
            status = "Ya" if a.is_active else "Nonaktif"
            email  = a.email or "-"
            print(f"{a.id:<5} {a.username:<20} {email:<30} {status:<8} {a.created_at}")
        print()
    finally:
        db.close()


# ── Hapus admin ──────────────────────────────────────────────────────────────
def cmd_delete(username: str):
    db = _get_db()
    try:
        admin = db.query(AdminUser).filter(AdminUser.username == username).first()
        if not admin:
            print(f"[ERROR] Admin '{username}' tidak ditemukan.")
            sys.exit(1)
        confirm = input(f"Hapus admin '{username}'? (ketik 'ya' untuk konfirmasi): ")
        if confirm.lower() != "ya":
            print("Dibatalkan.")
            return
        db.delete(admin)
        db.commit()
        print(f"[OK] Admin '{username}' berhasil dihapus.")
    finally:
        db.close()


# ── Reset password ───────────────────────────────────────────────────────────
def cmd_reset(username: str):
    db = _get_db()
    try:
        admin = db.query(AdminUser).filter(AdminUser.username == username).first()
        if not admin:
            print(f"[ERROR] Admin '{username}' tidak ditemukan.")
            sys.exit(1)

        while True:
            password = getpass.getpass("Password baru  : ")
            confirm  = getpass.getpass("Konfirmasi     : ")
            if password == confirm:
                break
            print("[!] Password tidak cocok. Coba lagi.\n")

        if len(password) < 6:
            print("[ERROR] Password minimal 6 karakter.")
            sys.exit(1)

        admin.password_hash = _pwd.hash(password)
        db.commit()
        print(f"[OK] Password admin '{username}' berhasil direset.")
    finally:
        db.close()


# ── Main ─────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Kelola akun admin PostureFit")
    group  = parser.add_mutually_exclusive_group()
    group.add_argument("--list",   action="store_true",  help="Tampilkan semua admin")
    group.add_argument("--delete", metavar="USERNAME",   help="Hapus akun admin")
    group.add_argument("--reset",  metavar="USERNAME",   help="Reset password admin")

    args = parser.parse_args()

    if args.list:
        cmd_list()
    elif args.delete:
        cmd_delete(args.delete)
    elif args.reset:
        cmd_reset(args.reset)
    else:
        cmd_create()
