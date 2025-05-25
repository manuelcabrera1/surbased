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
async def test_assign_user_success(db_session, admin_token):
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

    # Crear usuario a asignar
    user = User(
        email="test@test.com",
        password="test1234",
        name="Test",
        lastname="User",
        role="participant",
        organization_id=organization.id
    )
    db_session.add(user)
    await db_session.flush()
    await db_session.refresh(user)

    # Crear encuesta
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
            f"/surveys/{survey.id}/users/add",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={
                "email": user.email,
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == user.email

@pytest.mark.asyncio
async def test_assign_user_unauthorized(db_session):
    # Arrange
    survey_id = str(uuid.uuid4())
    user_email = "test@test.com"

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            f"/surveys/{survey_id}/users/add",
            json={
                "email": user_email,
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_assign_user_survey_not_found(db_session, admin_token):
    # Arrange
    nonexistent_survey_id = str(uuid.uuid4())
    user_email = "test@test.com"

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            f"/surveys/{nonexistent_survey_id}/users/add",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={
                "email": user_email,
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Survey not found"

@pytest.mark.asyncio
async def test_assign_user_not_found(db_session, admin_token):
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

    # Crear encuesta
    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="organization",
        category_id=category.id,
        organization_id=organization.id,
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
            f"/surveys/{survey.id}/users/add",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={
                "email": "nonexistent@test.com",
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"

@pytest.mark.asyncio
async def test_assign_user_already_assigned(db_session, admin_token):
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

    # Crear usuario
    user = User(
        email="test@test.com",
        password="test1234",
        name="Test",
        lastname="User",
        role="participant",
        organization_id=organization.id
    )
    db_session.add(user)
    await db_session.flush()
    await db_session.refresh(user)

    # Crear encuesta
    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="organization",
        category_id=category.id,
        organization_id=organization.id,
        owner_id=owner.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Asignar usuario a la encuesta
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
        response = await ac.post(
            f"/surveys/{survey.id}/users/add",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={
                "email": user.email,
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == f"User with email {user.email} already assigned to this survey"

@pytest.mark.asyncio
async def test_assign_owner_to_survey(db_session, admin_token):
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
        scope="organization",
        category_id=category.id,
        organization_id=organization.id,
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
            f"/surveys/{survey.id}/users/add",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={
                "email": owner.email,
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == f"User with email {owner.email} is the owner of the survey"

@pytest.mark.asyncio
async def test_assign_user_to_ended_survey(db_session, admin_token):
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

    # Crear usuario
    user = User(
        email="test@test.com",
        password="test1234",
        name="Test",
        lastname="User",
        role="participant",
        organization_id=organization.id
    )
    db_session.add(user)
    await db_session.flush()
    await db_session.refresh(user)

    # Crear encuesta finalizada
    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="organization",
        category_id=category.id,
        organization_id=organization.id,
        owner_id=owner.id,
        start_date=date.today() - timedelta(days=14),
        end_date=date.today() - timedelta(days=7)
    )
    
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            f"/surveys/{survey.id}/users/add",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={
                "email": user.email,
                "notification_title": "Test Notification",
                "notification_body": "Test Body"
            }
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "You can not invite participants to answer a survey that has already ended"


