from httpx import AsyncClient
import pytest
import pytest_asyncio
from fastapi.testclient import TestClient
from src.main import app
from src.models.OrganizationModel import Organization
from src.models.UserModel import User
from src.models.SurveyModel import Survey
from datetime import datetime, timedelta
from uuid import uuid4
from httpx import AsyncClient, ASGITransport
from sqlalchemy import select
from tests.conftest import ADMIN_ID

client = TestClient(app)

@pytest.mark.asyncio
async def test_get_organization_by_id_success(db_session, admin_token):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/organizations/{org.id}",
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == str(org.id)
    assert data["name"] == "Test Organization"
    assert "users_count" in data
    assert "surveys_count" in data

@pytest.mark.asyncio
async def test_get_organization_by_id_not_found(db_session, admin_token):
    # Arrange
    non_existent_id = uuid4()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/organizations/{non_existent_id}",
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Organization not found"

@pytest.mark.asyncio
async def test_get_organization_by_id_unauthorized():
    # Arrange
    org_id = uuid4()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/organizations/{org_id}"
        )

    # Assert
    assert response.status_code == 401

