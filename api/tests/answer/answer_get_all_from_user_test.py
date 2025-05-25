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
from src.models.AnswerModel import Answer
from sqlalchemy import select, insert
import uuid
from datetime import date, timedelta
from src.models.SurveyUserModel import survey_user

@pytest.mark.asyncio
async def test_get_user_answers_success(db_session, participant_token):
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

    # Obtener usuario
    user = await db_session.execute(select(User).where(User.email == "participant@test.com"))
    user = user.unique().scalars().first()

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
    await db_session.flush()
    await db_session.refresh(survey)

    # Crear pregunta
    question = Question(
        number=1,
        description="Test Question",
        type="open",
        survey_id=survey.id,
        required=True
    )
    db_session.add(question)
    await db_session.flush()
    await db_session.refresh(question)

    # Crear respuesta
    answer = Answer(
        user_id=user.id,
        question_id=question.id,
        text="Test Answer"
    )
    db_session.add(answer)
    await db_session.flush()
    await db_session.refresh(answer)

    # Asignar participante a la encuesta
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
            f"/users/{user.id}/answers",
            headers={"Authorization": f"Bearer {participant_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert len(data["answers"]) == 1
    assert data["answers"][0]["survey_id"] == str(survey.id)
    assert len(data["answers"][0]["questions"]) == 1
    assert data["answers"][0]["questions"][0]["text"] == "Test Answer"

@pytest.mark.asyncio
async def test_get_user_answers_unauthorized(db_session):
    # Arrange
    user_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(f"/users/{user_id}/answers")

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_get_user_answers_not_found(db_session, admin_token):
    # Arrange
    nonexistent_user_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/users/{nonexistent_user_id}/answers",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"

@pytest.mark.asyncio
async def test_get_user_answers_forbidden(db_session, participant_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.flush()
    await db_session.refresh(category)

    organization = Organization(name="Test Organization")
    db_session.add(organization)
    await db_session.flush()
    await db_session.refresh(organization)

    # Crear otro usuario
    other_user = User(
        email="other@test.com",
        password="test1234",
        name="Other",
        lastname="User",
        role="participant",
        organization_id=organization.id
    )
    db_session.add(other_user)
    await db_session.flush()
    await db_session.refresh(other_user)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/users/{other_user.id}/answers",
            headers={"Authorization": f"Bearer {participant_token}"}
        )

    # Assert
    assert response.status_code == 403
    assert response.json()["detail"] == "You are not allowed to access this user's answers"
