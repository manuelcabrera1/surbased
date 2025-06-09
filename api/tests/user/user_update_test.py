from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from src.main import app
from src.models.UserModel import User
from src.models.OrganizationModel import Organization
from sqlalchemy import select
import uuid
import bcrypt
from datetime import date

@pytest.mark.asyncio
async def test_update_user_success(db_session, admin_token):
    # Arrange
    org = Organization(name="Test Organization")
    org2 = Organization(name="Test Organization 2")
    db_session.add(org)
    db_session.add(org2)
    await db_session.flush()
    await db_session.refresh(org)
    await db_session.refresh(org2)

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

    update_data = {
        "email": "updated@test.com",
        "name": "Updated",
        "lastname": "User",
        "organization": str(org2.name),
        "birthdate": "1990-01-01",
        "gender": "male",
        "allow_notifications": True
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/users/{user.id}",
            json=update_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == update_data["email"]
    assert data["name"] == update_data["name"]
    assert data["lastname"] == update_data["lastname"]
    assert data["organization_id"] == str(org2.id)
    assert data["birthdate"] == update_data["birthdate"]
    assert data["gender"] == update_data["gender"]
    assert data["allow_notifications"] == update_data["allow_notifications"]

@pytest.mark.asyncio
async def test_update_user_unauthorized(db_session):
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

    update_data = {
        "email": "updated@test.com",
        "name": "Updated"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/users/{user.id}",
            json=update_data
        )

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_update_user_not_found(db_session, admin_token):
    # Arrange
    nonexistent_id = uuid.uuid4()
    update_data = {
        "email": "updated@test.com",
        "name": "Updated"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/users/{nonexistent_id}",
            json=update_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"

@pytest.mark.asyncio
async def test_update_user_duplicate_email(db_session, admin_token):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    # Crear usuario existente
    hashed_password = bcrypt.hashpw("test123".encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    existing_user = User(
        email="existing@test.com",
        password=hashed_password,
        name="Existing",
        lastname="User",
        role="researcher",
        organization_id=org.id
    )
    db_session.add(existing_user)
    await db_session.flush()

    # Crear usuario a actualizar
    user_to_update = User(
        email="test@test.com",
        password=hashed_password,
        name="Test",
        lastname="Test",
        role="researcher",
        organization_id=org.id
    )
    db_session.add(user_to_update)
    await db_session.flush()
    await db_session.refresh(user_to_update)

    update_data = {
        "email": "existing@test.com"  # Intentar actualizar a un email que ya existe
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/users/{user_to_update.id}",
            json=update_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "Email already registered"
