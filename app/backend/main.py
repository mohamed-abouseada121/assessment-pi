import os
import time
from datetime import datetime, timezone
from typing import Optional
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
try:
    import psycopg2
    from psycopg2.extras import RealDictCursor
except ImportError:
    psycopg2 = None
    RealDictCursor = None

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "appdb")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")
APP_ENV = os.getenv("APP_ENV", "production")

START_TIME = time.time()

def get_db_connection():
    if psycopg2 is None:
        raise RuntimeError("PostgreSQL driver (psycopg2) is not installed")
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        connect_timeout=3
    )

def init_db():
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS hr_reactions (
                    id SERIAL PRIMARY KEY,
                    sender_name VARCHAR(100) NOT NULL,
                    reaction_type VARCHAR(50) NOT NULL,
                    note TEXT,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                );
            """)
            conn.commit()
        conn.close()
    except Exception:
        pass

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    yield

app = FastAPI(
    title="Cloud & DevOps Showcase API",
    description="Backend service demonstrating automated 3-tier cloud deployment on AWS",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ReactionRequest(BaseModel):
    sender_name: str = Field(..., min_length=2, max_length=100, example="Sarah (Recruiting Partner)")
    reaction_type: str = Field(..., example="Impressive Setup! 🚀")
    note: Optional[str] = Field(None, max_length=500, example="Great IaC modularity and clean CI/CD.")

@app.get("/health")
def health_check():
    db_status = "connected"
    db_latency_ms = None
    try:
        t0 = time.time()
        conn = get_db_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT 1;")
        conn.close()
        db_latency_ms = round((time.time() - t0) * 1000, 2)
    except Exception as exc:
        db_status = f"unavailable: {str(exc)}"

    return {
        "status": "healthy" if db_status == "connected" else "degraded",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "uptime_seconds": round(time.time() - START_TIME, 2),
        "database": {
            "status": db_status,
            "engine": "PostgreSQL (Amazon RDS)",
            "latency_ms": db_latency_ms
        },
        "environment": APP_ENV
    }

@app.get("/api/hr-message")
def get_hr_message():
    db_connected = False
    total_notes = 0
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT COUNT(*) FROM hr_reactions;")
            row = cur.fetchone()
            if row:
                total_notes = row[0]
        conn.close()
        db_connected = True
    except Exception:
        db_connected = False

    return {
        "recipient": "Valued Recruiter & Engineering Leaders",
        "greeting": "Hello and welcome to my automated cloud infrastructure assessment! 👋",
        "core_message": (
            "Thank you for reviewing my submission. This application was built to demonstrate "
            "production-grade DevOps fundamentals: clean Infrastructure as Code (Terraform), "
            "isolated VPC networking, managed RDS PostgreSQL, hardened containerization, "
            "automated CI/CD pipelines, and proactive CloudWatch observability."
        ),
        "candidate_quote": "Excellence in DevOps is not just about making it work; it is about making it repeatable, secure, and observable.",
        "database_connected": db_connected,
        "recorded_feedback_count": total_notes
    }

@app.post("/api/reactions", status_code=status.HTTP_201_CREATED)
def submit_reaction(payload: ReactionRequest):
    try:
        conn = get_db_connection()
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                INSERT INTO hr_reactions (sender_name, reaction_type, note)
                VALUES (%s, %s, %s)
                RETURNING id, sender_name, reaction_type, note, created_at;
            """, (payload.sender_name, payload.reaction_type, payload.note))
            new_record = cur.fetchone()
            conn.commit()
        conn.close()
        return {
            "message": "Reaction successfully stored in Amazon RDS PostgreSQL!",
            "data": new_record
        }
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Database temporarily unreachable: {str(exc)}"
        )

@app.get("/api/stats")
def get_stats():
    reactions = []
    try:
        conn = get_db_connection()
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT id, sender_name, reaction_type, note, created_at FROM hr_reactions ORDER BY id DESC LIMIT 10;")
            reactions = cur.fetchall()
        conn.close()
    except Exception:
        pass

    return {
        "recent_reactions": reactions,
        "server_time": datetime.now(timezone.utc).isoformat()
    }
