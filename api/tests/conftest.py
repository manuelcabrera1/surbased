from datetime import date
from httpx import ASGITransport, AsyncClient
import pytest
import pytest_asyncio
import asyncio
from sqlalchemy import select
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from pathlib import Path
import sys
import os
import uuid
import asyncpg
import bcrypt

# Obtener la ruta absoluta del directorio api
api_dir = Path(__file__).parent.parent.absolute()
# Añadir el directorio api al path de Python
sys.path.insert(0, str(api_dir))

from src.models.OrganizationModel import Organization
from src.main import app
from src.database import Base, get_db
from src.models.UserModel import User
from src.auth.Auth import get_current_user

# Configuración de la base de datos de test
TEST_DB_NAME = f"test_db_{uuid.uuid4().hex[:10]}"
TEST_DATABASE_URL = f"postgresql+asyncpg://postgres:1234@localhost:5432/{TEST_DB_NAME}"

# ID del usuario admin para usar en el token y en el mock
ADMIN_ID = uuid.uuid4()
RESEARCHER_ID = uuid.uuid4()
PARTICIPANT_ID = uuid.uuid4()
@pytest_asyncio.fixture
async def create_test_database():
    """Crear una base de datos de test temporal"""
    # Conectar a la base de datos postgres para crear la base de datos de test
    sys_conn = await asyncpg.connect(
        user="postgres",
        password="1234",
        host="localhost",
        port="5432",
        database="postgres"
    )
    
    # Crear la base de datos de test
    await sys_conn.execute(f'CREATE DATABASE "{TEST_DB_NAME}"')
    await sys_conn.close()
    
    yield
    
    # Eliminar la base de datos de test después de las pruebas
    sys_conn = await asyncpg.connect(
        user="postgres",
        password="1234",
        host="localhost",
        port="5432",
        database="postgres"
    )
    await sys_conn.execute(f'DROP DATABASE "{TEST_DB_NAME}"')
    await sys_conn.close()

@pytest_asyncio.fixture()
async def test_engine(create_test_database):
    """Crear el motor de la base de datos de test"""
    engine = create_async_engine(TEST_DATABASE_URL)
    
    # Crear todas las tablas
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    yield engine
    
    await engine.dispose()

@pytest_asyncio.fixture()
async def db_session(test_engine):
    """Proporcionar una sesión de base de datos para cada test"""
    async_session = sessionmaker(
        test_engine, class_=AsyncSession, expire_on_commit=False
    )
    
    async with async_session() as session:
        yield session
        await session.rollback()



@pytest_asyncio.fixture(autouse=True)
async def setup_test_data(db_session):
    """Configure test data before each test"""

    org = Organization(name="Organization")
    

    hashed_password = bcrypt.hashpw("test123".encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    admin_user = User(
        id=ADMIN_ID,
        email="admin@test.com",
        password=hashed_password,
        name="Admin",
        lastname="Test",
        role="admin"
    )

    researcher_user = User(
        id=RESEARCHER_ID,
        email="researcher@test.com",
        password=hashed_password,
        name="Researcher",
        lastname="Test",
        role="researcher",
        organization_id=org.id
    )
    
    participant_user = User(
        id=PARTICIPANT_ID,
        email="participant@test.com",
        password=hashed_password,
        name="Participant",
        lastname="Test",
        role="participant",
        organization_id=org.id,
        birthdate=date(1990, 1, 1),
        gender="male"
        
    )
    
    
    # Verificar si el usuario ya existe
    result = await db_session.execute(select(User).where(User.email == "admin@test.com"))
    existing_user = result.unique().scalars().first()
    
    if not existing_user:
        db_session.add(admin_user)
        await db_session.commit()

    result = await db_session.execute(select(User).where(User.email == "researcher@test.com"))
    existing_user = result.unique().scalars().first()

    if not existing_user:
        db_session.add(researcher_user)
        await db_session.commit()

    result = await db_session.execute(select(User).where(User.email == "participant@test.com"))
    existing_user = result.unique().scalars().first()

    if not existing_user:
        db_session.add(participant_user)
        await db_session.commit()

    result = await db_session.execute(select(Organization).where(Organization.name == "Organization 1"))
    existing_org = result.unique().scalars().first()
    if not existing_org:
        db_session.add(org)
        await db_session.commit()

    async def override_get_db():
        try:
            yield db_session
        finally:
            await db_session.close()

    app.dependency_overrides[get_db] = override_get_db

@pytest_asyncio.fixture()
async def admin_token():
    login_data = {
        "username": "admin@test.com",
        "password": "test123"
    }
    
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/users/login",
            data=login_data,
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )
        return response.json()["access_token"]
    

@pytest_asyncio.fixture()
async def researcher_token():
    login_data = {
        "username": "researcher@test.com",
        "password": "test123"
    }
    
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/users/login",
            data=login_data,
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )
        return response.json()["access_token"]

@pytest_asyncio.fixture()
async def participant_token():
    login_data = {
        "username": "participant@test.com",
        "password": "test123"
    }
    
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            "/users/login",
            data=login_data,
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )
        return response.json()["access_token"]




