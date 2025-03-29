from fastapi import APIRouter, Depends, HTTPException
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig
from pydantic import BaseModel, EmailStr
from pathlib import Path
from jinja2 import Environment, FileSystemLoader
from sqlalchemy import select
from config.mailing.config import get_conf, get_templates
from schemas.MailSchema import *
import random
from database import get_db
from typing import Annotated
from sqlalchemy.ext.asyncio import AsyncSession
from models.UserModel import User
mail_router = APIRouter(prefix="/mail", tags=["mail"])


@mail_router.post("/send-survey-invitation/")
async def send_survey_invitation(invitation: MailSurveyInvitation,
                                 db: Annotated[AsyncSession, Depends(get_db)],
                                 conf: ConnectionConfig = Depends(get_conf), 
                                 templates: Environment = Depends(get_templates)):
    try:
        # Verificar si el usuario existe en la base de datos
        result = await db.execute(select(User).where(User.email == invitation.recipient_email))
        user = result.unique().scalars().first()

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        # Cargar y renderizar la plantilla
        template = templates.get_template('survey_invitation.html')
        html_content = template.render(
            recipient_name=invitation.recipient_name,
            survey_title=invitation.survey_title,
            survey_url=invitation.survey_url,
            invitation_message=invitation.invitation_message
        )

        # Crear el mensaje
        message = MessageSchema(
            subject=f"Invitación a la encuesta: {invitation.survey_title}",
            recipients=[invitation.recipient_email],
            body=html_content,
            subtype="html"
        )

        # Enviar el email
        fm = FastMail(conf)
        await fm.send_message(message)

        return {
            "success": True,
            "message": f"Invitación enviada exitosamente a {invitation.recipient_email}"
        }
    except Exception as e:
        # Mejorar el mensaje de error para depuración
        error_msg = str(e)
        if "535" in error_msg and "5.7.8" in error_msg:
            error_msg = "Error de autenticación: Las credenciales de Gmail no son válidas. Asegúrate de usar una 'Contraseña de aplicación' generada en la configuración de seguridad de tu cuenta de Google."
        
        raise HTTPException(
            status_code=500,
            detail=f"Error al enviar el email: {error_msg}"
        )

@mail_router.post("/forgot-password")
async def send_forgot_password(forgot_password: MailForgotPassword, 
                               db: Annotated[AsyncSession, Depends(get_db)],
                               conf: ConnectionConfig = Depends(get_conf), 
                               templates: Environment = Depends(get_templates)):
    
        # Verificar si el usuario existe en la base de datos 
    result = await db.execute(select(User).where(User.email == forgot_password.email))
    user = result.unique().scalars().first()

    if not user:
        print("iyooo aqui estoy llegando con la calo")
        raise HTTPException(status_code=404, detail="User not found")
    
    try:
        # Cargar y renderizar la plantilla
        reset_code = random.randint(100000, 999999)
        template = templates.get_template('forgot_password.html')
        html_content = template.render(
            recipient_name=user.name,
            reset_code=reset_code,
        )

        # Crear el mensaje
        message = MessageSchema(
            subject=f"Restablecer contraseña",
            recipients=[forgot_password.email],
            body=html_content,
            subtype="html"
        )

        # Enviar el email
        fm = FastMail(conf)
        await fm.send_message(message)

        return {
            "reset_code": reset_code,
            "email": forgot_password.email,
            "name": user.name
        }
    
    except Exception as e:
        # Mejorar el mensaje de error para depuración
        error_msg = str(e)
        if "535" in error_msg and "5.7.8" in error_msg:
            error_msg = "Error de autenticación: Las credenciales de Gmail no son válidas. Asegúrate de usar una 'Contraseña de aplicación' generada en la configuración de seguridad de tu cuenta de Google."
        
        raise HTTPException(
            status_code=500,
            detail=f"Error al enviar el email: {error_msg}"
        )
