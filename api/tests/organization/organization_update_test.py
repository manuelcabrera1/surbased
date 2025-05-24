from httpx import AsyncClient
import pytest
import pytest_asyncio
from fastapi.testclient import TestClient
from src.main import app
from src.models.OrganizationModel import Organization
from datetime import datetime, timedelta
from uuid import uuid4
from httpx import AsyncClient, ASGITransport
from sqlalchemy import select
from tests.conftest import ADMIN_ID

client = TestClient(app)

@pytest.mark.asyncio
async def test_update_organization_success(db_session, admin_token):
    # Arrange
    org = Organization(name="Original Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    update_data = {
        "name": "Updated Organization"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/organizations/{org.id}",
            json=update_data,
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Updated Organization"
    assert data["id"] == str(org.id)

@pytest.mark.asyncio
async def test_update_organization_not_found(db_session, admin_token):
    # Arrange
    non_existent_id = uuid4()
    update_data = {
        "name": "Updated Organization"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/organizations/{non_existent_id}",
            json=update_data,
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "Organization not found"

@pytest.mark.asyncio
async def test_update_organization_duplicate_name(db_session, admin_token):
    # Arrange
    org1 = Organization(name="Organization 1")
    org2 = Organization(name="Organization 2")
    db_session.add(org1)
    db_session.add(org2)
    await db_session.flush()
    await db_session.refresh(org1)
    await db_session.refresh(org2)

    update_data = {
        "name": "Organization 2"  # Intentando cambiar el nombre al de org2
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/organizations/{org1.id}",
            json=update_data,
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "Organization name already registered"

@pytest.mark.asyncio
async def test_update_organization_unauthorized():
    # Arrange
    org_id = uuid4()
    update_data = {
        "name": "Updated Organization"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/organizations/{org_id}",
            json=update_data
        )

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_update_organization_forbidden(db_session, researcher_token):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    update_data = {
        "name": "Updated Organization"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/organizations/{org.id}",
            json=update_data,
            headers={"Authorization": f"Bearer {researcher_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 403
