from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from src.main import app
from src.models.SurveyModel import Survey
from src.models.CategoryModel import Category
from src.models.UserModel import User
from src.models.OrganizationModel import Organization
from src.models.SurveyUserModel import survey_user
from sqlalchemy import select, insert
import uuid
from datetime import date, timedelta

@pytest.mark.asyncio
async def test_get_organization_survey_users_success(db_session, admin_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    organization = Organization(name="Test Organization")
    db_session.add(organization)
    await db_session.flush()
    await db_session.refresh(organization)

    # Crear usuarios en la organización
    users = []
    for i in range(3):
        user = User(
            email=f"user{i}@test.com",
            password="test1234",
            name=f"User{i}",
            lastname=f"Test{i}",
            role="participant",
            organization_id=organization.id
        )
        db_session.add(user)
        users.append(user)
    
    await db_session.flush()
    for user in users:
        await db_session.refresh(user)

    # Crear encuesta de organización
    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="organization",
        category_id=category.id,
        organization_id=organization.id,
        owner_id=users[0].id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Asignar usuarios a la encuesta
    for user in users:
        await db_session.execute(
            insert(survey_user).values({
                "user_id": user.id,
                "survey_id": survey.id,
                "status": "accepted"
            })
        )
    
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/surveys/{survey.id}/users",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert len(data["users"]) == 3
    assert len(data["pending_assignments"]) == 0

@pytest.mark.asyncio
async def test_get_private_survey_users_success(db_session, researcher_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    organization = Organization(name="Test Organization")
    db_session.add(organization)
    await db_session.flush()
    await db_session.refresh(organization)

    # Obtener el investigador actual
    result = await db_session.execute(select(User).where(User.email == "researcher@test.com"))
    researcher = result.unique().scalars().first()

    # Crear encuesta privada
    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="private",
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
            f"/surveys/{survey.id}/users",
            headers={"Authorization": f"Bearer {researcher_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert len(data["users"]) == 1  # Solo el propietario
    assert len(data["pending_assignments"]) == 0

@pytest.mark.asyncio
async def test_get_survey_users_unauthorized(db_session):
    # Arrange
    survey_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(f"/surveys/{survey_id}/users")

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_get_survey_users_not_found(db_session, admin_token):
    # Arrange
    nonexistent_survey_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/surveys/{nonexistent_survey_id}/users",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Survey not found"


@pytest.mark.asyncio
async def test_get_survey_users_with_pending_assignments(db_session, admin_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    organization = Organization(name="Test Organization")
    db_session.add(organization)
    await db_session.flush()
    await db_session.refresh(organization)

    # Crear usuarios
    users = []
    for i in range(3):
        user = User(
            email=f"user{i}@test.com",
            password="test1234",
            name=f"User{i}",
            lastname=f"Test{i}",
            role="participant",
            organization_id=organization.id
        )
        db_session.add(user)
        users.append(user)
    
    await db_session.flush()
    for user in users:
        await db_session.refresh(user)

    # Crear encuesta
    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="organization",
        category_id=category.id,
        organization_id=organization.id,
        owner_id=users[0].id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Asignar usuarios con diferentes estados
    statuses = ["accepted", "invited_pending", "requested_pending"]
    for user, status in zip(users, statuses):
        await db_session.execute(
            insert(survey_user).values({
                "user_id": user.id,
                "survey_id": survey.id,
                "status": status
            })
        )
    
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/surveys/{survey.id}/users",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert len(data["users"]) == 3
    assert len(data["pending_assignments"]) == 2  # Dos usuarios con asignaciones pendientes