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
async def test_get_surveys_by_owner_success(db_session, admin_token):
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

    # Create researcher's surveys
    surveys = [
        Survey(
            name="Public Survey",
            description="Description 1",
            scope="public",
            category_id=category.id,
            owner_id=researcher.id,
            start_date=date.today(),
            end_date=date.today() + timedelta(days=7)
        ),
        Survey(
            name="Private Survey",
            description="Description 2",
            scope="private",
            category_id=category.id,
            owner_id=researcher.id,
            start_date=date.today(),
            end_date=date.today() + timedelta(days=14)
        )
    ]
    
    db_session.add_all(surveys)
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/surveys/owner/{researcher.id}",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()["surveys"]
    assert len(data) == 2
    assert any(survey["name"] == "Public Survey" for survey in data)
    assert any(survey["name"] == "Private Survey" for survey in data)



@pytest.mark.asyncio
async def test_get_surveys_by_owner_unauthorized(db_session):
    # Arrange
    researcher_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(f"/surveys/owner/{researcher_id}")

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_get_surveys_by_owner_not_found(db_session, admin_token):
    # Arrange
    nonexistent_owner_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/surveys/owner/{nonexistent_owner_id}",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Owner not found"

@pytest.mark.asyncio
async def test_get_surveys_by_owner_forbidden(db_session, researcher_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    # Create another organization
    other_org = Organization(name="Other Organization")
    db_session.add(other_org)
    await db_session.flush()
    await db_session.refresh(other_org)

    # Create another researcher in another organization
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

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/surveys/owner/{other_researcher.id}",
            headers={"Authorization": f"Bearer {researcher_token}"}
        )

    # Assert
    assert response.status_code == 403
    assert response.json()["detail"] == "Forbidden"

