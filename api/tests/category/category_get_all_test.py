from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from src.main import app
from src.models.CategoryModel import Category
from sqlalchemy import select

@pytest.mark.asyncio
async def test_get_all_categories_success(db_session, admin_token):
    # Arrange
    categories = [
        Category(name="Category 1"),
        Category(name="Category 2"),
        Category(name="Category 3")
    ]
    
    db_session.add_all(categories)
    await db_session.commit()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            "/categories",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()["categories"]
    assert len(data) == 3
    assert any(category["name"] == "Category 1" for category in data)
    assert any(category["name"] == "Category 2" for category in data)
    assert any(category["name"] == "Category 3" for category in data)


@pytest.mark.asyncio
async def test_get_all_categories_unauthorized(db_session):
    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/categories")

    # Assert
    assert response.status_code == 401


