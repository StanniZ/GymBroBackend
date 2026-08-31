from fastapi.testclient import TestClient

from app.main import app


def test_apple_login_rejects_invalid_token() -> None:
    response = TestClient(app).post(
        "/auth/apple",
        json={
            "identity_token": "invalid-token",
            "raw_nonce": "0123456789abcdef0123456789abcdef",
        },
    )

    assert response.status_code == 401
    assert response.json() == {
        "detail": "Invalid Apple identity token",
    }
