from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from src.main import app
from src.models.UserModel import User
from src.models.UserFcmTokenModel import UserFcmToken
from sqlalchemy import select
import uuid

@pytest.mark.asyncio
async def test_delete_fcm_token_success(db_session, participant_token):
    # Arrange
    # Obtener participante
    participant = await db_session.execute(select(User).where(User.email == "participant@test.com"))
    participant = participant.unique().scalars().first()

    fcm_token = "test_fcm_token_123"

    # Crear token existente
    existing_token = UserFcmToken(
        user_id=participant.id,
        fcm_token=fcm_token
    )
    db_session.add(existing_token)
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.request(
            "DELETE",
            "/fcm-token",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "fcm_token": fcm_token,
                "user_id": str(participant.id)
            }
        )

    # Assert
    assert response.status_code == 204

    # Verificar que el token se eliminó de la base de datos
    result = await db_session.execute(
        select(UserFcmToken).where(
            UserFcmToken.user_id == participant.id,
            UserFcmToken.fcm_token == fcm_token
        )
    )
    saved_token = result.unique().scalars().first()
    assert saved_token is None

@pytest.mark.asyncio
async def test_delete_fcm_token_not_found(db_session, participant_token):
    # Arrange
    # Obtener participante
    participant = await db_session.execute(select(User).where(User.email == "participant@test.com"))
    participant = participant.unique().scalars().first()

    fcm_token = "nonexistent_token"

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.request(
            "DELETE",
            "/fcm-token",
            headers={"Authorization": f"Bearer {participant_token}"},
            json={
                "fcm_token": fcm_token,
                "user_id": str(participant.id)
            }
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Token not found"

@pytest.mark.asyncio
async def test_delete_fcm_token_unauthorized(db_session):
    # Arrange
    fcm_token = "test_fcm_token_123"
    user_id = str(uuid.uuid4())

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.request(
            "DELETE",
            "/fcm-token",
            json={
                "fcm_token": fcm_token,
                "user_id": user_id
            }
        )

    # Assert
    assert response.status_code == 401
