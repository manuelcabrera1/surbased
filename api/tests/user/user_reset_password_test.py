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
async def test_reset_password_success(db_session):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    hashed_password = bcrypt.hashpw("test123".encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    user = User(
        email="test@test.com",
        password=hashed_password,
        name="Test",
        lastname="Test",
        role="researcher",
        organization_id=org.id
    )
    db_session.add(user)
    await db_session.flush()
    await db_session.refresh(user)

    new_password = "newPassword123"
    reset_data = {
        "email": "test@test.com",
        "password": new_password
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            "/users/reset-password",
            json=reset_data
        )

    # Assert
    assert response.status_code == 200

    # Verificar que la contraseña se cambió correctamente
    result = await db_session.execute(select(User).where(User.email == "test@test.com"))
    updated_user = result.unique().scalars().first()
    assert bcrypt.checkpw(new_password.encode('utf-8'), updated_user.password.encode('utf-8'))

@pytest.mark.asyncio
async def test_reset_password_nonexistent_user(db_session):
    # Arrange
    reset_data = {
        "email": "nonexistent@test.com",
        "password": "newPassword123"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            "/users/reset-password",
            json=reset_data
        )

    # Assert
    assert response.status_code == 404  

@pytest.mark.asyncio
async def test_reset_password_invalid_password(db_session):
    # Arrange
    reset_data = {
        "email": "test@test.com",
        "password": "short"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            "/users/reset-password",
            json=reset_data
        )

    # Assert
    assert response.status_code == 422 

