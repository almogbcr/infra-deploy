from apps.appoen.app import app


def test_home():
    client = app.test_client()
    res = client.get("/")

    assert res.status_code == 200

    data = res.get_json()
    assert data["message"] == "Hello World"
    assert data["environment"] == "local"
    assert data["log_level"] == "INFO"


def test_health():
    client = app.test_client()
    res = client.get("/health")

    assert res.status_code == 200
    assert res.json == {"status": "healthy"}
