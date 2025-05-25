from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from src.main import app
from src.models.UserModel import User
from src.models.OrganizationModel import Organization
from sqlalchemy import select
import uuid
import bcrypt

@pytest.mark.asyncio
async def test_change_password_success(db_session, admin_token):
    # Arrange
    new_password = "newPassword123"
    password_data = {
        "password": new_password
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            "/users/change-password",
            json=password_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200

    result = await db_session.execute(select(User).where(User.email == "admin@test.com"))
    user = result.unique().scalars().first()

    assert bcrypt.checkpw(new_password.encode('utf-8'), user.password.encode('utf-8'))

@pytest.mark.asyncio
async def test_change_password_unauthorized(db_session):
    # Arrange
    password_data = {
        "password": "newPassword123"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            "/users/change-password",
            json=password_data
        )

    # Assert
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_change_password_invalid_password(db_session, admin_token):
    # Arrange
    password_data = {
        "password": "short"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            "/users/change-password",
            json=password_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 422 
