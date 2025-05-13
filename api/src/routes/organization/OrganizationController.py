from datetime import date
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import and_, func, select, update
from src.models.SurveyModel import Survey
from src.schemas.SurveySchema import SurveyResponseWithLength, SurveyScopeEnum
from src.models.UserModel import User
from src.schemas.OrganizationSchema import *
from src.schemas.UserSchema import *
from src.models.OrganizationModel import Organization
from src.database import get_db
from typing import Annotated, List
from sqlalchemy.ext.asyncio import AsyncSession
from src.auth.Auth import create_access_token, check_current_user, get_current_user, required_roles



org_router = APIRouter(tags=["Organization"])

@org_router.post("/organizations", status_code=201, response_model=OrganizationResponse)
@required_roles(["admin"])
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


 
@org_router.get("/organizations", status_code=200, response_model=OrganizationResponseWithLength)
@required_roles(["admin"])
async def get_all_organizations(db: Annotated[AsyncSession, Depends(get_db)], current_user: Annotated[User, Depends(get_current_user)] = None):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        result = await db.execute(select(Organization))
        orgs = result.unique().scalars().all()

        
        organizations = [OrganizationResponse(id=o.id, name=o.name, users_count=len(o.users), surveys_count=len(o.surveys)) for o in orgs]


        return { "organizations": organizations, "length": len(organizations) }
    


@org_router.get("/organizations/{id}", status_code=200, response_model=OrganizationResponse)
async def get_organization_by_id(id:uuid.UUID, db: Annotated[AsyncSession, Depends(get_db)], current_user: Annotated[User, Depends(get_current_user)] = None):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        result = await db.execute(select(Organization).where(Organization.id == id))
        existing_org = result.unique().scalars().first()

        if not existing_org:
            raise HTTPException(status_code=404, detail="Organization not found") 
        
        return OrganizationResponse(id=existing_org.id, name=existing_org.name, users_count=len(existing_org.users), surveys_count=len(existing_org.surveys))

@org_router.get("/organizations/", status_code=200, response_model=OrganizationResponseWithLength)
async def get_organizations_by_ids(ids:List[uuid.UUID], db: Annotated[AsyncSession, Depends(get_db)], current_user: Annotated[User, Depends(get_current_user)] = None):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        orgs = []
        for id in ids:
            result = await db.execute(select(Organization).where(Organization.id == id))
            existing_org = result.unique().scalars().first()
            orgs.append(existing_org)

        if not existing_org:
            raise HTTPException(status_code=404, detail="Organization not found") 
        
        return orgs

@org_router.get("/organizations/{id}/users", status_code=200, response_model=UserResponseWithLength)
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

@org_router.get("/organizations/{org_id}/surveys", status_code=200, response_model=SurveyResponseWithLength)
@required_roles(["admin", "researcher", "participant"])
async def get_surveys_in_organization(current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)], 
                        org_id: uuid.UUID, category_id: Optional[uuid.UUID] = None):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})

        if current_user.role != "admin" and current_user.organization_id != org_id:
            raise HTTPException(status_code=403, detail="Forbidden")
        
        
        result = await db.execute(select(Survey).where(and_(Survey.scope == SurveyScopeEnum.organization, 
                                                                Survey.organization_id == org_id)))
    
        surveys = result.unique().scalars().all()

        
        surveys = sorted(surveys, key=lambda x: x.end_date, reverse=True)


        return { "surveys": surveys, "length": len(surveys) }
            
    

@org_router.put("/organizations/{id}", status_code=200, response_model=OrganizationResponse)
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



@org_router.delete("/organizations/{id}", status_code=204)
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

    
    

