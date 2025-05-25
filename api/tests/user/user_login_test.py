from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from src.main import app
from src.models.UserModel import User
from sqlalchemy import select
import bcrypt

@pytest.mark.asyncio
async def test_login_success(db_session):
    # Arrange
    login_data = {
        "username": "admin@test.com",
        "password": "test123"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/users/login",
            data=login_data,
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

@pytest.mark.asyncio
async def test_login_invalid_password(db_session):
    # Arrange
    login_data = {
        "username": "admin@test.com",
        "password": "wrongpassword"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/users/login",
            data=login_data,
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )

    # Assert
    assert response.status_code == 401
    assert response.json()["detail"] == "Authentication failed"

@pytest.mark.asyncio
async def test_login_nonexistent_user(db_session):
    # Arrange
    login_data = {
        "username": "nonexistent@test.com",
        "password": "test1234"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/users/login",
            data=login_data,
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"
