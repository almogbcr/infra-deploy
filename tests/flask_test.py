
from app.app import app

def test_home():
    client = app.test_client()
    res = client.get("/")

    assert res.status_code == 200
    assert b"DevOps Assignment" in res.data
def test_health():
    client = app.test_client()
    res = client.get("/health")

    assert res.status_code == 200
    assert res.json == {"status": "healthy"}
