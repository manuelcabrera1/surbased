from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import and_, select
from sqlalchemy.ext.asyncio import AsyncSession
from auth.Auth import get_current_user
from schemas.UserFcmTokenSchema import UserFcmTokenCreate
from models.UserFcmTokenModel import UserFcmToken
from models.UserModel import User
from database import get_db


user_fcm_token_router = APIRouter(prefix="/fcm-token", tags=["User FCM Token"])


@user_fcm_token_router.post("", status_code=200)
async def register_user_fcm_token(user_fcm_token: UserFcmTokenCreate, db: Annotated[AsyncSession, Depends(get_db)], current_user: Annotated[User, Depends(get_current_user)] = None):

    if not current_user:
        raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    
    

    
    result = await db.execute(select(UserFcmToken).where(and_(UserFcmToken.user_id == user_fcm_token.user_id, UserFcmToken.fcm_token == user_fcm_token.fcm_token)))
    existing_token = result.unique().scalars().first()

    if not existing_token:
        new_token = UserFcmToken(user_id=user_fcm_token.user_id, fcm_token=user_fcm_token.fcm_token)
        db.add(new_token)
        await db.commit()
        await db.refresh(new_token)

        return {"message": "Token registered successfully"}
    else:
        return {"message": "Token already registered"}

    
