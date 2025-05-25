from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from src.main import app
from src.models.SurveyModel import Survey
from src.models.CategoryModel import Category
from src.models.UserModel import User
from src.models.OrganizationModel import Organization
from src.models.QuestionModel import Question
from src.models.AnswerModel import Answer
from sqlalchemy import select
import uuid
from datetime import date, timedelta

@pytest.mark.asyncio
async def test_get_highlighted_public_surveys_success(db_session, admin_token):
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

    participant = User(
        email="test+1@test.com",
        password="test1234",
        name="Participant",
        lastname="Test",
        role="participant",
        organization_id=organization.id
    )
    db_session.add(researcher)
    db_session.add(participant)
    await db_session.flush()
    await db_session.refresh(researcher)
    await db_session.refresh(participant)

    # Create surveys with different numbers of responses
    surveys = [
        Survey(
            name="Popular Survey",
            description="Description 1",
            scope="public",
            category_id=category.id,
            owner_id=researcher.id,
            start_date=date.today(),
            end_date=date.today() + timedelta(days=7)
        ),
        Survey(
            name="Less Popular Survey",
            description="Description 2",
            scope="public",
            category_id=category.id,
            owner_id=researcher.id,
            start_date=date.today(),
            end_date=date.today() + timedelta(days=14)
        )
    ]
    
    db_session.add_all(surveys)
    await db_session.commit()
    await db_session.refresh(surveys[0])
    await db_session.refresh(surveys[1])

    # Create questions for the surveys
    questions = [
        Question(
            number=1,
            description="Question 1",
            survey_id=surveys[0].id,
            required=True,
            type="open"
        ),
        Question(
            number=1,
            description="Question 1",
            survey_id=surveys[1].id,
            required=True,
            type="open"
        )
    ]
    
    db_session.add_all(questions)
    await db_session.commit()
    await db_session.refresh(questions[0])
    await db_session.refresh(questions[1])

    # Create more answers for the first survey
    answers = [
        Answer(
            question_id=questions[0].id,
            user_id=participant.id,
            text="Answer 1"
        ),
        Answer(
            question_id=questions[0].id,
            user_id=participant.id,
            text="Answer 2"
        ),
        Answer(
            question_id=questions[1].id,
            user_id=participant.id,
            text="Answer 1"
        )
    ]
    
    db_session.add_all(answers)
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            "/surveys/public/highlighted",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()["surveys"]
    assert len(data) == 2
    # The most popular survey should appear first
    assert data[0]["name"] == "Popular Survey"
    assert data[0]["response_count"] == 2
    assert data[1]["name"] == "Less Popular Survey"
    assert data[1]["response_count"] == 1

@pytest.mark.asyncio
async def test_get_highlighted_public_surveys_unauthorized(db_session):
    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/surveys/public/highlighted")

    # Assert
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_get_highlighted_public_surveys_expired(db_session, admin_token):
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

    participant = User(
        email="test+2@test.com",
        password="test1234",
        name="Participant",
        lastname="Test",
        role="participant",
        organization_id=organization.id
    )
    db_session.add(researcher)
    db_session.add(participant)
    await db_session.flush()
    await db_session.refresh(researcher)
    await db_session.refresh(participant)

    # Create surveys with different numbers of responses
    surveys = [
        Survey(
            name="Popular Survey",
            description="Description 1",
            scope="public",
            category_id=category.id,
            owner_id=researcher.id,
            start_date=date.today() - timedelta(days=2),
            end_date=date.today() - timedelta(days=1)
        ),
        Survey(
            name="Less Popular Survey",
            description="Description 2",
            scope="public",
            category_id=category.id,
            owner_id=researcher.id,
            start_date=date.today() - timedelta(days=14),
            end_date=date.today() - timedelta(days=7)
        )
    ]
    
    db_session.add_all(surveys)
    await db_session.commit()
    await db_session.refresh(surveys[0])
    await db_session.refresh(surveys[1])

    # Create questions for the surveys
    questions = [
        Question(
            number=1,
            description="Question 1",
            survey_id=surveys[0].id,
            required=True,
            type="open"
        ),
        Question(
            number=1,
            description="Question 1",
            survey_id=surveys[1].id,
            required=True,
            type="open"
        )
    ]
    
    db_session.add_all(questions)
    await db_session.commit()
    await db_session.refresh(questions[0])
    await db_session.refresh(questions[1])

    # Create more answers for the first survey
    answers = [
        Answer(
            question_id=questions[0].id,
            user_id=participant.id,
            text="Answer 1"
        ),
        Answer(
            question_id=questions[0].id,
            user_id=participant.id,
            text="Answer 2"
        ),
        Answer(
            question_id=questions[1].id,
            user_id=participant.id,
            text="Answer 1"
        )
    ]
    
    db_session.add_all(answers)
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            "/surveys/public/highlighted",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()["surveys"]
    assert len(data) == 0  # It should not show expired surveys
