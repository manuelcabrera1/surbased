from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from src.main import app
from src.models.SurveyModel import Survey
from src.models.CategoryModel import Category
from src.models.UserModel import User
from src.models.OrganizationModel import Organization
from sqlalchemy import select
import uuid
from datetime import date, timedelta

@pytest.mark.asyncio
@pytest.mark.parametrize("scope, expected_count", [("public", 2), ("organization", 1), ("private", 1)])
async def test_get_surveys_by_scope_public_success(db_session, admin_token, scope, expected_count):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    organization = Organization(name="Test Organization")
    db_session.add(organization)
    await db_session.flush()
    await db_session.refresh(organization)


    researcher = User(
        email="test@test.com",
        password="test1234",
        name="Test",
        lastname="Test",
        role="researcher",
        organization_id=organization.id
    )

    db_session.add(researcher)
    await db_session.flush()
    await db_session.refresh(researcher)

    # Crear encuestas públicas
    surveys = [
        Survey(
            name="Public Survey 1",
            description="Description 1",
            scope="public",
            category_id=category.id,
            owner_id=researcher.id,
            start_date=date.today(),
            end_date=date.today() + timedelta(days=7)
        ),
        Survey(
            name="Public Survey 2",
            description="Description 2",
            scope="public",
            category_id=category.id,
            owner_id=researcher.id,
            start_date=date.today(),
            end_date=date.today() + timedelta(days=14)
        ),
        Survey(
            name="Organization Survey",
            description="Description 4",
            scope="organization",
            category_id=category.id,
            owner_id=researcher.id,
            start_date=date.today(),
            end_date=date.today() + timedelta(days=14)
        ),
        Survey(
            name="Private Survey",
            description="Description 3",
            scope="private",
            category_id=category.id,
            owner_id=researcher.id,
            start_date=date.today(),
            end_date=date.today() + timedelta(days=14)
        ),
    ]
    
    db_session.add_all(surveys)
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/surveys/?scope={scope}",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()["surveys"]
    assert len(data) == expected_count


@pytest.mark.asyncio
async def test_get_surveys_by_scope_unauthorized(db_session):
    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/surveys/?scope=public")

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_get_surveys_by_scope_forbidden(db_session, researcher_token):
    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            "/surveys/?scope=private",
            headers={"Authorization": f"Bearer {researcher_token}"}
        )

    # Assert
    assert response.status_code == 403
    assert response.json()["detail"] == "Forbidden"



