from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from src.main import app
from src.models.SurveyModel import Survey
from src.models.CategoryModel import Category
from src.models.UserModel import User
from src.models.QuestionModel import Question
from src.models.OptionModel import Option
from sqlalchemy import select
import uuid
from datetime import date, timedelta

@pytest.mark.asyncio
async def test_create_survey_success(db_session, admin_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.commit()
    await db_session.refresh(category)

    # Obtener el usuario admin
    admin = await db_session.execute(select(User).where(User.email == "admin@test.com"))
    admin = admin.unique().scalars().first()

    survey_data = {
        "name": "Test Survey",
        "description": "Test Description",
        "scope": "public",
        "category_id": str(category.id),
        "owner_id": str(admin.id),
        "start_date": str(date.today()),
        "end_date": str(date.today() + timedelta(days=7)),
        "questions": [
            {
                "description": "Test Question 1",
                "type": "single_choice",
                "required": True,
                "options": [
                    {"description": "Option 1", "points": 1},
                    {"description": "Option 2", "points": 2}
                ]
            },
            {
                "description": "Test Question 2",
                "type": "multiple_choice",
                "required": False,
                "options": [
                    {"description": "Option 1", "points": 1},
                    {"description": "Option 2", "points": 2},
                    {"description": "Option 3", "points": 3}
                ]
            }
        ],
        "tags": [
            {"name": "Test Tag 1"},
            {"name": "Test Tag 2"}
        ]
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/surveys",
            json=survey_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == survey_data["name"]
    assert data["description"] == survey_data["description"]
    assert data["scope"] == survey_data["scope"]
    assert data["category_id"] == survey_data["category_id"]
    assert data["owner_id"] == survey_data["owner_id"]
    assert len(data["questions"]) == 2
    assert len(data["tags"]) == 2

@pytest.mark.asyncio
async def test_create_survey_unauthorized(db_session):
    # Arrange
    survey_data = {
        "name": "Test Survey",
        "description": "Test Description",
        "scope": "public",
        "category_id": str(uuid.uuid4()),
        "owner_id": str(uuid.uuid4()),
        "questions": []
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/surveys",
            json=survey_data
        )

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_create_survey_category_not_found(db_session, admin_token):
    # Arrange
    nonexistent_category_id = str(uuid.uuid4())
    admin = await db_session.execute(select(User).where(User.email == "admin@test.com"))
    admin = admin.unique().scalars().first()

    survey_data = {
        "name": "Test Survey",
        "description": "Test Description",
        "scope": "public",
        "category_id": nonexistent_category_id,
        "owner_id": str(admin.id),
        "questions": []
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/surveys",
            json=survey_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Category not found"

@pytest.mark.asyncio
async def test_create_survey_invalid_dates(db_session, admin_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.commit()
    await db_session.refresh(category)

    admin = await db_session.execute(select(User).where(User.email == "admin@test.com"))
    admin = admin.unique().scalars().first()

    survey_data = {
        "name": "Test Survey",
        "description": "Test Description",
        "scope": "public",
        "category_id": str(category.id),
        "owner_id": str(admin.id),
        "start_date": str(date.today() - timedelta(days=1)),  # Fecha en el pasado
        "end_date": str(date.today()),
        "questions": []
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/surveys",
            json=survey_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 422

@pytest.mark.asyncio
async def test_create_survey_duplicate_questions(db_session, admin_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.commit()
    await db_session.refresh(category)

    admin = await db_session.execute(select(User).where(User.email == "admin@test.com"))
    admin = admin.unique().scalars().first()

    survey_data = {
        "name": "Test Survey",
        "description": "Test Description",
        "scope": "public",
        "category_id": str(category.id),
        "owner_id": str(admin.id),
        "questions": [
            {
                "description": "Same Question",
                "type": "single_choice",
                "required": True,
                "options": [
                    {"description": "Option 1", "points": 1},
                    {"description": "Option 2", "points": 2}
                ]
            },
            {
                "description": "Same Question",  # Pregunta duplicada
                "type": "single_choice",
                "required": True,
                "options": [
                    {"description": "Option 1", "points": 1},
                    {"description": "Option 2", "points": 2}
                ]
            }
        ]
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/surveys",
            json=survey_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 400
    assert "Duplicated question description" in response.json()["detail"]

@pytest.mark.asyncio
async def test_create_survey_insufficient_options(db_session, admin_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.commit()
    await db_session.refresh(category)

    admin = await db_session.execute(select(User).where(User.email == "admin@test.com"))
    admin = admin.unique().scalars().first()

    survey_data = {
        "name": "Test Survey",
        "description": "Test Description",
        "scope": "public",
        "category_id": str(category.id),
        "owner_id": str(admin.id),
        "questions": [
            {
                "description": "Test Question",
                "type": "single_choice",
                "required": True,
                "options": [
                    {"description": "Option 1", "points": 1}  # Solo una opción
                ]
            }
        ]
    }

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/surveys",
            json=survey_data,
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 400
    assert "must have at least two options" in response.json()["detail"]
