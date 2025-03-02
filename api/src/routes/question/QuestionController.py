from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import delete, or_, select, update, and_
from models.CategoryModel import Category
from models.SurveyModel import Survey
from models.QuestionModel import Question
from schemas.QuestionSchema import *
from database import get_db
from sqlalchemy.ext.asyncio import AsyncSession
from auth.Auth import get_current_user, required_roles
from models.UserModel import User

"""
crear pregunta de un cuestionario
obtener preguntas de un cuestionario
modificar una pregunta de un cuestionario
eliminar una pregunta de un cuestionario
"""


question_router = APIRouter(tags=["Question"])

@question_router.post("/surveys/{id}/questions", status_code=200, response_model=QuestionResponse)
@required_roles(["admin", "researcher"])
async def create_question(id: uuid.UUID, question: QuestionCreateRequest, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        if current_user.role == "admin":
            result = await db.execute(select(Survey).where(Survey.id == id))
        existing_survey = result.scalars().first()

        if current_user.role == "researcher":
            result = await db.execute(select(Survey).join(Category).where(Survey.id == id, 
                                                                        Survey.category_id == Category.id, 
                                                                        Category.organization_id == current_user.organization_id))

        existing_survey = result.scalars().first()
        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        
        #check if question already exists in survey
        result2 = await db.execute(select(Question).where(Question.survey_id == id))
        questions = result2.scalars().all()

        existing_question = next((q for q in questions if q.description == question.description or q.number == question.number), None)

        if existing_question:
                raise HTTPException(status_code=400, detail="Question already exists")
        
        #check if question number is bigger than the survey questions
        if question.number > (len(questions) + 1):
            raise HTTPException(status_code=400, detail="Question number is bigger than the survey questions")
            
        
        #create question
        new_question = Question(
            number=question.number,
            description=question.description,
            multiple_answer=question.multiple_answer,
            survey_id=id
        )
        db.add(new_question)
        await db.commit()
        await db.refresh(new_question)

        return new_question
        


@question_router.get("/surveys/{id}/questions", status_code=200, response_model=QuestionResponseWithLength)
async def get_survey_questions(id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        if current_user.role == "admin":
            result = await db.execute(select(Survey).where(Survey.id == id))
        
        if current_user.role == "researcher":
            result = await db.execute(select(Survey).join(Category).where(and_(Survey.id == id, 
                                                                        Survey.category_id == Category.id, 
                                                                        Category.organization_id == current_user.organization_id)))
        
        existing_survey = result.scalars().first()

        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        
        
        #get questions
        result = await db.execute(select(Question).where(Question.survey_id == id))
        
        questions = result.scalars().all()
        return {"questions": questions, "length": len(questions)}
    


@question_router.get("/surveys/{survey_id}/questions/{question_id}", status_code=200, response_model=QuestionResponse)
async def get_survey_question_by_id(survey_id: uuid.UUID, id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        if current_user.role == "admin":
            result = await db.execute(select(Survey).where(Survey.id == id))
        
        if current_user.role == "researcher":
            result = await db.execute(select(Survey).join(Category).where(and_(Survey.id == id, 
                                                                        Survey.category_id == Category.id, 
                                                                        Category.organization_id == current_user.organization_id)))
        
        existing_survey = result.scalars().first()

        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        
        
        #get question
        result = await db.execute(select(Question).where(and_(Question.survey_id == survey_id, Question.id == id)))
        question = result.scalars().first()

        if not question:
            raise HTTPException(status_code=404, detail="Question not found")
        
        
        return question
    


@question_router.put("/surveys/{survey_id}/questions/{question_id}", status_code=200, response_model=QuestionResponse)
@required_roles(["admin", "researcher"])
async def update_question(survey_id: uuid.UUID, question_id: uuid.UUID, question: QuestionUpdateRequest, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        if current_user.role == "admin":
            result = await db.execute(select(Survey).where(Survey.id == survey_id))
        else:
            result = await db.execute(
                select(Survey)
                .join(Category)
                .where(and_(
                    Survey.id == survey_id, 
                    Survey.category_id == Category.id, 
                    Category.organization_id == current_user.organization_id
                ))
            )
        existing_survey = result.scalars().first()
        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")

        
        result2 = await db.execute(select(Question).where(Question.survey_id == survey_id))
        questions = result2.scalars().all()
        
        existing_question = next((q for q in questions if q.id == question_id), None)

        if not existing_question:
            raise HTTPException(status_code=404, detail="Question not found")

        
        #check if question number is bigger than the survey questions
        if question.number > len(questions):
            print(question.number, len(questions))
            raise HTTPException(status_code=400, detail="Question number is bigger than the survey questions")
        
        #check if question number is already in use
        if question.number != existing_question.number:
            number_exists = any(q.number == question.number for q in questions)
            if number_exists:
                raise HTTPException(status_code=400, detail="Question number already in use")
        
        #check if question description is already in use
        if question.description != existing_question.description:
            desc_query = await db.execute(
                select(Question).where(and_(
                    Question.description == question.description,
                    Question.survey_id == survey_id,
                    Question.id != question_id
                ))
            )
            if desc_query.scalar_one_or_none():
                raise HTTPException(status_code=400, detail="Question description already in use")
        
        #update question
        await db.execute(update(Question).where(Question.id == question_id).values(question.model_dump()))
        await db.commit()

        return existing_question
    


@question_router.delete("/surveys/{survey_id}/questions/{question_id}", status_code=204)
@required_roles(["admin", "researcher"])
async def delete_question(survey_id: uuid.UUID, question_id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
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
        
        #check if question exists in survey
        result2 = await db.execute(select(Question).where(Question.survey_id == survey_id))
        questions = result2.scalars().all()

        existing_question = next((q for q in questions if q.id == question_id), None)

        if not existing_question:
            raise HTTPException(status_code=404, detail="Question not found")


        
        await db.execute(delete(Question).where(Question.id == question_id))
        await db.commit()

        return None
        
