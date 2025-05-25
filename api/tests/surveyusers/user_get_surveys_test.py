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
async def test_get_user_surveys_success(db_session, admin_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    organization = Organization(name="Test Organization")
    db_session.add(organization)
    await db_session.flush()
    await db_session.refresh(organization)


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


    user = User(
        email="test+1@test.com",
        password="test1234",
        name="Participant",
        lastname="Participant",
        role="participant",
        organization_id=organization.id
    )
    db_session.add(user)
    await db_session.flush()
    await db_session.refresh(user)

    # Crear encuestas
    surveys = []
    
    survey = Survey(
        name=f"Test Survey",
        description=f"Test Description",
        scope="organization",
        category_id=category.id,
        owner_id=owner.id,
        organization_id=organization.id,
            start_date=date.today(),
            end_date=date.today() + timedelta(days=7)
    )
    survey2 = Survey(
        name=f"Test Survey 2",
        description=f"Test Description 2",
        scope="organization",
        category_id=category.id,
        owner_id=owner.id,
        organization_id=organization.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    db_session.add(survey)
    db_session.add(survey2)
    await db_session.flush()
    await db_session.refresh(survey)
    await db_session.refresh(survey2)
    
    surveys.append(survey)  
    surveys.append(survey2)

    # Asignar encuestas al participante
    statuses = ["accepted", "rejected"]
    for survey, status in zip(surveys, statuses):
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
            f"/users/{user.id}/surveys",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert len(data["surveys"]) == 1 #only one survey is returned because the other one is rejected

@pytest.mark.asyncio
async def test_get_user_surveys_unauthorized(db_session):
    # Arrange
    user_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(f"/users/{user_id}/surveys")

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_get_user_surveys_not_found(db_session, admin_token):
    # Arrange
    nonexistent_user_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/users/{nonexistent_user_id}/surveys",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"

@pytest.mark.asyncio
async def test_get_user_surveys_forbidden(db_session, participant_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    organization = Organization(name="Test Organization")
    db_session.add(organization)
    await db_session.flush()
    await db_session.refresh(organization)

    # Crear otro participante
    other_participant = User(
        email="other@test.com",
        password="test1234",
        name="Other",
        lastname="Participant",
        role="participant",
        organization_id=organization.id
    )
    db_session.add(other_participant)
    await db_session.commit()
    await db_session.refresh(other_participant)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/users/{other_participant.id}/surveys",
            headers={"Authorization": f"Bearer {participant_token}"}
        )

    # Assert
    assert response.status_code == 403
    assert response.json()["detail"] == "Forbidden"


