from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from src.main import app
from src.models.UserModel import User
from src.models.OrganizationModel import Organization
from sqlalchemy import select
import uuid

@pytest.mark.asyncio
async def test_get_all_users_success(db_session, admin_token):

    # Arrange

    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    user = User(
        email="test@test.com",
        password="test1234",
        name="Test",
        lastname="Test",
        role="researcher",
        organization_id=org.id  # Usuario pertenece a org1
    )

    user2 = User(
        email="test2@test.com",
        password="test1234",
        name="Test2",
        lastname="Test2",
        role="researcher",
        organization_id=org.id
    )
    
    db_session.add(user)
    db_session.add(user2)
    await db_session.flush()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            "/users",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert "users" in data
    assert len(data["users"]) > 0
    # Verificar que todos los usuarios tienen los campos requeridos
    for user in data["users"]:
        assert "id" in user
        assert "email" in user
        assert "role" in user


@pytest.mark.asyncio
async def test_get_all_users_filter_by_role_and_organization(db_session, admin_token):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    user = User(
        email="test@test.com",
        password="test1234",
        name="Test",
        lastname="Test",
        role="participant",
        organization_id=org.id  # Usuario pertenece a org1
    )

    user2 = User(
        email="test2@test.com",
        password="test1234",
        name="Test2",
        lastname="Test2",
        role="participant",
        organization_id=org.id
    )
    db_session.add(user)
    db_session.add(user2)
    await db_session.flush()
    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/users?role=participant&org={org.id}",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()["users"]
    assert len(data) == 2

    assert any(user["email"] == "test@test.com" for user in data)
    assert any(user["email"] == "test2@test.com" for user in data)



@pytest.mark.asyncio
async def test_get_all_users_unauthorized(db_session, researcher_token):
    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            "/users",
            headers={"Authorization": f"Bearer {researcher_token}"}
        )

    # Assert
    assert response.status_code == 403




