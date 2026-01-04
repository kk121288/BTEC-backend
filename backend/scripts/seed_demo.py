"""
Seed demo data: creates demo users (student/teacher/admin) using project's crud helpers.
Run: python backend/scripts/seed_demo.py
"""
import os
from sqlmodel import Session
from app.core.db import engine, init_db
from app import crud
from app.models import UserCreate
from datetime import datetime
import pathlib

def seed():
    init_db(Session(engine))
    # Create uploads dir
    uploads = pathlib.Path("uploads")
    uploads.mkdir(exist_ok=True)
    demo_file = uploads / "demo.txt"
    if not demo_file.exists():
        demo_file.write_text("This is a demo file for Keitagorus.")
    # Create demo users via crud (if not exist)
    with Session(engine) as session:
        for email, role in [("student1@example.com", "student"), ("teacher1@example.com", "teacher"), ("admin@example.com", "admin")]:
            existing = crud.get_user_by_email(session=session, email=email)
            if not existing:
                pw = "secret123"
                user_in = UserCreate(email=email, password=pw)
                user = crud.create_user(session=session, user_create=user_in)
                print(f"Created: {email} (pw: {pw})")
            else:
                print(f"Exists: {email}")
    print("Seed complete.")

if __name__ == "__main__":
    seed()
