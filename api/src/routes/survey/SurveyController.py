from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, insert, or_, select, update, and_
from src.models.TagModel import Tag
from src.models.AnswerModel import Answer
from src.models.QuestionModel import Question
from src.models.OptionModel import Option
from src.schemas.OptionSchema import OptionResponse
from src.schemas.QuestionSchema import QuestionResponse
from src.models.CategoryModel import Category
from src.models.UserModel import User
from src.models.SurveyModel import Survey
from src.schemas.SurveySchema import *
import bcrypt
from src.database import get_db
from typing import Annotated, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi.security import OAuth2PasswordRequestForm
from src.auth.Auth import create_access_token, check_current_user, oauth_scheme, get_current_user, required_roles
from sqlalchemy.orm import selectinload
from src.models.SurveyTagModel import survey_tag


survey_router = APIRouter(tags=["Survey"])

@survey_router.get("/surveys/", status_code=200, response_model=SurveyResponseList)
@required_roles(["admin", "researcher", "participant"])
async def get_surveys_by_scope(current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)], 
                        scope: SurveyScopeEnum):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    
        if scope == SurveyScopeEnum.public:
            result = await db.execute(select(Survey).where(and_(Survey.scope == SurveyScopeEnum.public, Survey.end_date >= date.today())))
        else: 
            if current_user.role != "admin":
                raise HTTPException(status_code=403, detail="Forbidden")
            result = await db.execute(select(Survey).where(Survey.scope == scope))
    

        surveys = result.unique().scalars().all()

        return surveys

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


@survey_router.delete("/surveys/{id}", status_code=204)
@required_roles(["admin", "researcher"])
async def delete_survey(id:uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})

        
        result = await db.execute(select(Survey).join(User).where(Survey.id == id))

        survey = result.unique().scalars().first()  

        if not survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        
        if current_user.role == "researcher" and survey.owner_id != current_user.id:
            raise HTTPException(status_code=403, detail="Forbidden")

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



@survey_router.get("/surveys/owner/{owner_id}", status_code=200, response_model=SurveyResponseList)
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
       

        return surveys

@survey_router.get("/surveys/public/highlighted", status_code=200, response_model=SurveyResponseList)
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

    return surveys


@survey_router.put("/surveys/{id}", status_code=200, response_model=SurveyResponse)
@required_roles(["admin", "researcher"])
async def update_survey(id: uuid.UUID, survey: SurveyUpdate, current_user: Annotated[User, Depends(get_current_user)], 
                       db: Annotated[AsyncSession, Depends(get_db)]):
    if not current_user:
        raise HTTPException(status_code=401, detail="Could not validate credentials")

    # Obtener el cuestionario existente con sus preguntas y opciones
    result = await db.execute(
        select(Survey)
        .options(selectinload(Survey.questions).selectinload(Question.options))
        .where(Survey.id == id)
    )
    existing_survey = result.unique().scalars().first()

    if not existing_survey:
        raise HTTPException(status_code=404, detail="Survey not found")

    if survey.category_id and survey.category_id != existing_survey.category_id:
        result = await db.execute(select(Category).where(Category.id == survey.category_id))
        category = result.unique().scalars().first()
        if not category:
            raise HTTPException(status_code=404, detail="Category not found")
    

    if survey.scope == SurveyScopeEnum.organization:
        #check if org id is provided
        if not survey.organization_id:
            raise HTTPException(status_code=400, detail="Organization must be specified")

        #check if researcher org and survey org match
        if survey.owner_id and survey.owner_id != existing_survey.owner_id:
            result = await db.execute(select(User).where(User.id == survey.owner_id, User.organization_id == survey.organization_id))
            researcher = result.unique().scalars().first()
            if not researcher:
                raise HTTPException(status_code=404, detail="Researcher does not belong to the specified organization")
    

    if survey.start_date and survey.end_date and survey.start_date > survey.end_date:
        raise HTTPException(status_code=400, detail="Start date cannot be after end date")
    

    # Actualizar datos básicos del cuestionario
    if survey.name:
        existing_survey.name = survey.name
    if survey.description:
        existing_survey.description = survey.description
    if survey.scope:
        existing_survey.scope = survey.scope
    if survey.organization_id:
        existing_survey.organization_id = survey.organization_id
    if survey.start_date:
        existing_survey.start_date = survey.start_date
    if survey.end_date:
        existing_survey.end_date = survey.end_date
    if survey.category_id:
        existing_survey.category_id = survey.category_id

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

            for tag in existing_survey.tags:
                if tag.name not in survey_tags_names:
                    await db.delete(survey_tag.where(survey_tag.tag_id == tag.id, survey_tag.survey_id == existing_survey.id))

                if tag.name in existing_tags_names:
                    new_tags.append(tag)
        
        await db.execute(insert(survey_tag).values(
            [{"survey_id": existing_survey.id, "tag_id": tag.id} for tag in new_tags]))
        
        await db.commit()

    existing_questions = {q.id: q for q in existing_survey.questions}
    new_questions = {q.id: q for q in survey.questions}

    question_number = 1

    # Procesar preguntas
    for question_id, new_question in new_questions.items():
        if question_id in existing_questions:
            # Actualizar pregunta existente
            existing_question = existing_questions[question_id]
            existing_question.description = new_question.description
            existing_question.required = new_question.required
            existing_question.type = new_question.type
            existing_question.number = question_number
            existing_question.survey_id = existing_survey.id

            # Procesar opciones
            existing_options = {o.id: o for o in existing_question.options}
            new_options = {o.id: o for o in new_question.options}

            # Actualizar/Añadir opciones
            for opt_id, new_opt in new_options.items():
                if opt_id in existing_options:
                    # Actualizar opción existente
                    existing_options[opt_id].points = new_opt.points
                    existing_options[opt_id].description = new_opt.description
                else:
                    # Añadir nueva opción
                    new_option = Option(
                        description=new_opt.description,
                        points=new_opt.points,
                        question_id=existing_question.id
                    )
                    db.add(new_option)
                    await db.flush()

            # Eliminar opciones que ya no existen
            for opt_id, old_opt in existing_options.items():
                if opt_id not in new_options:
                    await db.delete(old_opt)

        else:
            # Añadir nueva pregunta
            new_q = Question(
                number=question_number,
                description=new_question.description,
                survey_id=existing_survey.id,
                required=new_question.required,
                type=new_question.type
            )
            db.add(new_q)
            await db.flush()  # Para obtener el ID

            # Añadir sus opciones
            for option in new_question.options:
                new_option = Option(
                    description=option.description,
                    points=option.points,
                    question_id=new_q.id
                )
                db.add(new_option)

        question_number += 1

    # Eliminar preguntas que ya no existen
    for question_id, old_question in existing_questions.items():
        if question_id not in new_questions:
            await db.delete(old_question)

    try:
        await db.commit()
        
        # Recargar el cuestionario actualizado
        result = await db.execute(
            select(Survey)
            .options(selectinload(Survey.questions).selectinload(Question.options))
            .where(Survey.id == id)
        )
        updated_survey = result.unique().scalars().first()
        
        return updated_survey

    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating survey: {str(e)}")










