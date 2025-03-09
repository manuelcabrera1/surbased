from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, update, and_
from models.QuestionModel import Question
from models.OptionModel import Option
from schemas.OptionSchema import OptionResponse
from schemas.QuestionSchema import QuestionResponse
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
from sqlalchemy.orm import selectinload


survey_router = APIRouter(tags=["Survey"])





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


        surveys = result.unique().scalars().all()

        return { "surveys": surveys, "length": len(surveys) }




@survey_router.get("/surveys/{id}", status_code=200, response_model=SurveyResponse)
async def get_survey_by_id(id:uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        if current_user.role == "admin":
            result = await db.execute(select(Survey).join(User).where(Survey.id == id))

        if current_user.role == "researcher" or current_user.role == "participant":
            result = await db.execute(select(Survey).join(User).where(and_(Survey.id == id, User.organization_id == current_user.organization_id)))

        survey = result.unique().scalars().first()   

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

        existing_survey = result.unique().scalars().first()

        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")

        await db.execute(update(Survey).where(Survey.id == id).values(survey.model_dump()))
        await db.commit()
    

        return existing_survey
    


@survey_router.delete("/surveys/{id}", status_code=204)
@required_roles(["admin", "researcher"])
async def delete_survey(id:uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})

        if current_user.role == "admin":
            result = await db.execute(select(Survey).join(User).where(Survey.id == id))

        if current_user.role == "researcher":
            result = await db.execute(select(Survey).join(User).where(and_(Survey.id == id, User.organization_id == current_user.organization_id)))

        survey = result.unique().scalars().first()  

        if not survey:
            raise HTTPException(status_code=404, detail="Survey not found")

        await db.delete(survey)
        await db.commit()

        return None

@survey_router.post("/surveys", status_code=201, response_model=SurveyResponse)
@required_roles(["admin", "researcher"])
async def create_survey(survey: SurveyCreate, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

    if not current_user:
        raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    
    #check if category exists
    result = await db.execute(select(Category).where(Category.id == survey.category_id))
    category = result.unique().scalars().first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    
    #check if survey exists in this category (by name)
    result = await db.execute(select(Survey).where(Survey.name == survey.name, Survey.category_id == survey.category_id))
    existing_survey = result.unique().scalars().first()
    if existing_survey:
        raise HTTPException(status_code=400, detail="Survey name already registered in this category")
    
    #researcher id: check if researcher org and category org match
    result = await db.execute(select(User).where(User.id == survey.researcher_id, User.organization_id == category.organization_id))
    researcher = result.unique().scalars().first()
    if not researcher:
        raise HTTPException(status_code=404, detail="Researcher not found")
    
    #check if start_date is not before today and end_date is after start_date
    if survey.start_date and survey.start_date < date.today():
        raise HTTPException(status_code=400, detail="Start date cannot be in the past")
    if survey.start_date and survey.end_date and survey.start_date > survey.end_date:
        raise HTTPException(status_code=400, detail="Start date cannot be after end date")
    
    #questions
    # descriptions and number should be unique
    #options:
    # description should be unique
    # if the question referenced is not multiple_answer, then there should be at most one correct answer
    # if the question referenced is multiple_answer, then there should be at least one correct answer

    questions_descriptions = set()
    
    
    for question in survey.questions:
        if question.description in questions_descriptions:
            raise HTTPException(status_code=400, detail=f"Duplicated question description: {question.description}")

        questions_descriptions.add(question.description)
        
        options_descriptions = set()
        correct_options_count = 0   
        for option in question.options:
            if option.description in options_descriptions:
                raise HTTPException(status_code=400, detail=f"Duplicated option description: {option.description}")
            options_descriptions.add(option.description)
            if option.is_correct:
                correct_options_count += 1

        if question.has_correct_answer:
            if question.multiple_answer and correct_options_count == 0:
                    raise HTTPException(status_code=400, detail="Multiple answer question must have at least one correct answer")
            if not question.multiple_answer and correct_options_count > 1:
                    raise HTTPException(status_code=400, detail="Single answer question must have at most one correct answer")
    

    try:
        # Crear el cuestionario
        new_survey = Survey(
            name=survey.name, 
            description=survey.description, 
            start_date=survey.start_date, 
            end_date=survey.end_date, 
            researcher_id=survey.researcher_id, 
            category_id=survey.category_id
        )
        db.add(new_survey)
        await db.flush()  # Flush para obtener el ID del survey
        
        # Crear las preguntas
        created_questions = []
        question_number = 1
        
        for q_data in survey.questions:
            new_question = Question(
                number=question_number,
                description=q_data.description,
                multiple_answer=q_data.multiple_answer,
                survey_id=new_survey.id,  # Usar el ID directamente
                required=q_data.required,
                has_correct_answer=q_data.has_correct_answer
            )
            db.add(new_question)
            created_questions.append((new_question, q_data.options))
            question_number += 1
        
        await db.flush()  # Flush para obtener los IDs de las preguntas
        
        # Crear las opciones
        for question, options_data in created_questions:
            for option_data in options_data:
                new_option = Option(
                    description=option_data.description,
                    is_correct=option_data.is_correct,
                    question_id=question.id  # Usar el ID directamente
                )
                db.add(new_option)
        
        await db.commit()  # Commit final
        
        # Cargar las preguntas con sus opciones usando una consulta explícita
        result = await db.execute(
            select(Question)
            .options(selectinload(Question.options))
            .where(Question.survey_id == new_survey.id)
            .order_by(Question.number)
        )
        loaded_questions = result.unique().scalars().all()
        
        # Construir la respuesta
        response = SurveyResponse(
            id=new_survey.id,
            name=new_survey.name,
            description=new_survey.description,
            start_date=new_survey.start_date,
            end_date=new_survey.end_date,
            researcher_id=new_survey.researcher_id,
            category_id=new_survey.category_id,
            questions=[
                QuestionResponse(
                    id=q.id,
                    number=q.number,
                    description=q.description,
                    multiple_answer=q.multiple_answer,
                    survey_id=q.survey_id,
                    required=q.required,
                    has_correct_answer=q.has_correct_answer,
                    options=[
                        OptionResponse(
                            id=o.id,
                            description=o.description,
                            is_correct=o.is_correct,
                            question_id=o.question_id
                        ) for o in q.options
                    ]
                ) for q in loaded_questions
            ]
        )
        
        return response
        
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating survey: {str(e)}")






