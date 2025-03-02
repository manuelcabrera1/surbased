from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, update
from models.UserModel import User
from schemas.OrganizationSchema import *
from schemas.UserSchema import *
from models.OrganizationModel import Organization
from database import get_db
from typing import Annotated, List
from sqlalchemy.ext.asyncio import AsyncSession
from auth.Auth import create_access_token, check_current_user



org_router = APIRouter(tags=["Organization"])

@org_router.post("/orgs/create", status_code=201, response_model=OrganizationResponse)
async def create_organization(org: OrganizationCreate, db: Annotated[AsyncSession, Depends(get_db)]):

        result = await db.execute(select(Organization).where(Organization.name == org.name))
        existing_org = result.scalars().first()

        if existing_org:
            raise HTTPException(status_code=400, detail="This organization already exists")

        new_org = Organization(name=org.name)
        db.add(new_org)
        await db.commit()
        await db.refresh(new_org)

        return new_org


 
@org_router.get("/orgs", status_code=200, response_model=OrganizationResponseWithLength, dependencies=[Depends(check_current_user)])
async def get_all_organizations(db: Annotated[AsyncSession, Depends(get_db)]):

        result = await db.execute(select(Organization))
        orgs = result.scalars().all()
        return { "orgs": orgs, "length": len(orgs) }
    


@org_router.get("/orgs/{id}", status_code=200, response_model=OrganizationResponse, dependencies=[Depends(check_current_user)])
async def get_organization_by_id(id:uuid.UUID, db: Annotated[AsyncSession, Depends(get_db)]):

        
        result = await db.execute(select(Organization).where(Organization.id == id))
        existing_org = result.scalars().first()

        if not existing_org:
            raise HTTPException(status_code=404, detail="Organization not found") 
        
        return existing_org
            
    

@org_router.put("/orgs/{id}", status_code=201, response_model=OrganizationResponse, dependencies=[Depends(check_current_user)])
async def update_organization(id: uuid.UUID, org: OrganizationCreate, db: Annotated[AsyncSession, Depends(get_db)]):

        
        #check if org exists
        result = await db.execute(select(Organization).where(Organization.id == id))
        existing_org = result.scalars().first()

        if not existing_org:
            raise HTTPException(status_code=400, detail="Organization not found")

        #check if query name is already registered

        if existing_org.name != org.name:
            result2 = await db.execute(select(Organization).where(Organization.name == org.name))
            existing_org_name = result2.scalars().first()
            
            if existing_org_name:
                raise HTTPException(status_code=400, detail="Organization name already registered")
            

        await db.execute(update(Organization).where(Organization.id == id).values(org.model_dump()))
        await db.commit()

        return existing_org



@org_router.delete("/orgs/{id}", status_code=204, dependencies=[Depends(check_current_user)])
async def delete_organization(id: uuid.UUID, db: Annotated[AsyncSession, Depends(get_db)]):

        #check if org exists
        result = await db.execute(select(Organization).where(Organization.id == id))
        existing_org = result.scalars().first()

        if not existing_org:
            raise HTTPException(status_code=400, detail="Organization not found")

        await db.delete(existing_org)
        await db.commit()
    
        return None

    
    

