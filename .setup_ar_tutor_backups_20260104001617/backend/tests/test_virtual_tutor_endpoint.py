from fastapi.testclient import TestClient
from sqlmodel import SQLModel, create_engine, Session

from backend.app.main import app
from app.models import User, StudentProgress, StudentProgressCreate

def setup_in_memory_db():
    engine = create_engine("sqlite:///:memory:", echo=False)
    SQLModel.metadata.create_all(engine)
    return engine

def test_virtual_tutor_endpoint(monkeypatch):
    engine = setup_in_memory_db()
    # prepare DB with a user and progress
    with Session(engine) as session:
        user = User(email="client@example.com", hashed_password="x")
        session.add(user)
        session.commit()
        session.refresh(user)
        sp = StudentProgress.model_validate(StudentProgressCreate(module_name="Module A", progress=40, struggling=False), update={"user_id": user.id})
        session.add(sp)
        session.commit()

    # override deps.get_db to use our in-memory engine
    from app.api import deps
    def get_db_override():
        with Session(engine) as s:
            yield s
    monkeypatch.setattr(deps, "get_db", get_db_override)

    # override current user dependency to return our test user
    monkeypatch.setattr(deps, "get_current_user", lambda session, token=None: user)

    client = TestClient(app)
    resp = client.get("/api/v1/virtual-tutor/recommendations")
    assert resp.status_code == 200
    data = resp.json()
    assert isinstance(data, list)
    assert any(item["module_name"] == "Module A" for item in data)
