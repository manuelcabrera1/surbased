from httpx import AsyncClient
import pytest
import pytest_asyncio
from fastapi.testclient import TestClient
from src.models.CategoryModel import Category
from src.main import app
from src.models.OrganizationModel import Organization
from src.models.UserModel import User
from src.models.SurveyModel import Survey
from datetime import date, datetime, timedelta
from uuid import uuid4
from httpx import AsyncClient, ASGITransport
from sqlalchemy import select
from tests.conftest import ADMIN_ID

client = TestClient(app)

@pytest.mark.asyncio
async def test_get_surveys_in_organization_success(db_session, admin_token):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.flush()
    await db_session.refresh(org)

    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)


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


    survey1 = Survey(
        name="Survey 1",
        description="Description 1",
        scope="organization",
        start_date=date(2025, 5, 24),
        end_date=date(2025, 5, 25),
        organization_id=org.id,
        owner_id=user.id,
        category_id=category.id
    )
    
    survey2 = Survey(
        name="Survey 2",
        description="Description 2",
        scope="organization",
        start_date=date(2025, 5, 24),
        end_date=date(2025, 5, 26),
        organization_id=org.id,
        owner_id=user.id,
        category_id=category.id
    )
    
    db_session.add(survey1)
    db_session.add(survey2)
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/organizations/{org.id}/surveys",
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()["surveys"]
    assert len(data) == 2

    # Verify that the surveys are sorted by end_date in descending order
    assert data[0]["name"] == "Survey 2"  # Farthest end_date
    assert data[1]["name"] == "Survey 1"  # Closest end_date

@pytest.mark.asyncio
async def test_get_surveys_in_organization_empty(db_session, admin_token):
    # Arrange
    org = Organization(name="Test Organization")
    db_session.add(org)
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/organizations/{org.id}/surveys",
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()["surveys"]
    assert len(data) == 0

@pytest.mark.asyncio
async def test_get_surveys_in_organization_not_found(db_session, admin_token):
    # Arrange
    non_existent_id = uuid4()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/organizations/{non_existent_id}/surveys",
            headers={"Authorization": f"Bearer {admin_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 404

@pytest.mark.asyncio
async def test_get_surveys_in_organization_unauthorized():
    # Arrange
    org_id = uuid4()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/organizations/{org_id}/surveys"
        )

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_get_surveys_in_organization_forbidden(db_session, researcher_token):
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
        organization_id=org.id
    )
    db_session.add(user)
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/organizations/{org.id}/surveys",
            headers={"Authorization": f"Bearer {researcher_token}", "Content-Type": "application/json"}
        )

    # Assert
    assert response.status_code == 403
