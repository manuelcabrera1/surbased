from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from src.main import app
from src.models.SurveyModel import Survey
from src.models.CategoryModel import Category
from src.models.UserModel import User
from src.models.OrganizationModel import Organization
from src.models.QuestionModel import Question
from src.models.OptionModel import Option
from src.models.TagModel import Tag
from sqlalchemy import select, insert
import uuid
from datetime import date, timedelta
from src.models.SurveyTagModel import survey_tag

@pytest.mark.asyncio
async def test_update_survey_success(db_session, admin_token):
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

    # Crear encuesta inicial
    survey = Survey(
        name="Original Survey",
        description="Original Description",
        scope="public",
        category_id=category.id,
        owner_id=researcher.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.flush()
    await db_session.refresh(survey)


    await db_session.commit()

    # Datos de actualización
    update_data = {
        "name": "Updated Survey",
        "description": "Updated Description",
        "scope": "private",
        "questions": [
            {
                "description": "Original Question modified",
                "type": "open",
                "required": True,
                "options": []
            }
        ],
        "tags": [
            {"name": "New Tag 1"}
        ]
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/surveys/{survey.id}",
            json=update_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == update_data["name"]
    assert data["description"] == update_data["description"]
    assert data["scope"] == update_data["scope"]
    assert len(data["questions"]) == 1
    assert len(data["tags"]) == 1

@pytest.mark.asyncio
async def test_update_survey_unauthorized(db_session):
    # Arrange
    survey_id = str(uuid.uuid4())
    update_data = {
        "name": "Updated Survey",
        "description": "Updated Description"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/surveys/{survey_id}",
            json=update_data
        )

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_update_survey_not_found(db_session, admin_token):
    # Arrange
    nonexistent_survey_id = str(uuid.uuid4())
    update_data = {
        "name": "Updated Survey",
        "description": "Updated Description"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/surveys/{nonexistent_survey_id}",
            json=update_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Survey not found"

@pytest.mark.asyncio
async def test_update_survey_forbidden(db_session, researcher_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    # Crear otra organización
    other_org = Organization(name="Other Organization")
    db_session.add(other_org)
    await db_session.flush()
    await db_session.refresh(other_org)

    # Crear otro investigador en otra organización
    other_researcher = User(
        email="other@test.com",
        password="test1234",
        name="Other",
        lastname="Researcher",
        role="researcher",
        organization_id=other_org.id
    )
    db_session.add(other_researcher)
    await db_session.flush()
    await db_session.refresh(other_researcher)

    # Crear encuesta del otro investigador
    survey = Survey(
        name="Other Survey",
        description="Description",
        scope="private",
        category_id=category.id,
        owner_id=other_researcher.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.flush()
    await db_session.refresh(survey)

    await db_session.commit()

    update_data = {
        "name": "Updated Survey",
        "description": "Updated Description"
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/surveys/{survey.id}",
            json=update_data,
            headers={"Authorization": f"Bearer {researcher_token}"}
        )

    # Assert
    assert response.status_code == 403
    assert response.json()["detail"] == "Forbidden"



@pytest.mark.asyncio
async def test_update_survey_category_not_found(db_session, admin_token):
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
        name="Original Survey",
        description="Original Description",
        scope="public",
        category_id=category.id,
        owner_id=researcher.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    update_data = {
        "category_id": str(uuid.uuid4())  # ID de categoría inexistente
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/surveys/{survey.id}",
            json=update_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Category not found"
