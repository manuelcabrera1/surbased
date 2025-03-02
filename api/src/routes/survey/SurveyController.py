from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, update, and_
from models.CategoryModel import Category
from models.UserModel import User
from models.SurveyModel import Survey
from schemas.SurveySchema import *
import bcrypt
from database import get_db
from typing import Annotated, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi.security import OAuth2PasswordRequestForm
from auth.Auth import create_access_token, check_current_user, oauth_scheme, get_current_user, required_roles


survey_router = APIRouter(tags=["Survey"])



@survey_router.post("/surveys",status_code=201, response_model=SurveyResponse)
@required_roles(["researcher", "admin"])
async def create_survey(survey: SurveyCreate, db: Annotated[AsyncSession, Depends(get_db)], current_user: Annotated[User, Depends(get_current_user)] = None):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if category exists

        result = await db.execute(select(Category).where(Category.id == survey.category_id))
        category = result.scalars().first()

        if not category:
            raise HTTPException(status_code=400, detail="Category not found")
        
        #check if researcher exists

        result = await db.execute(select(User).where(and_(User.id == survey.researcher_id, User.role == "researcher")))
        researcher = result.scalars().first()

        if not researcher:
            raise HTTPException(status_code=400, detail="Researcher not found")
        
        #check if survey name is already registered in the category

        result = await db.execute(select(Survey).join(Category).where(and_(Survey.name == survey.name, Category.id == survey.category_id)))
        existing_survey = result.scalars().first()

        if existing_survey:
            raise HTTPException(status_code=400, detail="Survey name already registered in this category")
        
        #check if researcher is trying to create a survey for another organization
        if current_user.role == "researcher" and researcher.organization_id != current_user.organization_id:
            raise HTTPException(status_code=403, detail="Forbidden")

        new_survey = Survey(name=survey.name, description=survey.description, start_date=survey.start_date, end_date=survey.end_date, researcher_id=survey.researcher_id, category_id=survey.category_id)
        db.add(new_survey)
        await db.commit()
        await db.refresh(new_survey)

        return new_survey


@survey_router.get("/surveys", status_code=200, response_model=SurveyResponseWithLength)
@required_roles(["admin", "researcher"])
async def get_all_surveys(current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)], org: Optional[uuid.UUID] = None, category: Optional[uuid.UUID] = None):
    
        
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})

        #TODO: try to modularize this in methods (service logic)

        if current_user.role == "admin":
            if org and not category:
                result = await db.execute(select(Survey).join(Category).where(Category.organization_id == org))
            
            elif category and org:
                result = await db.execute(select(Survey).join(Category).where(Category.id == category))
            
            elif category and not org:
                raise HTTPException(status_code=400, details="Organization must be specified")

            else:
                result = await db.execute(select(Survey))



        if current_user.role == "researcher":
            
            if category:
                result = await db.execute(select(Survey).join(Category).where(and_(Category.id == category, Category.organization_id == current_user.organization_id)))
            
            if not category:
                result = await db.execute(select(Survey).join(Category).where(Category.organization_id == current_user.organization_id))


        surveys = result.scalars().all()

        return { "surveys": surveys, "length": len(surveys) }




@survey_router.get("/surveys/{id}", status_code=200, response_model=SurveyResponse)
async def get_survey_by_id(id:uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        if current_user.role == "admin":
            result = await db.execute(select(Survey).join(User).where(Survey.id == id))

        if current_user.role == "researcher" or current_user.role == "participant":
            result = await db.execute(select(Survey).join(User).where(and_(Survey.id == id, User.organization_id == current_user.organization_id)))

        survey = result.scalars().first()   

        if not survey:
            raise HTTPException(status_code=404, detail="Survey not found")

        return survey

    
    

@survey_router.put("/surveys/{id}", status_code=200, response_model=SurveyResponse)
@required_roles(["admin", "researcher"])
async def update_survey(id:uuid.UUID, survey: SurveyCreate, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        if current_user.role == "admin":
            result = await db.execute(select(Survey).join(User).where(Survey.id == id))

        if current_user.role == "researcher":
            result = await db.execute(select(Survey).join(User).where(and_(Survey.id == id, User.organization_id == current_user.organization_id)))

        existing_survey = result.scalars().first()

        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")

        await db.execute(update(Survey).where(Survey.id == id).values(survey.model_dump()))
        await db.commit()

        return survey
    


@survey_router.delete("/surveys/{id}", status_code=204)
@required_roles(["admin", "researcher"])
async def delete_survey(id:uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})

        if current_user.role == "admin":
            result = await db.execute(select(Survey).join(User).where(Survey.id == id))

        if current_user.role == "researcher":
            result = await db.execute(select(Survey).join(User).where(and_(Survey.id == id, User.organization_id == current_user.organization_id)))

        survey = result.scalars().first()  

        if not survey:
            raise HTTPException(status_code=404, detail="Survey not found")

        await db.delete(survey)
        await db.commit()

        return None
    






