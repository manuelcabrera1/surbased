from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, update
from models.UserModel import User
from schemas.OrganizationSchema import *
from schemas.UserSchema import *
from models.OrganizationModel import Organization
from database import get_db
from typing import Annotated, List
from sqlalchemy.ext.asyncio import AsyncSession
from auth.Auth import create_access_token, check_current_user, get_current_user, required_roles



org_router = APIRouter(tags=["Organization"])

@org_router.post("/orgs/create", status_code=201, response_model=OrganizationResponse)
async def create_organization(org: OrganizationCreate, db: Annotated[AsyncSession, Depends(get_db)], current_user: Annotated[User, Depends(get_current_user)] = None):

    if not current_user:
        raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    
    result = await db.execute(select(Organization).where(Organization.name == org.name))
    existing_org = result.unique().scalars().first()

    if existing_org:
        raise HTTPException(status_code=400, detail="This organization already exists")

    new_org = Organization(name=org.name)
    db.add(new_org)
    await db.commit()
    await db.refresh(new_org)

    return new_org


 
@org_router.get("/orgs", status_code=200, response_model=OrganizationResponseWithLength)
@required_roles(["admin"])
async def get_all_organizations(db: Annotated[AsyncSession, Depends(get_db)], current_user: Annotated[User, Depends(get_current_user)] = None):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        result = await db.execute(select(Organization))
        orgs = result.unique().scalars().all()
        return { "orgs": orgs, "length": len(orgs) }
    


@org_router.get("/orgs/{id}", status_code=200, response_model=OrganizationResponse)
async def get_organization_by_id(id:uuid.UUID, db: Annotated[AsyncSession, Depends(get_db)], current_user: Annotated[User, Depends(get_current_user)] = None):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        result = await db.execute(select(Organization).where(Organization.id == id))
        existing_org = result.unique().scalars().first()

        if not existing_org:
            raise HTTPException(status_code=404, detail="Organization not found") 
        
        return existing_org

@org_router.get("/orgs/{id}/users", status_code=200, response_model=UserResponseWithLength)
@required_roles(["researcher", "admin"])
async def get_all_users_in_organization(id:uuid.UUID, db: Annotated[AsyncSession, Depends(get_db)], 
                                        current_user: Annotated[User, Depends(get_current_user)] = None, 
                                        sortBy: Optional[str] = 'email', order: Optional[str] = 'ASC'):
        
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        if current_user.organization_id != id and current_user.role != "admin":
            raise HTTPException(status_code=403, detail="You are not allowed to access this organization")
        

        result = await db.execute(select(User).where(User.organization_id == id))

        users = result.unique().scalars().all()

        if sortBy == "email":
            users.sort(key=lambda a: (a.email), reverse=order == 'DESC')
        elif sortBy == "role":
            users.sort(key=lambda a: (a.role), reverse=order == 'DESC')

        return { "users": users, "length": len(users) }
            
    

@org_router.put("/orgs/{id}", status_code=201, response_model=OrganizationResponse)
@required_roles(["admin"])
async def update_organization(id: uuid.UUID, org: OrganizationCreate, db: Annotated[AsyncSession, Depends(get_db)], current_user: Annotated[User, Depends(get_current_user)] = None):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if org exists
        result = await db.execute(select(Organization).where(Organization.id == id))
        existing_org = result.scalars().first()

        if not existing_org:
            raise HTTPException(status_code=400, detail="Organization not found")

        #check if query name is already registered

        if existing_org.name != org.name:
            result2 = await db.execute(select(Organization).where(Organization.name == org.name))
            existing_org_name = result2.unique().scalars().first()
            
            if existing_org_name:
                raise HTTPException(status_code=400, detail="Organization name already registered")
            

        await db.execute(update(Organization).where(Organization.id == id).values(org.model_dump()))
        await db.commit()

        return existing_org



@org_router.delete("/orgs/{id}", status_code=204)
@required_roles(["admin"])
async def delete_organization(id: uuid.UUID, db: Annotated[AsyncSession, Depends(get_db)], current_user: Annotated[User, Depends(get_current_user)] = None):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if org exists
        result = await db.execute(select(Organization).where(Organization.id == id))
        existing_org = result.unique().scalars().first()

        if not existing_org:
            raise HTTPException(status_code=400, detail="Organization not found")

        await db.delete(existing_org)
        await db.commit()
    
        return None

    
    

