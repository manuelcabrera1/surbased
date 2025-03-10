from typing import Annotated
import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import delete, or_, select, update, and_
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
from models.SurveyParticipantModel import survey_participant
from datetime import datetime



answer_router = APIRouter(tags=["Answer"])


        
@answer_router.post("/surveys/{survey_id}/answers", status_code=201, response_model=AnswerResponse)
async def register_survey_answers(survey_id: uuid.UUID, answer: AnswerCreate, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):

    if not current_user:
        raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    
    #check if participant exists and is assigned to the survey
    if current_user.role == "participant":
        result = await db.execute(select(survey_participant).where(and_(survey_participant.c.participant_id == current_user.id, 
                                                                              survey_participant.c.survey_id == survey_id)))
        
        assignment = result.unique().scalars().first()
        if not assignment:
            raise HTTPException(status_code=400, detail="Participant not assigned to the survey")
        
    #check if survey exists and it is created in the user organization scope 
    # (EN TEORIA, SI EL USER ESTA ASIGNADO AL CUESTIONARIO ES QUE YA ESTA EN EL SCOPE LUEGO NO HAY QUE REVISARLO)
    result = await db.execute(select(Survey).join(Category).where(Survey.id == survey_id,
                                                                  Survey.category_id == Category.id,
                                                                Category.organization_id == current_user.organization_id))
    
    survey = result.unique().scalars().first()
    if not survey:
        raise HTTPException(status_code=400, detail="Survey not found")
    
    #for each question:
        # check if question belongs to survey
        # for each option:
            #check if option belong to question
            # if there are more than option related to question, check if the question is multiple_answer

    for question in answer.questions:
        #check if question belongs to survey
        result = await db.execute(select(Question).where(Question.id == question.id, Question.survey_id == survey_id))
        question = result.unique().scalars().first()
        if not question:
            raise HTTPException(status_code=400, detail="Question not found in this survey")
        
        #check if there are answers registered for this question
        result = await db.execute(select(Answer).where(Answer.question_id == question.id, Answer.participant_id == current_user.id))
        answers = result.unique().scalars().all()
        if answers:
            await db.execute(delete(Answer).where(Answer.question_id == question.id, Answer.participant_id == current_user.id))
        
        option_count = 0
        for option in question.options:
            #check if option belong to question
            result = await db.execute(select(Option).where(Option.id == option.id, Option.question_id == question.id))
            option = result.unique().scalars().first()
            if not option:
                raise HTTPException(status_code=400, detail="Option not found in this question")
            option_count += 1
            
    
        if option_count == 0:
            raise HTTPException(status_code=400, detail="Question has no answers")
        
        if option_count > 1 and not question.multiple_answer:
            raise HTTPException(status_code=400, detail="Question is not multiple answer")

    #create answers in one transaction
    try:
        for question in answer.questions:
            for option in question.options:
                new_answer = Answer(
                    participant_id=current_user.id,
                    option_id=option.id,
                    question_id=question.id,
                )
                db.add(new_answer)
        await db.commit()

        #set new updated_at for the survey
        await db.execute(update(survey_participant).where(and_(survey_participant.c.survey_id == survey_id, survey_participant.c.participant_id == current_user.id)).values(updated_at=datetime.now()))
        await db.commit()

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
        "total": len(answers_list)
    }
        


    

