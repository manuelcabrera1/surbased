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
from src.models.TagModel import Tag
from src.schemas.TagSchema import *

tag_router = APIRouter(tags=["Tag"])




@tag_router.get("/tags", status_code=200, response_model=TagResponseList)
async def get_all_tags(current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        

        result = await db.execute(select(Tag))

        tags = result.unique().scalars().all()
        return tags
    
    
