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
async def test_remove_assignment_success(db_session, admin_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    organization = Organization(name="Test Organization")
    db_session.add(organization)
    await db_session.flush()
    await db_session.refresh(organization)

    # Crear investigador
    researcher = User(
        email="test@test.com",
        password="test1234",
        name="Researcher",
        lastname="Researcher",
        role="researcher",
        organization_id=organization.id
    )
    db_session.add(researcher)
    await db_session.flush()
    await db_session.refresh(researcher)

    # Crear participante
    participant = User(
        email="test+1@test.com",
        password="test1234",
        name="Participant",
        lastname="Participant",
        role="participant",
        organization_id=organization.id
    )
    db_session.add(participant)
    await db_session.flush()
    await db_session.refresh(participant)

    # Crear encuesta
    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="organization",
        category_id=category.id,
        owner_id=researcher.id,
        organization_id=organization.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Asignar participante a la encuesta
    await db_session.execute(
        insert(survey_user).values({
            "user_id": participant.id,
            "survey_id": survey.id,
            "status": "accepted"
        })
    )
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.request(
            "DELETE",
            f"/users/{survey.id}/users/delete",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={"email": participant.email}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert len(data["users"]) == 0

@pytest.mark.asyncio
async def test_remove_assignment_unauthorized(db_session):
    # Arrange
    survey_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.request(
            "DELETE",
            f"/users/{survey_id}/users/delete",
            json={"email": "test@test.com"}
        )

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_remove_assignment_survey_not_found(db_session, researcher_token):
    # Arrange
    nonexistent_survey_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.request(
            "DELETE",
            f"/users/{nonexistent_survey_id}/users/delete",
            headers={"Authorization": f"Bearer {researcher_token}"},
            json={"email": "test@test.com"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Survey not found"

@pytest.mark.asyncio
async def test_remove_assignment_participant_not_found(db_session, researcher_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    organization = Organization(name="Test Organization")
    db_session.add(organization)
    await db_session.flush()
    await db_session.refresh(organization)

    # Crear investigador
    researcher = User(
        email="test@test.com",
        password="test1234",
        name="Researcher",
        lastname="Researcher",
        role="researcher",
        organization_id=organization.id
    )
    db_session.add(researcher)
    await db_session.flush()
    await db_session.refresh(researcher)

    # Crear encuesta
    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="organization",
        category_id=category.id,
        owner_id=researcher.id,
        organization_id=organization.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.request(
            "DELETE",
            f"/users/{survey.id}/users/delete",
            headers={"Authorization": f"Bearer {researcher_token}"},
            json={"email": "nonexistent@test.com"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Participant not found"

@pytest.mark.asyncio
async def test_remove_assignment_not_assigned(db_session, researcher_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    organization = Organization(name="Test Organization")
    db_session.add(organization)
    await db_session.flush()
    await db_session.refresh(organization)

    # Crear investigador
    researcher = User(
        email="test@test.com",
        password="test1234",
        name="Researcher",
        lastname="Researcher",
        role="researcher",
        organization_id=organization.id
    )
    db_session.add(researcher)
    await db_session.flush()
    await db_session.refresh(researcher)

    # Crear participante
    participant = User(
        email="test+1@test.com",
        password="test1234",
        name="Participant",
        lastname="Participant",
        role="participant",
        organization_id=organization.id
    )
    db_session.add(participant)
    await db_session.flush()
    await db_session.refresh(participant)

    # Crear encuesta
    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="organization",
        category_id=category.id,
        owner_id=researcher.id,
        organization_id=organization.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.request(
            "DELETE",
            f"/users/{survey.id}/users/delete",
            headers={"Authorization": f"Bearer {researcher_token}"},
            json={"email": participant.email}
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "Participant not assigned to this survey"

@pytest.mark.asyncio
async def test_remove_assignment_forbidden(db_session, researcher_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    # Crear organizaciones diferentes
    organization1 = Organization(name="Test Organization 1")
    organization2 = Organization(name="Test Organization 2")
    db_session.add(organization1)
    db_session.add(organization2)
    await db_session.flush()
    await db_session.refresh(organization1)
    await db_session.refresh(organization2)

    # Crear investigador de otra organización
    researcher = User(
        email="test@test.com",
        password="test1234",
        name="Researcher",
        lastname="Researcher",
        role="researcher",
        organization_id=organization2.id
    )
    db_session.add(researcher)
    await db_session.flush()
    await db_session.refresh(researcher)

    # Crear participante
    participant = User(
        email="test+1@test.com",
        password="test1234",
        name="Participant",
        lastname="Participant",
        role="participant",
        organization_id=organization1.id
    )
    db_session.add(participant)
    await db_session.flush()
    await db_session.refresh(participant)

    # Crear encuesta
    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="organization",
        category_id=category.id,
        owner_id=researcher.id,
        organization_id=organization1.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Asignar participante a la encuesta
    await db_session.execute(
        insert(survey_user).values({
            "user_id": participant.id,
            "survey_id": survey.id,
            "status": "accepted"
        })
    )
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.request(
            "DELETE",
            f"/users/{survey.id}/users/delete",
            headers={"Authorization": f"Bearer {researcher_token}"},
            json={"email": participant.email}
        )

    # Assert
    assert response.status_code == 403
    assert response.json()["detail"] == "Forbidden"
