from httpx import AsyncClient
import pytest
import pytest_asyncio
from fastapi.testclient import TestClient
from src.main import app
from src.models.OrganizationModel import Organization
from src.models.UserModel import User
from datetime import datetime, timedelta
from uuid import uuid4
from httpx import AsyncClient, ASGITransport
from sqlalchemy import select
from tests.conftest import ADMIN_ID

client = TestClient(app)

@pytest.mark.asyncio
async def test_get_users_in_organization_success(db_session, admin_token):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    user1 = User(
        email="user1@test.com",
        password="test123",
        name="User1",
        lastname="Test",
        role="researcher",
        organization_id=org.id
    )
    user2 = User(
        email="user2@test.com",
        password="test123",
        name="User2",
        lastname="Test",
        role="participant",
        organization_id=org.id
    )
    db_session.add(user1)
    db_session.add(user2)
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/organizations/{org.id}/users",
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()["users"]
    assert len(data) == 2
    assert data[0]["email"] == "user1@test.com"
    assert data[1]["email"] == "user2@test.com"

@pytest.mark.asyncio
async def test_get_users_in_organization_empty(db_session, admin_token):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/organizations/{org.id}/users",
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()["users"]
    assert len(data) == 0

@pytest.mark.asyncio
async def test_get_users_in_organization_not_found(db_session, admin_token):
    # Arrange
    non_existent_id = uuid4()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/organizations/{non_existent_id}/users",
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 404

@pytest.mark.asyncio
async def test_get_users_in_organization_unauthorized():
    # Arrange
    org_id = uuid4()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/organizations/{org_id}/users"
        )

    # Assert
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_get_users_in_organization_forbidden(db_session, researcher_token):
    # Arrange
    org = Organization(name="Organization 1")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    user = User(
        email="test@test.com",
        password="test123",
        name="Test",
        lastname="Test",
        role="researcher",
        organization_id=org.id  # Usuario pertenece a org1
    )
    db_session.add(user)
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/organizations/{org.id}/users",
            headers={"Authorization": f"Bearer {researcher_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 403


