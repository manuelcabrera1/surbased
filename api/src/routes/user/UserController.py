from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import or_, select, update
from models.UserModel import User
from models.OrganizationModel import Organization
from schemas.UserSchema import *
from schemas.TokenSchema import Token
import bcrypt
from database import get_db
from typing import Annotated, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi.security import OAuth2PasswordRequestForm
from auth.Auth import create_access_token, check_current_user, oauth_scheme, get_current_user, required_roles

user_router = APIRouter(tags=["User"])

@user_router.post("/users/create", status_code=201, response_model=UserResponse)
async def create_user(user: UserCreateRequest, db: Annotated[AsyncSession, Depends(get_db)]):
    
   
    try: 
        #check if user already exists
        result = await db.execute(select(User).where(User.email == user.email))
        existing_user = result.unique().scalars().first()

        if existing_user and existing_user.email == user.email:
            raise HTTPException(status_code=400, detail="This email is already in use")  
        
        #check if org already exists
        result = await db.execute(select(Organization).where(Organization.name.ilike(user.organization)))
        existing_org = result.unique().scalars().first()

        if not existing_org:
            raise HTTPException(status_code=404, detail= "Organization not found")

        #hash password
        hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

        #insert user to db
        new_user = User(name=user.name, lastname=user.lastname, email=user.email, password=hashed_password, role=user.role, birthdate= user.birthdate, gender= user.gender, organization_id= existing_org.id)
    
        db.add(new_user) 
        await db.commit()
        await db.refresh(new_user)


        return new_user
    
    except Exception as e:
        await db.rollback() 
        raise HTTPException(status_code=400, detail=str(e))



@user_router.post("/users/login", status_code=200)
async def login(form_data: Annotated[OAuth2PasswordRequestForm, Depends()], db: Annotated[AsyncSession, Depends(get_db)]):
 
        
    #check if user exists
    result = await db.execute(select(User).where(User.email == form_data.username))
    existing_user = result.unique().scalars().first()

    if not existing_user:
            raise HTTPException(status_code=404, detail="User not found")
        
    #check password
    password_is_valid = bcrypt.checkpw(form_data.password.encode('utf-8'), existing_user.password.encode('utf-8'))

    if not password_is_valid:
        raise HTTPException(status_code=401, detail="Authentication failed")
        
        #generate user token
    access_token = create_access_token({"id": str(existing_user.id)})

    return Token(access_token=access_token, token_type="bearer")
    



@user_router.get("/users/me", status_code=200, response_model=UserResponse)
async def get_user(current_user: Annotated[User, Depends(get_current_user)] = None):
    
    if not current_user:
        raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
    return current_user
    


@user_router.get("/users", status_code=200, response_model=UserResponseWithLength, dependencies=[Depends(check_current_user)])
@required_roles(["admin"])
async def get_all_users(db: Annotated[AsyncSession, Depends(get_db)], current_user: Annotated[User, Depends(get_current_user)] = None, role: Optional[UserRoleEnum] = None, org: Optional[uuid.UUID] = None):
        
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})

        if current_user.role == "admin":
            if org and role:
                result = await db.execute(select(User).where(User.organization_id == org, User.role == role))
            elif org:
                result = await db.execute(select(User).where(User.organization_id == org))
            elif role:
                result = await db.execute(select(User).where(User.role == role))
            else:
                result = await db.execute(select(User))
                
       

        users = result.unique().scalars().all()
        return { "users": users, "length": len(users) }
    


@user_router.get("/users/{id}", status_code=200, response_model=UserResponse)
@required_roles(["admin", "researcher"])
async def get_user_by_id(id:uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
        
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})

        result = await db.execute(select(User).where(User.id == id))
        existing_user = result.unique().scalars().first()

        if current_user.role == "researcher" and existing_user.organization_id != current_user.organization_id:
            raise HTTPException(status_code=403, detail="You are not allowed to access this user")

        if not existing_user:
            raise HTTPException(status_code=404, detail="User not found") 
        
        return existing_user


@user_router.put("/users/change-password", status_code=200, dependencies=[Depends(check_current_user)])
async def update_password(current_user: Annotated[User, Depends(get_current_user)], pw: UserUpdatePasswordRequest, db: Annotated[AsyncSession, Depends(get_db)]):
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    

        hashed_password = bcrypt.hashpw(pw.password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

        await db.execute(update(User).where(User.id == current_user.id).values(password=hashed_password))
        await db.commit()

        return None

@user_router.put("/users/{id}", status_code=200, response_model=UserResponse, dependencies=[Depends(check_current_user)])
async def update_user(id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], user: UserUpdateRequest, db: Annotated[AsyncSession, Depends(get_db)]):
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})

        #check if user exists
        result = await db.execute(select(User).where(User.id == id))
        existing_user = result.unique().scalars().first()

        if not existing_user:
            raise HTTPException(status_code=404, detail="User not found")

        #check if email is already registered

        if existing_user.email != user.email:
            result3 = await db.execute(select(User).where(User.email == user.email))

            if result3.unique().scalars().first() is not None:
                raise HTTPException(status_code=400, detail="Email already registered")
            
        if current_user.role == "admin":
            await db.execute(update(User).where(User.id == id).values(user.model_dump()))
            await db.commit()
        else:
            await db.execute(update(User).where(User.id == id).values(email= user.email, name= user.name, lastname= user.lastname, birthdate= user.birthdate))
            await db.commit()


        return existing_user



@user_router.delete("/users/{id}", status_code=200, dependencies=[Depends(check_current_user)])
async def delete_user(id: uuid.UUID, db: Annotated[AsyncSession, Depends(get_db)]):

        #check if user exists
        result = await db.execute(select(User).where(User.id == id))
        existing_user = result.unique().scalars().first()

        if not existing_user:
            raise HTTPException(status_code=400, detail="User not found")

        await db.delete(existing_user)
        await db.commit()
    
        return None


@user_router.get("/users/", status_code=200, response_model=UserResponseWithLength, dependencies=[Depends(check_current_user)])
async def filter_users(db: Annotated[AsyncSession, Depends(get_db)], role:Optional[UserRoleEnum] = None, org_id: Optional[uuid.UUID] = None):

        query = select(User)

        if role:
            query = query.where(User.role == role)
        
        if org_id:
        
            query = query.where(User.organization_id == org_id)
        
        result = await db.execute(query)
        users = result.unique().scalars().all()

        return { "users": users, "length": len(users) }
    

@user_router.post("/users/logout", status_code=200)
def logout():    
        return {"msg": "Succesfully logout"}











    
    