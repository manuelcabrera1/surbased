from httpx import AsyncClient
import pytest
import pytest_asyncio
from fastapi.testclient import TestClient
from src.main import app
from src.schemas.OrganizationSchema import OrganizationCreate
from src.auth.Auth import create_access_token
from src.models.OrganizationModel import Organization
from src.models.UserModel import User
from uuid import uuid4
from httpx import AsyncClient, ASGITransport
from sqlalchemy import insert, select
from tests.conftest import ADMIN_ID

client = TestClient(app)

@pytest.mark.asyncio
async def test_create_organization_success(db_session, admin_token):
    # Arrange
    organization_data = {
        "name": "Test Organization"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/organizations",
            json=organization_data,
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test Organization"
    assert "id" in data

    # Verificar en la base de datos
    result = await db_session.execute(select(Organization).where(Organization.name == "Test Organization"))
    org = result.unique().scalars().first()
    assert org is not None
    assert org.name == "Test Organization"
    assert str(org.id) == data["id"]

@pytest.mark.asyncio
async def test_create_organization_duplicate_name(db_session, admin_token):
    # Arrange
    organization_data = {
        "name": "Duplicate Organization"
    }
    
    await db_session.execute(insert(Organization).values(organization_data))
    await db_session.commit()   

    # Intentar crear organización con el mismo nombre
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/organizations",
            json=organization_data,
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "This organization already exists"

@pytest.mark.asyncio
async def test_create_organization_missing_name(admin_token):
    # Arrange
    organization_data = {}

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/organizations",
            json=organization_data,
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 422
    assert "name" in response.json()["detail"][0]["loc"]


@pytest.mark.asyncio
async def test_create_organization_unauthorized():
    # Arrange
    organization_data = {}

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/organizations",
            json=organization_data,
        )

    # Assert
    assert response.status_code == 401





    


    


