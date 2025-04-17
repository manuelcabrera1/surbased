from datetime import date
from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import and_, or_, select, update
from models.UserFcmTokenModel import UserFcmToken
from shared.notifications import send_notification
from models.CategoryModel import Category
from models.SurveyModel import Survey
from models.SurveyUserModel import survey_user
from auth.Auth import get_current_user, required_roles
from models.UserModel import User
from database import get_db
from sqlalchemy.ext.asyncio import AsyncSession
from schemas.SurveySchema import *
from schemas.UserSchema import *
from schemas.NotificationSchema import *


survey_users_router = APIRouter(tags=["Survey Users"])

@survey_users_router.get("/surveys/{id}/users", status_code=200, response_model=UserResponseWithPendingAssignments)
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
    result2 = await db.execute(select(User, survey_user.c.status).join(survey_user).where(and_(survey_user.c.survey_id == id,
                                                                            User.id == survey_user.c.user_id, 
                                                                            survey_user.c.status != AssignmentStatusEnum.rejected)))
    
    
    
    users_assigned = result2.all()
    

    pending_assignments = {}
    for user, status in users_assigned:
        if user not in users:
            users.append(user)
        if status == AssignmentStatusEnum.requested_pending or status == AssignmentStatusEnum.invited_pending:
            pending_assignments[str(user.id)] = status
        

    return { "users": users, "pending_assignments": pending_assignments }
    

@survey_users_router.get("/users/{id}/surveys", status_code=200, response_model=SurveyResponseWithLength)
async def get_user_surveys_assigned(id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        

        result = await db.execute(select(User).where(User.id == id))
        existing_user = result.unique().scalars().first()

        if not existing_user:
            raise HTTPException(status_code=404, detail="User not found")
        
        if current_user.role == "participant" and current_user.id != existing_user.id:
            raise HTTPException(status_code=403, detail="Forbidden")
        

        """
        #buscamos los cuestionarios creados por el usuario
        if existing_user.role != "participant":
            result = await db.execute(select(Survey).where(and_(Survey.owner_id == existing_user.id,
                                                                Survey.scope != SurveyScopeEnum.organization)))
            surveys_owned = result.unique().scalars().all()
            surveys.extend(surveys_owned)
        """
       
        #buscamos los cuestionarios asignados al usuario
        result = await db.execute(select(Survey, survey_user.c.status.label("status")).join(survey_user, Survey.id == survey_user.c.survey_id).where(survey_user.c.user_id == id))
        
            
        surveys_assigned = result.all()

        surveys = []

        for survey, status in surveys_assigned:
            if status == AssignmentStatusEnum.rejected or status == AssignmentStatusEnum.requested_pending:
                continue
            survey.assignment_status = status
            surveys.append(survey)
            
        surveys = sorted(surveys, key=lambda x: x.end_date, reverse=True)


        return { "surveys": surveys, "length": len(surveys)}
    

@survey_users_router.post("/surveys/{id}/users/add", status_code=200, response_model=UserResponse)
@required_roles(["admin", "researcher"])
async def assign_users_to_survey(id: uuid.UUID, user: AssignParticipantToSurvey, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    
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
                    raise HTTPException(status_code=403, detail="Forbidden")
        
        #check if user exist
        result = await db.execute(select(User).where(and_(User.email == user.email)))
        existing_user = result.unique().scalars().first()
        if not existing_user:
                raise HTTPException(status_code=404, detail="User not found")
        
        #check if survey has not ended and user is participant
        if existing_user.role == "participant" and existing_survey.end_date < date.today():
            raise HTTPException(status_code=400, detail="You can not invite participants to answer a survey that has already ended")

         #check if user is owner of the survey
        if existing_survey.owner_id == existing_user.id:
            raise HTTPException(status_code=400, detail=f"User with email {user.email} is the owner of the survey")
        
        #check if user is already assigned to the survey
        if existing_survey.scope == SurveyScopeEnum.organization:
             if existing_user.organization_id == existing_survey.organization_id:
                raise HTTPException(status_code=400, detail=f"User with email {user.email} already assigned to this survey")
             
        assignment_query = await db.execute(
            select(survey_user.c.user_id, 
                   survey_user.c.survey_id, 
                   survey_user.c.status, 
                   survey_user.c.invitations_rejected)
            .where(and_(
            survey_user.c.user_id == existing_user.id,
            survey_user.c.survey_id == existing_survey.id
            ))
        )
        existing_assignment = assignment_query.first()

        if existing_assignment:
            if existing_assignment.status == AssignmentStatusEnum.invited_pending:
                raise HTTPException(status_code=400, detail=f"User with email {user.email} already invited to this survey")
            
            if existing_assignment.status == AssignmentStatusEnum.requested_pending:
                raise HTTPException(status_code=400, detail=f"User with email {user.email} already requested access to this survey")
            
            if existing_assignment.status == AssignmentStatusEnum.accepted:
                raise HTTPException(status_code=400, detail=f"User with email {user.email} already assigned to this survey")
            
            if existing_assignment.status == AssignmentStatusEnum.rejected:
                if existing_assignment.invitations_rejected >= 3:
                    raise HTTPException(status_code=400, detail=f"User with email {user.email} already rejected this survey 3 times. They can't be invited again.")
                else:
                    update_assignment = survey_user.update().values(status=AssignmentStatusEnum.invited_pending).where(and_(survey_user.c.user_id == existing_user.id, survey_user.c.survey_id == existing_survey.id))
                    await db.execute(update_assignment)
                    await db.commit()
        
        else: 
            new_assignment =  survey_user.insert().values([{"user_id": existing_user.id, "survey_id": existing_survey.id, "status": AssignmentStatusEnum.invited_pending}])
            await db.execute(new_assignment)
            await db.commit()
    
        try: #obtener los tokens de los usuarios que estan asignados al cuestionario
            result = await db.execute(select(UserFcmToken).where(UserFcmToken.user_id == existing_user.id))
            tokens = result.unique().scalars().all()

            fcm_tokens = [token.fcm_token for token in tokens]

        #enviar notificaciones a los usuarios que estan asignados al cuestionario
            if fcm_tokens:
                 for token in fcm_tokens:
                    notifcation_params = NotificationRequest(token=token, title=user.notification_title, body=user.notification_body, email=current_user.email, survey_id=existing_survey.id, survey_name=existing_survey.name, user_id=existing_user.id)
                    success = send_notification(notifcation_params)
                    if not success:
                        raise HTTPException(status_code=500, detail="Error sending notification")
        
        except Exception as e:
            print(e)
            raise HTTPException(status_code=500, detail=f"Error sending notification: {str(e)}")
        

        return existing_user

@survey_users_router.put("/users/{user_id}/surveys/{survey_id}/accept", status_code=200, response_model=SurveyResponse)
@required_roles(["participant", "researcher"])
async def accept_survey_assignment(user_id: uuid.UUID, survey_id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        result = await db.execute(select(Survey).where(Survey.id == survey_id))
        existing_survey = result.unique().scalars().first()

        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        
        
        #check if user exist
        result = await db.execute(select(User).where(User.id == user_id))
        existing_user = result.unique().scalars().first()
        if not existing_user:
                raise HTTPException(status_code=404, detail="User not found")

        assignment_query = await db.execute(
            select(
                survey_user.c.user_id,
                survey_user.c.survey_id,
                survey_user.c.status,
                survey_user.c.invitations_rejected,
            ).where(and_(
                survey_user.c.user_id == existing_user.id,
                survey_user.c.survey_id == existing_survey.id
            ))
        )
        existing_assignment = assignment_query.first()
        print("Assignment details:", existing_assignment)

        if existing_assignment:
            print(existing_assignment.status)
            if existing_assignment.status != AssignmentStatusEnum.invited_pending and existing_assignment.status != AssignmentStatusEnum.requested_pending:
                raise HTTPException(status_code=400, detail=f"This survey can not be accepted")
         
        
        update_assignment = survey_user.update().values(status=AssignmentStatusEnum.accepted).where(and_(survey_user.c.user_id == existing_user.id, survey_user.c.survey_id == existing_survey.id))
        await db.execute(update_assignment)
        await db.commit()
        
        survey = existing_survey
        survey.assignment_status = AssignmentStatusEnum.accepted
        survey.invitations_rejected = existing_assignment.invitations_rejected
        return survey

@survey_users_router.put("/users/{user_id}/surveys/{survey_id}/reject", status_code=200, response_model=SurveyResponse)
@required_roles(["participant", "researcher"])
async def reject_survey_assignment(user_id: uuid.UUID, survey_id: uuid.UUID, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        result = await db.execute(select(Survey).where(Survey.id == survey_id))
        existing_survey = result.unique().scalars().first()

        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        
        
        #check if user exist
        result = await db.execute(select(User).where(User.id == user_id))
        existing_user = result.unique().scalars().first()
        if not existing_user:
                raise HTTPException(status_code=404, detail="User not found")

        assignment_query = await db.execute(
            select(
                survey_user.c.user_id,
                survey_user.c.survey_id,
                survey_user.c.status,
                survey_user.c.invitations_rejected,
            ).where(and_(
                survey_user.c.user_id == existing_user.id,
                survey_user.c.survey_id == existing_survey.id
            ))
        )
        existing_assignment = assignment_query.first()

        if existing_assignment:
            if existing_assignment.status != AssignmentStatusEnum.invited_pending and existing_assignment.status != AssignmentStatusEnum.requested_pending:
                raise HTTPException(status_code=400, detail=f"This survey can not be rejected")
           
        update_assignment = survey_user.update().values(status=AssignmentStatusEnum.rejected, invitations_rejected=survey_user.c.invitations_rejected + 1).where(and_(survey_user.c.user_id == existing_user.id, survey_user.c.survey_id == existing_survey.id))
        await db.execute(update_assignment)
        await db.commit()

        survey = existing_survey
        survey.assignment_status = AssignmentStatusEnum.rejected
        survey.invitations_rejected = existing_assignment.invitations_rejected + 1
        return survey
    
    
    

@survey_users_router.delete("/users/{id}/users/delete", status_code=200, response_model=UserResponseWithLength)
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


@survey_users_router.post("/surveys/{id}/users/{user_id}/request", status_code=200, response_model=UserResponse)
@required_roles(["participant"])
async def request_survey_access(id: uuid.UUID, user_id: uuid.UUID, payload: RequestSurveyAccess, current_user: Annotated[User, Depends(get_current_user)], db: Annotated[AsyncSession, Depends(get_db)]):
    
        if not current_user:
            raise HTTPException(status_code=401, detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
        
        #check if survey exists
        result = await db.execute(select(Survey).where(Survey.id == id))
        existing_survey = result.unique().scalars().first()

        if not existing_survey:
            raise HTTPException(status_code=404, detail="Survey not found")
        
        #check if survey is public
        if existing_survey.scope != SurveyScopeEnum.public:
            raise HTTPException(status_code=400, detail="This survey is not public. You can't request access to it.")
        
        if current_user.role == "researcher":
            #check if researcher from another organization is trying to assign users to the survey
            if existing_survey.scope == SurveyScopeEnum.organization and existing_survey.organization_id != current_user.organization_id:
                raise HTTPException(status_code=403, detail="Forbidden")
            
            #check if researcher is trying to assign users to a private survey that is not owned by them or is not moderated by them
            if existing_survey.scope == SurveyScopeEnum.private or existing_survey.scope == SurveyScopeEnum.public:
                result = await db.execute(select(survey_user).where(and_(survey_user.c.survey_id == existing_survey.id, survey_user.c.user_id == current_user.id)))
                existing_assignment = result.unique().scalars().first()
                
                if existing_survey.owner_id != current_user.id and not existing_assignment:
                    raise HTTPException(status_code=403, detail="Forbidden")
        
        #check if user exist
        result = await db.execute(select(User).where(and_(User.id == user_id)))
        existing_user = result.unique().scalars().first()
        if not existing_user:
                raise HTTPException(status_code=404, detail="User not found")
             
        assignment_query = await db.execute(
            select(survey_user.c.user_id, 
                   survey_user.c.survey_id, 
                   survey_user.c.status, 
                   survey_user.c.invitations_rejected)
            .where(and_(
            survey_user.c.user_id == existing_user.id,
            survey_user.c.survey_id == existing_survey.id
            ))
        )
        existing_assignment = assignment_query.first()

        if existing_assignment:
            if existing_assignment.status == AssignmentStatusEnum.requested_pending:
                raise HTTPException(status_code=400, detail=f"You already requested access to this survey. Wait for the owner response.")
            
            if existing_assignment.status == AssignmentStatusEnum.invited_pending:
                raise HTTPException(status_code=400, detail=f"You are already invited to this survey.")
            
            if existing_assignment.status == AssignmentStatusEnum.accepted:
                raise HTTPException(status_code=400, detail=f"You are already assigned to this survey")
            
            if existing_assignment.status == AssignmentStatusEnum.rejected:
                if existing_assignment.invitations_rejected >= 3:
                    raise HTTPException(status_code=400, detail=f"You already rejected this survey 3 times. You can't request access again.")
                else:
                    update_assignment = survey_user.update().values(status=AssignmentStatusEnum.requested_pending).where(and_(survey_user.c.user_id == existing_user.id, survey_user.c.survey_id == existing_survey.id))
                    await db.execute(update_assignment)
                    await db.commit()
        
        else: 
            new_assignment =  survey_user.insert().values([{"user_id": existing_user.id, "survey_id": existing_survey.id, "status": AssignmentStatusEnum.requested_pending}])
            await db.execute(new_assignment)
            await db.commit()

    
        try: #obtener el token del owner del cuestionario
            result = await db.execute(select(UserFcmToken).where(UserFcmToken.user_id == existing_survey.owner_id))
            tokens = result.unique().scalars().all()

            fcm_tokens = [token.fcm_token for token in tokens]

            if fcm_tokens:
                 for token in fcm_tokens:
                    #enviar notificaciones al owner del cuestionario
                    send_notification_params = NotificationRequest(token=token, title=payload.notification_title, body=payload.notification_body, email=current_user.email, survey_id=existing_survey.id, survey_name=existing_survey.name, user_id=existing_user.id)
                    success = send_notification(send_notification_params)
                    if not success:
                        raise HTTPException(status_code=500, detail="Error sending notification")
        
        except Exception as e:
            print(e)
            raise HTTPException(status_code=500, detail=f"Error sending notification: {str(e)}")
        
        

        return existing_user

    
