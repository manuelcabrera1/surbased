from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import and_, select, update
from src.models.UserModel import User
from src.models.CategoryModel import Category
from src.schemas.CategorySchema import *
from src.schemas.TokenSchema import Token
import bcrypt
from src.database import get_db
from typing import Annotated, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi.security import OAuth2PasswordRequestForm
from src.auth.Auth import create_access_token, check_current_user, get_current_user, oauth_scheme, required_roles

category_router = APIRouter(tags=["Category"])

@category_router.post("/categories/create",status_code=201, response_model=CategoryResponse)
@required_roles(["researcher", "admin"])
async def create_category(category: CategoryCreate, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        result = await db.execute(select(Category).where(Category.name == category.name))
        existing_category = result.unique().scalars().first()

        if existing_category:
            raise HTTPException(status_code=400, detail="Existing category")

        new_category = Category(name=category.name)
        db.add(new_category)
        await db.commit()
        await db.refresh(new_category)

        return new_category


@category_router.get("/categories", status_code=200, response_model=CategoryResponseList)
async def get_all_categories(current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        

        result = await db.execute(select(Category))


        categories = result.unique().scalars().all()
        return { "categories": categories }
    


@category_router.get("/categories/{id}", status_code=200, response_model=CategoryResponse)
@required_roles(["researcher", "admin"])
async def get_category_by_id(id:uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        result = await db.execute(select(Category).where(Category.id == id))

        existing_category = result.unique().scalars().first()

        if not existing_category:
            raise HTTPException(status_code=404, detail="Category not found") 
        
        return existing_category
            
    

@category_router.put("/categories/{id}", status_code=201, response_model=CategoryResponse)
@required_roles(["researcher", "admin"])
async def update_category(id: uuid.UUID, category: CategoryUpdate, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
        
        #check if category exists

        result = await db.execute(select(Category).where(Category.id == id))

        existing_category = result.unique().scalars().first()

        if not existing_category:
            raise HTTPException(status_code=400, detail="Category not found")

        #check if query name is already registered

        if existing_category.name != category.name:
            result2 = await db.execute(select(Category).where(Category.name == category.name))
            
            if result2.unique().scalars().first() is not None:
                raise HTTPException(status_code=400, detail="Category name already registered")
            

        await db.execute(update(Category).where(Category.id == id).values(category.model_dump()))
        await db.commit()

        return existing_category



@category_router.delete("/categories/{id}", status_code=204)
@required_roles(["researcher"])
async def delete_category(id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        #check if category exists
        result = await db.execute(select(Category).where(Category.id == id))
        existing_category = result.unique().scalars().first()

        if not existing_category:
            raise HTTPException(status_code=400, detail="Category not found")

        await db.delete(existing_category)
        await db.commit()
    
        return None

    
