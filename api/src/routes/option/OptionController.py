from typing import Annotated
import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import delete, or_, select, update, and_
from models.OptionModel import Option
from schemas.OptionSchema import *
from models.CategoryModel import Category
from models.SurveyModel import Survey
from models.QuestionModel import Question
from database import get_db
from sqlalchemy.ext.asyncio import AsyncSession
from auth.Auth import get_current_user, required_roles
from models.UserModel import User

"""
Crear una nueva opcion de respuesta
obtener opciones de respuesta de una pregunta
modificar una opcion de respuesta
eliminar una opcion de respuesta
"""


option_router = APIRouter(tags=["Option"])


@option_router.post("/surveys/{survey_id}/questions/{question_id}/options", status_code=200, response_model=OptionResponse)
@required_roles(["admin", "researcher"])
async def create_option(survey_id:uuid.UUID, question_id:uuid.UUID, option: OptionCreateRequest, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
        
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        if current_user.role == "admin":
            result = await db.execute(select(Survey).where(Survey.id == survey_id))
        if current_user.role == "researcher":
            result = await db.execute(select(Survey).join(Category).where(and_(Survey.id == survey_id, 
                                                                        Survey.category_id == Category.id, 
                                                                        Category.organization_id == current_user.organization_id)))
            
        survey = result.scalars().first()
        if not survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        
        #check if question exists and belongs to survey
        result = await db.execute(select(Question).where(and_(Question.id == question_id, Question.survey_id == survey_id)))
        question = result.scalars().first()

        if not question:
            raise HTTPException(status_code=404, detail="Question not found")
        
        #check if option already exists
        result = await db.execute(select(Option).where(Option.question_id == question_id))
        options = result.scalars().all()
        existing_option_description = any(o.description == option.description for o in options)
        if existing_option_description:
            raise HTTPException(status_code=400, detail="Option already exists")

        #check if there is only one correct option
        if not question.multiple_answer:
            existing_correct_option = any(o.is_correct for o in options)
            if option.is_correct and existing_correct_option:
                raise HTTPException(status_code=400, detail="There can only be one correct option")
            
        #create option
        new_option = Option(description=option.description, is_correct=option.is_correct, question_id=question_id)
        db.add(new_option)
        await db.commit()
        return new_option
        


@option_router.get("/surveys/{survey_id}/questions/{question_id}/options", status_code=200, response_model=OptionResponseWithLength)
async def get_options(survey_id:uuid.UUID, question_id:uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})

        #check if survey exists
        if current_user.role == "admin":
            result = await db.execute(select(Survey).where(Survey.id == survey_id))
        if current_user.role == "researcher":
            result = await db.execute(select(Survey).join(Category).where(and_(Survey.id == survey_id, 
                                                                        Survey.category_id == Category.id, 
                                                                        Category.organization_id == current_user.organization_id)))
            
        survey = result.scalars().first()
        if not survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        

        #check if question exists and belongs to survey
        result = await db.execute(select(Question).where(and_(Question.id == question_id, Question.survey_id == survey_id)))
        question = result.scalars().first()
        if not question:
            raise HTTPException(status_code=404, detail="Question not found")
        
        #get options
        result = await db.execute(select(Option).where(Option.question_id == question_id))
        options = result.scalars().all()
        #return options
        return {"options": options, "length": len(options)}
        

@option_router.put("/surveys/{survey_id}/questions/{question_id}/options/{option_id}", status_code=200, response_model=OptionResponse)
@required_roles(["admin", "researcher"])
async def update_option(survey_id:uuid.UUID, question_id:uuid.UUID, option_id:uuid.UUID, option: OptionUpdateRequest, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        if current_user.role == "admin":
            result = await db.execute(select(Survey).where(Survey.id == survey_id))
        if current_user.role == "researcher":
            result = await db.execute(select(Survey).join(Category).where(and_(Survey.id == survey_id, 
                                                                        Survey.category_id == Category.id, 
                                                                        Category.organization_id == current_user.organization_id)))
            
        #check if question exists and belongs to survey
        result = await db.execute(select(Question).where(and_(Question.id == question_id, Question.survey_id == survey_id)))
        question = result.scalars().first()
        if not question:
            raise HTTPException(status_code=404, detail="Question not found")
        
        #check if option exists and belongs to question
        result = await db.execute(select(Option).where(Option.question_id == question_id))
        options = result.scalars().all()
        existing_option = next((o for o in options if o.id == option_id), None)
        if not existing_option:
            raise HTTPException(status_code=404, detail="Option not found")
        #check if option description is already in use
        if option.description != existing_option.description:
            existing_option_description = any(o.description == option.description for o in options)
        if existing_option_description:
            raise HTTPException(status_code=400, detail="Option already exists")
        #check if there is only one correct option
        if not question.multiple_answer:
            existing_correct_option = any(o.is_correct for o in options)
            if option.is_correct and existing_correct_option:
                raise HTTPException(status_code=400, detail="There can only be one correct option")
        #update option
        await db.execute(update(Option).where(Option.id == option_id).values(option.model_dump()))
        await db.commit()
        return existing_option
        


@option_router.delete("/surveys/{survey_id}/questions/{question_id}/options/{option_id}", status_code=204)
@required_roles(["admin", "researcher"])
async def delete_option(survey_id:uuid.UUID, question_id:uuid.UUID, option_id:uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        if current_user.role == "admin":
            result = await db.execute(select(Survey).where(Survey.id == survey_id))
        if current_user.role == "researcher":
            result = await db.execute(select(Survey).join(Category).where(and_(Survey.id == survey_id, 
                                                                               Survey.category_id == Category.id,
                                                                                Category.organization_id == current_user.organization_id)))
        existing_survey = result.scalars().first()

        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        
        #check if question exists and belongs to survey
        result = await db.execute(select(Question).where(and_(Question.id == question_id, Question.survey_id == survey_id)))
        question = result.scalars().first()

        if not question:
            raise HTTPException(status_code=404, detail="Question not found")

        #check if option exists and belongs to question
        result = await db.execute(select(Option).where(and_(Option.id == option_id, Option.question_id == question.id)))
        existing_option = result.scalars().first()
        
        if not existing_option:
            raise HTTPException(status_code=404, detail="Option not found")
        
        #delete option
        await db.execute(delete(Option).where(Option.id == option_id))
        await db.commit()

        return None

        
        
        
        

        
        
        
        





