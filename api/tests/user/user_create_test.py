from httpx import AsyncClient
import pytest
import pytest_asyncio
from fastapi.testclient import TestClient
from src.main import app
from src.models.OrganizationModel import Organization
from src.models.UserModel import User
from datetime import date
from uuid import uuid4
from httpx import AsyncClient, ASGITransport
from sqlalchemy import select
from tests.conftest import ADMIN_ID

client = TestClient(app)

@pytest.mark.asyncio
async def test_create_user_success(db_session):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    user_data = {
        "email": "test@test.com",
        "role": "participant",
        "name": "Test",
        "lastname": "User",
        "organization": "Test Organization",
        "password": "test1234",
        "birthdate": "1990-01-01",
        "gender": "male"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/users/create",
            json=user_data
        )

    # Assert
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == user_data["email"]
    assert data["name"] == user_data["name"]
    assert data["lastname"] == user_data["lastname"]
    assert data["role"] == user_data["role"]
    assert data["organization_id"] == str(org.id)
    assert "id" in data
    assert "password" not in data


@pytest.mark.asyncio
async def test_create_user_duplicate_email(db_session):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    # Crear usuario inicial
    user_data = {
        "email": "researcher@test.com",
        "role": "researcher",
        "name": "Test",
        "lastname": "User",
        "organization": "Test Organization",
        "password": "test1234",
        "birthdate": "1990-01-01",
        "gender": "male"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/users/create",
            json=user_data
        )

    # Assert
    assert response.status_code == 400

@pytest.mark.asyncio
async def test_create_user_nonexistent_organization(db_session):
    # Arrange
   
    user_data = {
        "email": "test@test.com",
        "role": "participant",
        "name": "Test",
        "lastname": "User",
        "organization": "Non existent organization",
        "password": "test1234",
        "birthdate": "1990-01-01",
        "gender": "male"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/users/create",
            json=user_data
        )

    # Assert
    assert response.status_code == 404




