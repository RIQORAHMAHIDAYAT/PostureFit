"""
migrate_add_postur_columns.py — Migrasi database: menambah kolom baru ke tabel cv_assessments.

Pastikan MySQL sudah berjalan, lalu jalankan:
    python migrate_add_postur_columns.py
"""

from dotenv import load_dotenv
load_dotenv()

from sqlalchemy import text
from database import engine

def run_migration():
    print("Connecting to database...")
    with engine.connect() as conn:
        # Cek apakah kolom sudah ada sebelum menambahkan (aman dijalankan ulang)
        for col, typedef in [
            ("postur_label", "VARCHAR(50) NULL"),
            ("workout_json",  "TEXT NULL"),
        ]:
            try:
                conn.execute(text(f"ALTER TABLE cv_assessments ADD COLUMN {col} {typedef}"))
                conn.commit()
                print(f"✓ Kolom '{col}' berhasil ditambahkan.")
            except Exception as e:
                err = str(e).lower()
                if "duplicate column" in err or "already exists" in err or "1060" in err:
                    print(f"ℹ Kolom '{col}' sudah ada, dilewati.")
                else:
                    print(f"[Error] {col}: {e}")

    print("\n✅ Migrasi selesai.")

if __name__ == "__main__":
    run_migration()

