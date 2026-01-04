from sqlmodel import SQLModel, create_engine, Session

from app.models import User, StudentProgress, StudentProgressCreate
from app.virtual_tutor import recommend_remediation

def setup_in_memory_db():
    engine = create_engine("sqlite:///:memory:", echo=False)
    SQLModel.metadata.create_all(engine)
    return engine

def test_recommend_remediation_basic():
    engine = setup_in_memory_db()
    with Session(engine) as session:
        # create test user
        user = User(email="test@example.com", hashed_password="x")
        session.add(user)
        session.commit()
        session.refresh(user)

        # add progress entries
        sp1 = StudentProgressCreate(module_name="Electrical Basics", progress=50, struggling=False)
        sp2 = StudentProgressCreate(module_name="Advanced Circuits", progress=30, struggling=True)
        s1 = StudentProgress.model_validate(sp1, update={"user_id": user.id})
        s2 = StudentProgress.model_validate(sp2, update={"user_id": user.id})
        session.add(s1)
        session.add(s2)
        session.commit()

        recs = recommend_remediation(session=session, user=user, threshold=60)
        modules = {r["module_name"] for r in recs}
        assert "Electrical Basics" in modules
        assert "Advanced Circuits" in modules
