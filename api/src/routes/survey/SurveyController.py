from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, insert, or_, select, update, and_
from models.TagModel import Tag
from models.AnswerModel import Answer
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
from models.SurveyTagModel import survey_tag


survey_router = APIRouter(tags=["Survey"])

@survey_router.get("/surveys/{scope}", status_code=200, response_model=SurveyResponseWithLength)
@required_roles(["admin", "researcher", "participant"])
async def get_surveys_by_scope(current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)], 
                        scope: SurveyScopeEnum):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    
        if scope == SurveyScopeEnum.public:
            result = await db.execute(select(Survey).where(Survey.scope == SurveyScopeEnum.public))
        else: 
            if current_user.role != "admin":
                raise HTTPException(status_code=403, detail="Forbidden")
            result = await db.execute(select(Survey).where(Survey.scope == scope))
    

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
    
    if survey.scope == SurveyScopeEnum.organization:
        #check if org id is provided
        if not survey.organization_id:
            raise HTTPException(status_code=400, detail="Organization must be specified")

        #check if researcher org and survey org match
        result = await db.execute(select(User).where(User.id == survey.owner_id, User.organization_id == survey.organization_id))
        researcher = result.unique().scalars().first()
        if not researcher:
            raise HTTPException(status_code=404, detail="Researcher does not belong to the specified organization")
          
    
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
        options_count = 0   
        for option in question.options:
            if option.description in options_descriptions:
                raise HTTPException(status_code=400, detail=f"Duplicated option description: {option.description}")
            options_descriptions.add(option.description)
            options_count+=1
        
        if options_count <= 1 and question.type != "open":
            raise HTTPException(status_code=400, detail=f"Question {question.description} must have at least two options")  

    try:
        # Crear el cuestionario
        new_survey = Survey(
            name=survey.name, 
            description=survey.description,
            scope=survey.scope,
            organization_id=survey.organization_id,
            start_date=survey.start_date, 
            end_date=survey.end_date, 
            owner_id=survey.owner_id, 
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
                survey_id=new_survey.id,  # Usar el ID directamente
                required=q_data.required,
                type=q_data.type
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
                    points=option_data.points,
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

        #check if tags exist, if not, create them
        if survey.tags:  # Solo procesar tags si hay alguno
            survey_tags_names = [tag.name for tag in survey.tags]
            result = await db.execute(select(Tag).where(Tag.name.in_(survey_tags_names)))
            existing_tags = result.unique().scalars().all()

            new_tags = []

            if len(existing_tags) != len(survey_tags_names):
                existing_tags_names = [t.name for t in existing_tags]
                tags_to_add = list(set(survey_tags_names) - set(existing_tags_names))
                
                new_tags = [Tag(name=tag) for tag in tags_to_add]

                db.add_all(new_tags)
                await db.flush()
            
            await db.execute(insert(survey_tag).values(
                [{"survey_id": new_survey.id, "tag_id": tag.id} for tag in new_tags] + 
                [{"survey_id": new_survey.id, "tag_id": tag.id} for tag in existing_tags]))
            await db.commit()
        
        # Construir la respuesta
        response = SurveyResponse(
            id=new_survey.id,
            name=new_survey.name,
            description=new_survey.description,
            scope=new_survey.scope,
            start_date=new_survey.start_date,
            end_date=new_survey.end_date,
            owner_id=new_survey.owner_id,
            category_id=new_survey.category_id,
            questions=[
                QuestionResponse(
                    id=q.id,
                    number=q.number,
                    description=q.description,
                    type=q.type,
                    survey_id=q.survey_id,
                    required=q.required,
                    options=[
                        OptionResponse(
                            id=o.id,
                            description=o.description,
                            points=o.points,
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



@survey_router.get("/surveys/owner/{owner_id}", status_code=200, response_model=SurveyResponseWithLength)
@required_roles(["admin", "researcher"])
async def get_surveys_by_owner(current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)], owner_id: uuid.UUID):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        result = await db.execute(select(User).where(User.id == owner_id))
        owner = result.unique().scalars().first()
        if not owner:
            raise HTTPException(status_code=404, detail="Owner not found")
        
        if current_user.role == "researcher" and (owner.organization_id != current_user.organization_id or owner.id != current_user.id):
            raise HTTPException(status_code=403, detail="Forbidden")

        #de momento no se muestran las encuestas de organizacion en esta vista
        result = await db.execute(select(Survey).where(and_(Survey.owner_id == owner_id, Survey.scope != SurveyScopeEnum.organization)))
    
        surveys = result.unique().scalars().all()


        surveys = sorted(surveys, key=lambda x: x.end_date, reverse=True)
       

        return { "surveys": surveys, "length": len(surveys) }

@survey_router.get("/surveys/public/highlighted", status_code=200, response_model=SurveyResponseWithLength)
async def get_highlighted_public_surveys(current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    
    if not current_user:
        raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    
    # Consulta para obtener las encuestas más populares basadas en el número de respuestas
    result = await db.execute(
        select(
            Survey,
            func.count(Answer.question_id).label("response_count")
        )
        .join(Question, Survey.id == Question.survey_id)
        .join(Answer, Question.id == Answer.question_id)
        .where(and_(Survey.end_date >= date.today(), Survey.end_date.isnot(None)))
        .group_by(Survey.id)
        .order_by(func.count(Answer.question_id).desc())
        .limit(5)
    )
    
    # Obtener los resultados y asignar el conteo a cada encuesta
    surveys_with_counts = result.all()
    surveys = []
    for survey, count in surveys_with_counts:
        survey.response_count = count
        surveys.append(survey)

    return {"surveys": surveys, "length": len(surveys)}










