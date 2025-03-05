from datetime import datetime
from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import and_, select, update
from models.CategoryModel import Category
from models.SurveyModel import Survey
from models.SurveyParticipantModel import survey_participant
from auth.Auth import get_current_user, required_roles
from models.UserModel import User
from database import get_db
from sqlalchemy.ext.asyncio import AsyncSession
from schemas.SurveySchema import *
from schemas.UserSchema import *


survey_participants_router = APIRouter(tags=["Survey Participant"])

"""
1. Obtener todos los participantes asociados a un cuestionario
2. Obtener todos los cuestionarios a los que está asociado un participante
3. Asignar un participante a un cuestionario
4. Desasignar un participante a un cuestionario
"""
@survey_participants_router.get("/surveys/{id}/participants", status_code=200, response_model=UserResponseWithLength)
@required_roles(["admin", "researcher"])
async def get_all_survey_participants(id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    if not current_user:
        raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    
    if current_user.role == "admin":
            result = await db.execute(select(User).join(survey_participant).join(Survey).where(and_(Survey.id == id, 
                                                                                                    Survey.id == survey_participant.c.survey_id, 
                                                                                                    User.id == survey_participant.c.participant_id, 
                                                                                                    User.role == "participant")))

    if current_user.role == "researcher":
            result = await db.execute(select(User).join(survey_participant).join(Survey).where(and_(Survey.id == id,
                                                                                                    Survey.id == survey_participant.c.survey_id, 
                                                                                                    User.id == survey_participant.c.participant_id, 
                                                                                                    User.organization_id == current_user.organization_id, 
                                                                                                    User.role == "participant")))

    participants = result.unique().scalars().all()

    return { "users": participants, "length": len(participants) }
    

@survey_participants_router.get("/participants/{id}/surveys", status_code=200, response_model=SurveyResponseWithLength)
async def get_all_participant_surveys(id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)], category: Optional[uuid.UUID] = None):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        if current_user.role == "admin":
            result = await db.execute(select(Survey).join(survey_participant).join(User).where(and_(User.id == id,
                                                                                                    Survey.id == survey_participant.c.survey_id, 
                                                                                                    User.id == survey_participant.c.participant_id,
                                                                                                    User.role == "participant")))

        if current_user.role == "researcher" or current_user.role == "participant":
            if category:
                result = await db.execute(select(Survey).join(survey_participant).join(User).where(and_(User.id == id, 
                                                                                                    Survey.id == survey_participant.c.survey_id, 
                                                                                                    Survey.category_id == category,
                                                                                                    Survey.end_date >= datetime.now(),
                                                                                                    User.id == survey_participant.c.participant_id,
                                                                                                    User.organization_id == current_user.organization_id, User.role == "participant")))
            else:
                result = await db.execute(select(Survey).join(survey_participant).join(User).where(and_(User.id == id,
                                                                                                    Survey.id == survey_participant.c.survey_id, 
                                                                                                    User.id == survey_participant.c.participant_id,
                                                                                                    Survey.end_date >= datetime.now(),
                                                                                                    User.organization_id == current_user.organization_id, User.role == "participant")))
        
        surveys = result.unique().scalars().all()

        return { "surveys": surveys, "length": len(surveys)}
    

@survey_participants_router.post("/surveys/{id}/participants/add", status_code=200, response_model=UserResponseWithLength)
@required_roles(["admin", "researcher"])
async def assign_participant_to_survey(id: uuid.UUID, user: AssignParticipantToSurvey, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        result = await db.execute(select(Survey).where(Survey.id == id))
        existing_survey = result.scalars().first()

        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        
        #check if participant exists
        result = await db.execute(select(User).where(and_(User.email == user.email, User.role == "participant")))
        existing_participant = result.scalars().first()

        if not existing_participant:
            raise HTTPException(status_code=404, detail="Participant not found")

        #check if user is already assigned to the survey
        assignment_query = await db.execute(
            select(User)
            .join(User.surveys_participant)
            .where(and_(
                User.id == existing_participant.id,
                Survey.id == existing_survey.id
            ))
        )
        existing_assignment = assignment_query.scalars().first()
        
        if existing_assignment:
            raise HTTPException(status_code=400, detail="Participant already assigned to this survey")
        

        #check if survey and participant are from the same organization
        result = await db.execute(select(Category).where(and_(Category.id == existing_survey.category_id,
                                                                              Category.organization_id == existing_participant.organization_id)))
        belongs_to_same_org = result.scalars().first()
        
        if not belongs_to_same_org:
            raise HTTPException(status_code=403, detail="Forbidden")
        
        #check if researcher is trying to assign participant to survey of another organization
        if current_user.role == "researcher" and existing_participant.organization_id != current_user.organization_id:
            raise HTTPException(status_code=403, detail="Forbidden")

        new_assignment =  survey_participant.insert().values(
            participant_id=existing_participant.id,
            survey_id=existing_survey.id
        )

        await db.execute(new_assignment)
        await db.commit()

        #ahora devolvemos la lista de participantes del cuestionario
        result = await db.execute(select(User).join(survey_participant).join(Survey).where(and_(Survey.id == existing_survey.id, 
                                                                                                Survey.id == survey_participant.c.survey_id, 
                                                                                                User.id == survey_participant.c.participant_id,
                                                                                                User.role == "participant")))
        participants = result.scalars().all()

        return { "users": participants, "length": len(participants) }
    
    

@survey_participants_router.delete("/surveys/{id}/participants/delete", status_code=200, response_model=UserResponseWithLength)
@required_roles(["admin", "researcher"])
async def remove_participant_from_survey(id: uuid.UUID, user: RemoveParticipantFromSurvey, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        result = await db.execute(select(Survey).where(Survey.id == id))
        existing_survey = result.scalars().first()

        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        
        #check if participant exists
        result = await db.execute(select(User).where(and_(User.email == user.email, User.role == "participant")))
        existing_participant = result.scalars().first()

        if not existing_participant:
            raise HTTPException(status_code=404, detail="Participant not found")

        #check if user is already assigned to the survey
        assignment_query = await db.execute(
            select(User)
            .join(User.surveys_participant)
            .where(and_(
                User.id == existing_participant.id,
                Survey.id == existing_survey.id
            ))
        )
        existing_assignment = assignment_query.scalars().first()
        
        if not existing_assignment:
            raise HTTPException(status_code=400, detail="Participant not assigned to this survey")
        
        
        #check if researcher is trying to remove the participant from the survey of another organization
        if current_user.role == "researcher" and existing_participant.organization_id != current_user.organization_id:
            raise HTTPException(status_code=403, detail="Forbidden")

        removed_assignment = survey_participant.delete().where(and_(survey_participant.c.participant_id == existing_participant.id,
                                                                  survey_participant.c.survey_id == existing_survey.id))

        await db.execute(removed_assignment)
        await db.commit()

        #ahora devolvemos la lista de participantes del cuestionario
        result = await db.execute(select(User).join(survey_participant).join(Survey).where(and_(Survey.id == existing_survey.id, 
                                                                                                Survey.id == survey_participant.c.survey_id, 
                                                                                                User.id == survey_participant.c.participant_id,
                                                                                                User.role == "participant")))
        participants = result.scalars().all()

        return { "users": participants, "length": len(participants) }
    
