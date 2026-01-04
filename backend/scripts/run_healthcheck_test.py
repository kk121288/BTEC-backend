from fastapi.testclient import TestClient
from app.main import app


def run():
    client = TestClient(app)
    resp = client.get("/api/v1/health/")
    assert resp.status_code == 200, f"unexpected status {resp.status_code}"
    body = resp.json()
    assert "status" in body
    assert isinstance(body["status"], dict)
    assert body["status"].get("status") == "ok"
    print("PASSED: healthcheck")


if __name__ == "__main__":
    run()
