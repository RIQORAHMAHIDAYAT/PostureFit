import os
# pyrefly: ignore [missing-import]
from sqlalchemy import create_engine, text
# pyrefly: ignore [missing-import]
from dotenv import load_dotenv

load_dotenv()
db_url = os.getenv("DATABASE_URL")
print(f"Connecting to {db_url}...")
engine = create_engine(db_url)

migrations = [
    (
        "ALTER TABLE users ADD COLUMN fokus_pilihan VARCHAR(50);",
        "Added fokus_pilihan column to users table.",
    ),
    (
        "ALTER TABLE users ADD COLUMN foto_profil VARCHAR(500);",
        "Added foto_profil column to users table.",
    ),
]

with engine.begin() as conn:
    for sql, desc in migrations:
        try:
            conn.execute(text(sql))
            print(f"Success: {desc}")
        except Exception as e:
            print(f"Skipped (mungkin sudah ada): {e}")

