from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from tests.conftest import RESEARCHER_ID
from src.main import app
from src.models.UserModel import User
from src.models.OrganizationModel import Organization
from sqlalchemy import select
import uuid
import bcrypt

@pytest.mark.asyncio
async def test_delete_user_success(db_session, admin_token):
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
        response = await ac.request(
            "DELETE",
            f"/users/{user.id}",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 204

    # Verificar que el usuario ya no existe en la base de datos
    result = await db_session.execute(select(User).where(User.id == user.id))
    deleted_user = result.unique().scalars().first()
    assert deleted_user is None

@pytest.mark.asyncio
async def test_delete_user_unauthorized(db_session):
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

    delete_data = {
        "password": "test1234"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.request(
            "DELETE",
            f"/users/{user.id}",
            json=delete_data
        )

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_delete_user_not_found(db_session, admin_token):
    # Arrange
    nonexistent_id = uuid.uuid4()
    delete_data = {
        "password": "test1234"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.request(
            "DELETE",
            f"/users/{nonexistent_id}",
            json=delete_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 404

@pytest.mark.asyncio
async def test_delete_user_wrong_password(db_session, researcher_token):
    # Arrange
    
    #Obtain researcher
    researcher = await db_session.execute(select(User).where(User.email == "researcher@test.com"))
    researcher = researcher.unique().scalars().first()


    delete_data = {
        "password": "wrongpassword"
    }

    # Act

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.request(
            "DELETE",
            f"/users/{researcher.id}",
            json=delete_data,
            headers={"Authorization": f"Bearer {researcher_token}"}
        )

    # Assert
    assert response.status_code == 401
    assert response.json()["detail"] == "Incorrect password"

@pytest.mark.asyncio
async def test_delete_user_forbidden(db_session, researcher_token):
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

    # Crear otro usuario para intentar eliminarlo
    other_user = User(
        email="other@test.com",
        password=hashed_password,
        name="Other",
        lastname="User",
        role="researcher",
        organization_id=org.id
    )
    db_session.add(other_user)
    await db_session.flush()
    await db_session.refresh(other_user)

    delete_data = {
        "password": "test1234"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.request(
            "DELETE",
            f"/users/{other_user.id}",
            json=delete_data,
            headers={"Authorization": f"Bearer {researcher_token}"}
        )

    # Assert
    assert response.status_code == 403
