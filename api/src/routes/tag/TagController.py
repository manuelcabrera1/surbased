from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import and_, select, update
from models.UserModel import User
from models.CategoryModel import Category
from schemas.CategorySchema import *
from schemas.TokenSchema import Token
import bcrypt
from database import get_db
from typing import Annotated, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi.security import OAuth2PasswordRequestForm
from auth.Auth import create_access_token, check_current_user, get_current_user, oauth_scheme, required_roles
from models.TagModel import Tag
from schemas.TagSchema import *

tag_router = APIRouter(tags=["Tag"])




@tag_router.get("/tags", status_code=200, response_model=TagResponseWithLength)
async def get_all_tags(current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        

        result = await db.execute(select(Tag))

        tags = result.unique().scalars().all()
        return {
              "tags": tags,
              "length": len(tags)
        }
    
    
