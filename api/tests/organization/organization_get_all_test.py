from datetime import datetime, timedelta
from httpx import AsyncClient
import pytest
import pytest_asyncio
from fastapi.testclient import TestClient
from src.main import app
from src.models.OrganizationModel import Organization
from uuid import uuid4
from httpx import AsyncClient, ASGITransport
from sqlalchemy import delete, insert, select
from tests.conftest import ADMIN_ID

client = TestClient(app)

@pytest.mark.asyncio
async def test_get_all_organizations_success(db_session, admin_token):
    # Arrange
    org1 = Organization(name="Test Organization 1")
    org2 = Organization(name="Test Organization 2")
    db_session.add(org1)
    db_session.add(org2)
    await db_session.commit()


    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            "/organizations",
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 200

    data = response.json()["organizations"]
    assert len(data) == 3 # 2 organizations + 1 created at setup_test_data
    assert any(org["name"] == "Test Organization 1" for org in data)
    assert any(org["name"] == "Test Organization 2" for org in data)



@pytest.mark.asyncio
async def test_get_all_organizations_unauthorized():
    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            "/organizations"
        )

    # Assert
    assert response.status_code == 401







    

