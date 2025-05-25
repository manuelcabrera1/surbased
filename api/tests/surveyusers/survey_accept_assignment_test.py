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
async def test_accept_assignment_success(db_session, participant_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    organization = Organization(name="Test Organization")
    db_session.add(organization)
    await db_session.flush()
    await db_session.refresh(organization)

    # Crear propietario
    owner = User(
        email="owner@test.com",
        password="test1234",
        name="Owner",
        lastname="Owner",
        role="researcher",
        organization_id=organization.id
    )
    db_session.add(owner)
    await db_session.flush()
    await db_session.refresh(owner)

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
        scope="public",
        category_id=category.id,
        owner_id=owner.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Asignar usuario a la encuesta con estado invited_pending
    await db_session.execute(
        insert(survey_user).values({
            "user_id": participant.id,
            "survey_id": survey.id,
            "status": "invited_pending"
        })
    )
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/users/{participant.id}/surveys/{survey.id}/accept",
            headers={"Authorization": f"Bearer {participant_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["assignment_status"] == "accepted"

@pytest.mark.asyncio
async def test_accept_assignment_unauthorized(db_session):
    # Arrange
    survey_id = str(uuid.uuid4())
    user_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(f"/users/{user_id}/surveys/{survey_id}/accept")

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_accept_assignment_survey_not_found(db_session, participant_token):
    # Arrange
    nonexistent_survey_id = str(uuid.uuid4())
    user_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/users/{user_id}/surveys/{nonexistent_survey_id}/accept",
            headers={"Authorization": f"Bearer {participant_token}"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Survey not found"

@pytest.mark.asyncio
async def test_accept_assignment_user_not_found(db_session, participant_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    organization = Organization(name="Test Organization")
    db_session.add(organization)
    await db_session.flush()
    await db_session.refresh(organization)

    # Crear propietario
    owner = User(
        email="owner@test.com",
        password="test1234",
        name="Owner",
        lastname="Owner",
        role="researcher",
        organization_id=organization.id
    )
    db_session.add(owner)
    await db_session.flush()
    await db_session.refresh(owner)

    # Crear encuesta
    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="public",
        category_id=category.id,
        owner_id=owner.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.put(
            f"/users/{uuid.uuid4()}/surveys/{survey.id}/accept",
            headers={"Authorization": f"Bearer {participant_token}"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"

@pytest.mark.asyncio
async def test_accept_assignment_wrong_status(db_session, participant_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    organization = Organization(name="Test Organization")
    db_session.add(organization)
    await db_session.flush()
    await db_session.refresh(organization)

    # Crear propietario
    owner = User(
        email="owner@test.com",
        password="test1234",
        name="Owner",
        lastname="Owner",
        role="researcher",
        organization_id=organization.id
    )
    db_session.add(owner)
    await db_session.flush()
    await db_session.refresh(owner)

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
        scope="public",
        category_id=category.id,
        owner_id=owner.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Asignar usuario a la encuesta con estado accepted
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
        response = await ac.put(
            f"/users/{participant.id}/surveys/{survey.id}/accept",
            headers={"Authorization": f"Bearer {participant_token}"}
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "This survey can not be accepted"

