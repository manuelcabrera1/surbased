from httpx import AsyncClient, ASGITransport
import pytest
import pytest_asyncio
from src.main import app
from src.models.CategoryModel import Category
from sqlalchemy import select
import uuid

@pytest.mark.asyncio
async def test_get_category_by_id_success(db_session, admin_token):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.commit()
    await db_session.refresh(category)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/categories/{category.id}",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == str(category.id)
    assert data["name"] == "Test Category"

@pytest.mark.asyncio
async def test_get_category_by_id_not_found(db_session, admin_token):
    # Arrange
    nonexistent_id = uuid.uuid4()

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(
            f"/categories/{nonexistent_id}",
            headers={"Authorization": f"Bearer {admin_token}"}
        )

    # Assert
    assert response.status_code == 404
    assert response.json()["detail"] == "Category not found"

@pytest.mark.asyncio
async def test_get_category_by_id_unauthorized(db_session):
    # Arrange
    category = Category(name="Test Category")
    db_session.add(category)
    await db_session.commit()
    await db_session.refresh(category)

    # Act
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get(f"/categories/{category.id}")

    # Assert
    assert response.status_code == 401


