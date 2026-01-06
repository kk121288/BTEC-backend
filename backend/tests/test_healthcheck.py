from fastapi.testclient import TestClient
from app.main import app


client = TestClient(app)


def test_healthcheck_root():
    resp = client.get("/api/v1/health/")
    assert resp.status_code == 200
    body = resp.json()
    assert "status" in body
    # service returns a dict under "status" with a key "status"
    assert isinstance(body["status"], dict)
    assert body["status"].get("status") == "ok"
