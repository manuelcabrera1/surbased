from httpx import AsyncClient
import pytest
import pytest_asyncio
from fastapi.testclient import TestClient
from src.main import app
from src.models.OrganizationModel import Organization
from src.models.UserModel import User
from src.models.SurveyModel import Survey
from src.models.CategoryModel import Category
from datetime import date, datetime, timedelta
from uuid import uuid4
from httpx import AsyncClient, ASGITransport
from sqlalchemy import select
from tests.conftest import ADMIN_ID

client = TestClient(app)

@pytest.mark.asyncio
async def test_delete_organization_success(db_session, admin_token):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.delete(
            f"/organizations/{org.id}",
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 204

    # Verificar que la organización ya no existe
    result = await db_session.execute(select(Organization).where(Organization.id == org.id))
    deleted_org = result.unique().scalars().first()
    assert deleted_org is None

@pytest.mark.asyncio
async def test_delete_organization_not_found(db_session, admin_token):
    # Arrange
    non_existent_id = uuid4()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.delete(
            f"/organizations/{non_existent_id}",
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Organization not found"

@pytest.mark.asyncio
async def test_delete_organization_unauthorized():
    # Arrange
    org_id = uuid4()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.delete(
            f"/organizations/{org_id}"
        )

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_delete_organization_forbidden(db_session, researcher_token):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.delete(
            f"/organizations/{org.id}",
            headers={"Authorization": f"Bearer {researcher_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 403

@pytest.mark.asyncio
async def test_delete_organization_not_empty(db_session, admin_token):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    # Crear usuario asociado
    user = User(
        email="test@test.com",
        password="test123",
        name="Test",
        lastname="Test",
        role="researcher",
        organization_id=org.id
    )
    db_session.add(user)
    await db_session.flush()
    await db_session.refresh(user)

    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="organization",
        start_date=date(2025, 5, 24),
        end_date=date(2025, 5, 25),
        organization_id=org.id,
        owner_id=user.id,
        category_id=category.id
    )
    db_session.add(survey)
    await db_session.flush()
    await db_session.refresh(survey)

    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.delete(
            f"/organizations/{org.id}",
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 400


