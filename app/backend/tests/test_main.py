from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert "status" in data
    assert "database" in data
    assert "uptime_seconds" in data

def test_hr_message_endpoint():
    response = client.get("/api/hr-message")
    assert response.status_code == 200
    data = response.json()
    assert "greeting" in data
    assert "core_message" in data
    assert "candidate_quote" in data
    assert "recipient" in data

def test_reaction_validation_failure():
    invalid_payload = {
        "sender_name": "A",
        "reaction_type": "Thumbs Up"
    }
    response = client.post("/api/reactions", json=invalid_payload)
    assert response.status_code == 422
