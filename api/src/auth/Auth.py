from datetime import UTC, timedelta, datetime
from functools import wraps
from typing import Annotated, Callable, List
import uuid
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi import APIRouter, Depends, HTTPException, Request
import jwt
from dotenv import load_dotenv
import os

from sqlalchemy import select
from models.UserModel import User
from schemas.TokenSchema import TokenData
from database import get_db
from sqlalchemy.ext.asyncio import AsyncSession

load_dotenv()
 
#specify oauth2 scheme
oauth_scheme = OAuth2PasswordBearer(tokenUrl="/users/login")


def create_access_token(data: dict)->str:

    try:

        payload = data.copy()

        token_expiration = os.getenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES")
        

        if token_expiration:
            expire = datetime.now(UTC) + timedelta(minutes=int(token_expiration))
        else:
            expire = datetime.now(UTC) + timedelta(minutes=15)

        payload.update({"exp": expire})
        encoded_jwt = jwt.encode(payload=payload, key=os.getenv("JWT_SECRET"), algorithm=os.getenv("JWT_ALGORITHM"))

        return encoded_jwt
    
    except Exception as e:
        raise HTTPException(str(e))


def check_current_user(token: Annotated[str,Depends(oauth_scheme)])-> dict: 
    try:

        payload = jwt.decode(token, key= os.getenv("JWT_SECRET"), algorithms=os.getenv("JWT_ALGORITHM"))


        if payload.get("id") is None:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})


        token_data = TokenData(id=payload.get("id"), role=payload.get("role"))

        return token_data

    except Exception:
        raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})



async def get_current_user(payload: Annotated[TokenData, Depends(check_current_user)], db: Annotated[AsyncSession, Depends(get_db)])-> dict:
    try:
        if payload.id is None:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})

        result = await db.execute(select(User).where(User.id == payload.id))
        user = result.scalars().first()

        if user is None:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})

        return user
        

    except Exception:
        raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})


def required_roles(roles: List[str]):
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):

            current_user = kwargs.get("current_user")


            if current_user.role not in roles:
                raise HTTPException(status_code=403, detail="Forbidden")

            return await func(*args, **kwargs)

        return wrapper

    return decorator
            
        
