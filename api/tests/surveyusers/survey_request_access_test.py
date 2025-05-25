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
async def test_request_access_success(db_session, participant_token):
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

    # Crear encuesta pública
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
        response = await ac.post(
            f"/surveys/{survey.id}/users/{owner.id}/request",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == owner.email

@pytest.mark.asyncio
async def test_request_access_unauthorized(db_session):
    # Arrange
    survey_id = str(uuid.uuid4())
    user_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            f"/surveys/{survey_id}/users/{user_id}/request",
            json={
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_request_access_survey_not_found(db_session, participant_token):
    # Arrange
    nonexistent_survey_id = str(uuid.uuid4())
    user_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            f"/surveys/{nonexistent_survey_id}/users/{user_id}/request",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Survey not found"

@pytest.mark.asyncio
async def test_request_access_not_public_survey(db_session, participant_token):
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

    # Crear encuesta privada
    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="private",
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
        response = await ac.post(
            f"/surveys/{survey.id}/users/{owner.id}/request",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "This survey is not public. You can't request access to it."

@pytest.mark.asyncio
async def test_request_access_already_requested(db_session, participant_token):
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

    # Crear encuesta pública
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

    # Asignar usuario a la encuesta con estado requested_pending
    await db_session.execute(
        insert(survey_user).values({
            "user_id": owner.id,
            "survey_id": survey.id,
            "status": "requested_pending"
        })
    )
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            f"/surveys/{survey.id}/users/{owner.id}/request",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "You already requested access to this survey. Wait for the owner response."

@pytest.mark.asyncio
async def test_request_access_already_invited(db_session, participant_token):
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

    # Crear encuesta pública
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
            "user_id": owner.id,
            "survey_id": survey.id,
            "status": "invited_pending"
        })
    )
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            f"/surveys/{survey.id}/users/{owner.id}/request",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "You are already invited to this survey."

@pytest.mark.asyncio
async def test_request_access_already_assigned(db_session, participant_token):
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

    # Crear encuesta pública
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
            "user_id": owner.id,
            "survey_id": survey.id,
            "status": "accepted"
        })
    )
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            f"/surveys/{survey.id}/users/{owner.id}/request",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "You are already assigned to this survey"

@pytest.mark.asyncio
async def test_request_access_rejected_three_times(db_session, participant_token):
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

    # Crear encuesta pública
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

    # Asignar usuario a la encuesta con estado rejected y 3 rechazos
    await db_session.execute(
        insert(survey_user).values({
            "user_id": owner.id,
            "survey_id": survey.id,
            "status": "rejected",
            "invitations_rejected": 3
        })
    )
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            f"/surveys/{survey.id}/users/{owner.id}/request",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "You already rejected this survey 3 times. You can't request access again."
