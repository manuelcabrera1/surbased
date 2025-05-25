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
async def test_get_user_by_id_success(db_session, admin_token):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    hashed_password = bcrypt.hashpw("test1234".encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
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

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/users/{user.id}",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == str(user.id)
    assert data["email"] == user.email
    assert data["name"] == user.name
    assert data["lastname"] == user.lastname
    assert data["role"] == user.role
    assert data["organization_id"] == str(org.id)

@pytest.mark.asyncio
async def test_get_user_by_id_not_found(db_session, admin_token):
    # Arrange
    nonexistent_id = uuid.uuid4()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/users/{nonexistent_id}",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"

@pytest.mark.asyncio
async def test_get_user_by_id_unauthorized(db_session):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    hashed_password = bcrypt.hashpw("test1234".encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
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

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(f"/users/{user.id}")

    # Assert
    assert response.status_code == 401
