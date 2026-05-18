"""
database.py — SQLAlchemy engine, SessionLocal, Base, and get_db dependency.

Uses MySQL via PyMySQL driver. Adjust the URL below if your local
MySQL credentials differ.
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# ---------------------------------------------------------------------------
# Database URL  –  mysql+pymysql://user:password@host:port/db_name
# ---------------------------------------------------------------------------
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://root:@127.0.0.1:3306/posturfit"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    pool_pre_ping=True,      # Auto-reconnect on stale connections
    pool_size=10,             # Keep up to 10 persistent connections
    max_overflow=20,          # Allow up to 20 additional connections under load
    echo=False,               # Set True for SQL debugging
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


# ---------------------------------------------------------------------------
# FastAPI dependency  –  yields a DB session per request and always closes it.
# ---------------------------------------------------------------------------
def get_db():
    """Dependency that provides a SQLAlchemy session for the duration of a
    single request, then closes it to prevent connection leaks."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()