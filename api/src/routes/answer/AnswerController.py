from typing import Annotated
import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import delete, or_, select, update, and_
from schemas.SurveySchema import SurveyScopeEnum
from models.AnswerModel import Answer
from models.OptionModel import Option
from schemas.AnswerSchema import *
from models.CategoryModel import Category
from models.SurveyModel import Survey
from models.QuestionModel import Question
from database import get_db
from sqlalchemy.ext.asyncio import AsyncSession
from auth.Auth import get_current_user, required_roles
from models.UserModel import User
from models.SurveyUserModel import survey_user
from datetime import datetime



answer_router = APIRouter(tags=["Answer"])


        
@answer_router.post("/surveys/{survey_id}/answers", status_code=201, response_model=AnswerResponse)
async def register_survey_answers_from_user(survey_id: uuid.UUID, answer: AnswerCreate, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

    if not current_user:
        raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    

    result = await db.execute(select(Survey).where(Survey.id == survey_id))
    existing_survey = result.unique().scalars().first()
    if not existing_survey:
        raise HTTPException(status_code=400, detail="Survey not found")
    
    if existing_survey.scope == SurveyScopeEnum.private:
        #check if participant exists and is assigned to the survey
        result = await db.execute(select(survey_user).where(and_(survey_user.c.user_id == current_user.id, 
                                                                              survey_user.c.survey_id == survey_id)))
        assignment = result.unique().scalars().first()
        if not assignment:
            raise HTTPException(status_code=400, detail="User not assigned to the survey")

    if existing_survey.scope == SurveyScopeEnum.organization:
        #check if user belongs to the organization
        result = await db.execute(select(User).where(User.id == current_user.id, User.organization_id == existing_survey.organization_id))
        user = result.unique().scalars().first()
        if not user:
            raise HTTPException(status_code=400, detail="User not assigned to the organization")
    
    

    for q in answer.questions:
        #check if question belongs to survey
        result = await db.execute(select(Question).where(Question.id == q.id, Question.survey_id == survey_id))
        question = result.unique().scalars().first()
        if not question:
            raise HTTPException(status_code=400, detail="Question not found in this survey")
        
        #check if there are previous answers registered for this question
        result = await db.execute(select(Answer).where(Answer.question_id == q.id, Answer.participant_id == current_user.id))
        answers = result.unique().scalars().all()
        if answers:
            await db.execute(delete(Answer).where(Answer.question_id == q.id, Answer.participant_id == current_user.id))
        
        option_count = 0
        if question.type == QuestionTypeEnum.open:
            if not q.text:
                raise HTTPException(status_code=400, detail=f"Question {question.description} has no answer")
            
        else:
            if not q.options:
                raise HTTPException(status_code=400, detail=f"Question {question.description} has no options")
            
            for o in q.options:
                #check if option belong to question
                result = await db.execute(select(Option).where(Option.id == o.id, Option.question_id == q.id))
                option = result.unique().scalars().first()
                if not option:
                    raise HTTPException(status_code=400, detail="Option not found in this question")
            option_count += 1    
    
            if option_count == 0:
                raise HTTPException(status_code=400, detail="Question has no answers")
        
            if option_count > 1 and question.type != QuestionTypeEnum.multiple_choice:
                raise HTTPException(status_code=400, detail="Question is not multiple answer")

        

    #create answers in one transaction
    try:
        for question in answer.questions:
            print(question.text)
            print(question.options)

            if question.type == QuestionTypeEnum.open:
                new_answer = Answer(
                    participant_id=current_user.id,
                    text=question.text,
                    question_id=question.id,
                )
                db.add(new_answer)
            else:
                for option in question.options:
                    new_answer = Answer(
                        participant_id=current_user.id,
                        option_id=option.id,
                        question_id=question.id,
                    )
                db.add(new_answer)
            
        await db.commit()

        #set new updated_at for the survey
        #await db.execute(update(survey_user).where(and_(survey_user.c.survey_id == survey_id, survey_user.c.user_id == current_user.id)).values(updated_at=datetime.now()))
        #await db.commit()

    # return response 
        return AnswerResponse(
            survey_id=survey_id,
            questions=answer.questions
        )
    
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=str(e))


@answer_router.get("/answers", status_code=200)
async def get_all_user_answers(current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    #check current user
    if not current_user:
        raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    
    #get all answers from user
    result = await db.execute(
        select(Answer, Option, Question, Survey)
        .join(Option, Answer.option_id == Option.id)
        .join(Question, Answer.question_id == Question.id)
        .join(Survey, Question.survey_id == Survey.id)
        .where(Answer.participant_id == current_user.id)
    )
    answers = result.all()


    explored_answers = {}
    for answer, option, question, survey in answers:
        if survey.id not in explored_answers:
            explored_answers[survey.id] = {
                "survey_id": survey.id,
                "questions": []
            }
        question_found = False
        for q in explored_answers[survey.id]["questions"]:
            if q["id"] == str(question.id):
                q["options"].append({
                    "id": str(option.id),
                })
                question_found = True
                break
        if not question_found:
            explored_answers[survey.id]["questions"].append({
                "id": str(question.id),
                "options": [{
                    "id": str(option.id),
                }]
            })
    answers_list = list(explored_answers.values())
    
    return {
        "answers": answers_list,
        "length": len(answers_list)
    }
        

@answer_router.get("/surveys/{survey_id}/answers", status_code=200)
async def get_survey_answers(
    survey_id: uuid.UUID,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    if not current_user:
        raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    
    # Verificar que el usuario tiene acceso a la encuesta
    result = await db.execute(select(Survey).where(Survey.id == survey_id))
    survey = result.unique().scalars().first()
    
    if not survey:
        raise HTTPException(status_code=404, detail="Survey not found")
    
    # Verificar permisos según el scope de la encuesta
    if survey.scope == SurveyScopeEnum.private:
        # Verificar si el usuario está asignado a la encuesta
        result = await db.execute(
            select(survey_user).where(
                and_(
                    survey_user.c.user_id == current_user.id,
                    survey_user.c.survey_id == survey_id
                )
            )
        )
        assignment = result.unique().scalars().first()

        if not assignment and survey.owner_id != current_user.id:
            raise HTTPException(status_code=403, detail="Access denied: User not assigned to this survey")

    elif survey.scope == SurveyScopeEnum.organization:
        # Verificar si el usuario pertenece a la misma organización
        if current_user.organization_id != survey.organization_id:
            raise HTTPException(status_code=403, detail="Access denied: User not in the same organization")

    # Obtener todas las respuestas de la encuesta
    result = await db.execute(
        select(Answer, Option, Question, User)
        .join(Question, Answer.question_id == Question.id)
        .join(User, Answer.participant_id == User.id)
        .outerjoin(Option, Answer.option_id == Option.id)  # Usamos outerjoin para incluir respuestas sin opciones (texto)
        .where(Question.survey_id == survey_id)
    )
    answers = result.all()

    # Estructurar las respuestas
    explored_answers = {}
    for answer, option, question, user in answers:
        if user.id not in explored_answers:
            explored_answers[user.id] = {
                "user_id": str(user.id),
                "username": f"{user.name} {user.lastname or ''}",
                "questions": []
            }
        
        question_found = False
        for q in explored_answers[user.id]["questions"]:
            if q["id"] == str(question.id):
                if question.type == "open":
                    # Para preguntas abiertas, guardamos el texto directamente
                    q["text"] = answer.text
                else:
                    # Para otros tipos de preguntas, guardamos las opciones
                    if option:  # Verificamos que la opción existe
                        if "options" not in q:
                            q["options"] = []
                        q["options"].append({
                            "id": str(option.id),
                            "description": option.description,
                            "points": option.points
                        })
                question_found = True
                break
        
        if not question_found:
            new_question = {
                "id": str(question.id),
                "description": question.description,
                "type": question.type,
            }
            
            if question.type == "open":
                # Para preguntas abiertas, incluimos el texto
                new_question["text"] = answer.text
            else:
                # Para otros tipos, incluimos la lista de opciones
                if option:  # Verificamos que la opción existe
                    new_question["options"] = [{
                        "id": str(option.id),
                        "description": option.description,
                        "points": option.points
                    }]
                else:
                    new_question["options"] = []
            
            explored_answers[user.id]["questions"].append(new_question)

    answers_list = list(explored_answers.values())
    
    return {
        "answers": answers_list,
        "length": len(answers_list)
    }


    

