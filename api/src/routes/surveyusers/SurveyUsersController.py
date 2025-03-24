from datetime import datetime
from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import and_, or_, select, update
from models.CategoryModel import Category
from models.SurveyModel import Survey
from models.SurveyUserModel import survey_user
from auth.Auth import get_current_user, required_roles
from models.UserModel import User
from database import get_db
from sqlalchemy.ext.asyncio import AsyncSession
from schemas.SurveySchema import *
from schemas.UserSchema import *


survey_users_router = APIRouter(tags=["Survey Users"])

"""
1. Obtener todos los participantes asociados a un cuestionario
2. Obtener todos los cuestionarios a los que está asociado un participante
3. Asignar un participante a un cuestionario
4. Desasignar un participante a un cuestionario
"""
@survey_users_router.get("/surveys/{id}/users", status_code=200, response_model=UserResponseWithLength)
@required_roles(["admin", "researcher"])
async def get_all_survey_assigned_users(id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    if not current_user:
        raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    
    

    result = await db.execute(select(Survey).where(Survey.id == id))
    existing_survey = result.unique().scalars().first()
    
    if not existing_survey:
        raise HTTPException(status_code=404, detail="Survey not found")
    
    
    users = []

    if existing_survey.scope == SurveyScopeEnum.organization:
        if current_user.role == "researcher" and current_user.organization_id != existing_survey.organization_id:
            raise HTTPException(status_code=403, detail="Forbidden")

        result = await db.execute(select(User, Survey).where(User.organization_id == existing_survey.organization_id))
        users_in_organization = result.unique().scalars().all()
        users.extend(users_in_organization)
    
    if existing_survey.scope == SurveyScopeEnum.private:
        result = await db.execute(select(User, Survey).where(and_(User.id == existing_survey.owner_id,
                                                                  Survey.id == existing_survey.id)))
        owner = result.unique().scalars().first()
        users.append(owner)
    
    # tanto si el scope es organization como si es private, se buscan los usuarios que están asignados al cuestionario
    result2 = await db.execute(select(User).join(survey_user).where(and_(survey_user.c.survey_id == id,
                                                                            User.id == survey_user.c.user_id)))
    
    users_assigned = result2.unique().scalars().all()
    print(users_assigned)
        

    users.extend(users_assigned)
        

    return { "users": users, "length": len(users) }
    

@survey_users_router.get("/users/{id}/surveys", status_code=200, response_model=SurveyResponseWithLength)
async def get_user_surveys_assigned(id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)], category: Optional[uuid.UUID] = None):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        

        result = await db.execute(select(User).where(User.id == id))
        existing_user = result.unique().scalars().first()

        if not existing_user:
            raise HTTPException(status_code=404, detail="User not found")
        
        if (existing_user.role == "participant" or existing_user.role == "researcher") and existing_user.id != current_user.id:
            raise HTTPException(status_code=403, detail="Forbidden")
        
        surveys = []

        """
        #buscamos los cuestionarios creados por el usuario
        if existing_user.role != "participant":
            result = await db.execute(select(Survey).where(and_(Survey.owner_id == existing_user.id,
                                                                Survey.scope != SurveyScopeEnum.organization)))
            surveys_owned = result.unique().scalars().all()
            surveys.extend(surveys_owned)
        """
       
        #buscamos los cuestionarios asignados al usuario
        result = await db.execute(select(Survey).join(survey_user).where(and_(survey_user.c.user_id == id,
                                                                            Survey.id == survey_user.c.survey_id)))
        surveys_assigned = result.unique().scalars().all()
        surveys.extend(surveys_assigned)


        return { "surveys": surveys, "length": len(surveys)}
    

@survey_users_router.post("/surveys/{id}/users/add", status_code=200, response_model=UserResponseWithLength)
@required_roles(["admin", "researcher"])
async def assign_users_to_survey(id: uuid.UUID, users: List[AssignParticipantToSurvey], current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        result = await db.execute(select(Survey).where(Survey.id == id))
        existing_survey = result.unique().scalars().first()

        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        
        if current_user.role == "researcher":
            #check if researcher from another organization is trying to assign users to the survey
            if existing_survey.scope == SurveyScopeEnum.organization and existing_survey.organization_id != current_user.organization_id:
                raise HTTPException(status_code=403, detail="Forbidden")
            
            #check if researcher is trying to assign users to a private survey that is not owned by them or is not moderated by them
            if existing_survey.scope == SurveyScopeEnum.private or existing_survey.scope == SurveyScopeEnum.public:
                result = await db.execute(select(survey_user).where(and_(survey_user.c.survey_id == existing_survey.id, survey_user.c.user_id == current_user.id)))
                existing_assignment = result.unique().scalars().first()
                
                if existing_survey.owner_id != current_user.id and not existing_assignment:
                    print(existing_survey.owner_id)
                    print(current_user.id)
                    raise HTTPException(status_code=403, detail="Forbidden")
        
        users_to_assign : List[User] = []
        #check if users exist
        for user in users:
            result = await db.execute(select(User).where(and_(User.email == user.email)))
            existing_user = result.unique().scalars().first()
            if not existing_user:
                raise HTTPException(status_code=404, detail="User not found")
            
            #check if user is already assigned to the survey
            assignment_query = await db.execute(
                select(survey_user)
                .where(and_(
                    survey_user.c.user_id == existing_user.id,
                    survey_user.c.survey_id == existing_survey.id
                ))
            )
            existing_assignment = assignment_query.unique().scalars().first()
            if existing_assignment:
                raise HTTPException(status_code=400, detail=f"User with email {user.email} already assigned to this survey")
            
            #check if user is owner of the survey
            if existing_survey.owner_id == existing_user.id:
                raise HTTPException(status_code=400, detail=f"User with email {user.email} is the owner of the survey")

            #check if survey scope is by organization, if so, check if user belongs to the same org
            if existing_survey.scope == SurveyScopeEnum.organization:
                #if survey is scoped by org, check if user belongs to the same org
                result = await db.execute(select(Survey).where(and_(Survey.id == existing_survey.id,
                                                                    Survey.organization_id == existing_user.organization_id)))
                belongs_to_same_org = result.unique().scalars().first()

                if belongs_to_same_org:
                    raise HTTPException(status_code=400, detail=f"User with email {user.email} already assigned to this survey")
                
            users_to_assign.append(existing_user)
            

        new_assignment =  survey_user.insert().values([{"user_id": user.id, "survey_id": existing_survey.id} for user in users_to_assign])
        await db.execute(new_assignment)
        await db.commit()

        #ahora devolvemos la lista de users del cuestionario
        result = await db.execute(select(User).join(survey_user).join(Survey).where(and_(Survey.id == existing_survey.id, 
                                                                                                Survey.id == survey_user.c.survey_id, 
                                                                                                User.id == survey_user.c.user_id)))
        users = result.unique().scalars().all()

        return { "users": users, "length": len(users) }
    
    

@survey_users_router.delete("/surveys/{id}/users/delete", status_code=200, response_model=UserResponseWithLength)
@required_roles(["admin", "researcher"])
async def remove_user_from_survey(id: uuid.UUID, user: RemoveParticipantFromSurvey, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        result = await db.execute(select(Survey).where(Survey.id == id))
        existing_survey = result.unique().scalars().first()

        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        
        #check if participant exists
        result = await db.execute(select(User).where(and_(User.email == user.email, User.role == "participant")))
        existing_participant = result.unique().scalars().first()

        if not existing_participant:
            raise HTTPException(status_code=404, detail="Participant not found")

        #check if user is already assigned to the survey
        assignment_query = await db.execute(
            select(survey_user)
            .where(and_(
                survey_user.c.user_id == existing_participant.id,
                survey_user.c.survey_id == existing_survey.id
            ))
        )
        existing_assignment = assignment_query.unique().scalars().first()
        
        if not existing_assignment:
            raise HTTPException(status_code=400, detail="Participant not assigned to this survey")
        
        
        #check if researcher is trying to remove the participant from the survey of another organization
        if current_user.role == "researcher" and existing_participant.organization_id != current_user.organization_id:
            raise HTTPException(status_code=403, detail="Forbidden")

        removed_assignment = survey_user.delete().where(and_(survey_user.c.user_id == existing_participant.id,
                                                                  survey_user.c.survey_id == existing_survey.id))

        await db.execute(removed_assignment)
        await db.commit()

        #ahora devolvemos la lista de participantes del cuestionario
        result = await db.execute(select(User).join(survey_user).join(Survey).where(and_(Survey.id == existing_survey.id, 
                                                                                                Survey.id == survey_user.c.survey_id, 
                                                                                                User.id == survey_user.c.user_id)))
        participants = result.unique().scalars().all()

        return { "users": participants, "length": len(participants) }
    
