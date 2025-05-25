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
async def test_get_survey_by_id_success(db_session, admin_token):
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

    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="public",
        category_id=category.id,
        owner_id=researcher.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/surveys/{survey.id}",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == survey.name
    assert data["description"] == survey.description
    assert data["scope"] == survey.scope
    assert data["category_id"] == str(survey.category_id)
    assert data["owner_id"] == str(survey.owner_id)



@pytest.mark.asyncio
async def test_get_survey_by_id_unauthorized(db_session):
    # Arrange
    survey_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(f"/surveys/{survey_id}")

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_get_survey_by_id_not_found(db_session, admin_token):
    # Arrange
    nonexistent_survey_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/surveys/{nonexistent_survey_id}",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Survey not found"

@pytest.mark.asyncio
async def test_get_survey_by_id_from_other_organization(db_session, researcher_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    other_org = Organization(name="Other Organization")
    db_session.add(other_org)
    await db_session.flush()
    await db_session.refresh(other_org)

    other_researcher = User(
        email="other@test.com",
        password="test1234",
        name="Other",
        lastname="Researcher",
        role="researcher",
        organization_id=other_org.id
    )
    db_session.add(other_researcher)
    await db_session.commit()
    await db_session.refresh(other_researcher)

    survey = Survey(
        name="Other Survey",
        description="Description",
        scope="public",
        category_id=category.id,
        owner_id=other_researcher.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/surveys/{survey.id}",
            headers={"Authorization": f"Bearer {researcher_token}"}
        )

    # Assert
    assert response.status_code == 404
