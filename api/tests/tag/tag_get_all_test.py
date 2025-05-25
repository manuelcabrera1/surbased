from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from src.main import app
from src.models.TagModel import Tag
from sqlalchemy import select

@pytest.mark.asyncio
async def test_get_all_tags_success(db_session, admin_token):
    # Arrange
    tags = [
        Tag(name="Tag 1"),
        Tag(name="Tag 2"),
        Tag(name="Tag 3")
    ]
    
    db_session.add_all(tags)
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            "/tags",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()["tags"]
    assert len(data) == 3
    assert any(tag["name"] == "Tag 1" for tag in data)
    assert any(tag["name"] == "Tag 2" for tag in data)
    assert any(tag["name"] == "Tag 3" for tag in data)

@pytest.mark.asyncio
async def test_get_all_tags_unauthorized(db_session):
    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/tags")

    # Assert
    assert response.status_code == 401


