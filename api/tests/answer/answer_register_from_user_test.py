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
async def test_register_answers_success(db_session, participant_token):
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
        email="test@test.com",
        password="test1234",
        name="Owner",
        lastname="Owner",
        role="researcher",
        organization_id=organization.id
    )
    db_session.add(owner)
    await db_session.flush()
    await db_session.refresh(owner)

    # Obtener participante
    participant = await db_session.execute(select(User).where(User.email == "participant@test.com"))
    participant = participant.unique().scalars().first()

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
        response = await ac.post(
            f"/surveys/{survey.id}/answers",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "questions": [
                    {
                        "id": str(question.id),
                        "type": "open",
                        "text": "Test Answer",
                        "options": []
                    }
                ]
            }
        )

    # Assert
    assert response.status_code == 201    
    data = response.json()
    assert data["survey_id"] == str(survey.id)
    assert len(data["questions"]) == 1
    assert data["questions"][0]["text"] == "Test Answer"
    assert data["questions"][0]["type"] == "open"

@pytest.mark.asyncio
async def test_register_answers_unauthorized(db_session):
    # Arrange
    survey_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            f"/surveys/{survey_id}/answers",
            json={
                "questions": []
            }
        )

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_register_answers_survey_not_found(db_session, participant_token):
    # Arrange
    nonexistent_survey_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            f"/surveys/{nonexistent_survey_id}/answers",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "questions": []
            }
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "Survey not found"

@pytest.mark.asyncio
async def test_register_answers_not_assigned(db_session, participant_token):
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
        email="test@test.com",
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
            f"/surveys/{survey.id}/answers",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "questions": []
            }
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "User not assigned to the survey"

@pytest.mark.asyncio
async def test_register_answers_not_in_organization(db_session, participant_token):
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

    # Crear propietario
    owner = User(
        email="test@test.com",
        password="test1234",
        name="Owner",
        lastname="Owner",
        role="researcher",
        organization_id=organization1.id
    )
    db_session.add(owner)
    await db_session.flush()
    await db_session.refresh(owner)

    # Crear encuesta de organización
    survey = Survey(
        name="Test Survey",
        description="Test Description",
        scope="organization",
        category_id=category.id,
        owner_id=owner.id,
        organization_id=organization1.id,
        start_date=date.today(),
        end_date=date.today() + timedelta(days=7)
    )
    db_session.add(survey)
    await db_session.commit()
    await db_session.refresh(survey)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            f"/surveys/{survey.id}/answers",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "questions": []
            }
        )

    # Assert
    assert response.status_code == 400
    assert response.json()["detail"] == "User not assigned to the organization"

@pytest.mark.asyncio
async def test_register_answers_question_not_found(db_session, participant_token):
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
        email="test@test.com",
        password="test1234",
        name="Owner",
        lastname="Owner",
        role="researcher",
        organization_id=organization.id
    )
    db_session.add(owner)
    await db_session.flush()
    await db_session.refresh(owner)

    # Obtener participante
    participant = await db_session.execute(select(User).where(User.email == "participant@test.com"))
    participant = participant.unique().scalars().first()

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
        response = await ac.post(
            f"/surveys/{survey.id}/answers",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "questions": [
                    {
                        "id": str(uuid.uuid4()),
                        "type": "open",
                        "text": "Test Answer",
                        "options": []
                    }
                ]
            }
        )

    # Assert
    assert response.status_code == 400

@pytest.mark.asyncio
async def test_register_answers_invalid_open_question(db_session, participant_token):
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
        email="test@test.com",
        password="test1234",
        name="Owner",
        lastname="Owner",
        role="researcher",
        organization_id=organization.id
    )
    db_session.add(owner)
    await db_session.flush()
    await db_session.refresh(owner)

    # Obtener participante
    participant = await db_session.execute(select(User).where(User.email == "participant@test.com"))
    participant = participant.unique().scalars().first()

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
        response = await ac.post(
            f"/surveys/{survey.id}/answers",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "questions": [
                    {
                        "id": str(question.id),
                        "type": "open",
                        "text": None,
                        "options": []
                    }
                ]
            }
        )

    # Assert
    assert response.status_code == 400


@pytest.mark.asyncio
async def test_register_answers_option_not_found(db_session, participant_token):
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
        email="test@test.com",
        password="test1234",
        name="Owner",
        lastname="Owner",
        role="researcher",
        organization_id=organization.id
    )
    db_session.add(owner)
    await db_session.flush()
    await db_session.refresh(owner)

    # Obtener participante
    participant = await db_session.execute(select(User).where(User.email == "participant@test.com"))
    participant = participant.unique().scalars().first()

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
        type="multiple_choice",
        survey_id=survey.id,
        required=True
    )
    db_session.add(question)
    await db_session.flush()
    await db_session.refresh(question)

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
        response = await ac.post(
            f"/surveys/{survey.id}/answers",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "questions": [
                    {
                        "id": str(question.id),
                        "type": "multiple_choice",
                        "text": None,
                        "options": []
                    }
                ]
            }
        )

    # Assert
    assert response.status_code == 400
