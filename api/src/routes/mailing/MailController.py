from fastapi import APIRouter, Depends, HTTPException
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig
from pydantic import BaseModel, EmailStr
from pathlib import Path
from jinja2 import Environment, FileSystemLoader
from dotenv import load_dotenv
import os

load_dotenv()

mail_router = APIRouter()

# Configuración del email
conf = ConnectionConfig(
    MAIL_USERNAME=os.getenv("MAIL_USERNAME"),
    MAIL_PASSWORD=os.getenv("MAIL_PASSWORD"),
    MAIL_FROM=os.getenv("MAIL_FROM"),
    MAIL_PORT=int(os.getenv("MAIL_PORT", 587)),
    MAIL_SERVER=os.getenv("MAIL_SERVER", "smtp.gmail.com"),
    MAIL_STARTTLS=True,
    MAIL_SSL_TLS=False,
    USE_CREDENTIALS=True,
    VALIDATE_CERTS=True
)

# Configuración de Jinja2
templates = Environment(
    loader=FileSystemLoader('config/mailing/templates')
)

class SurveyInvitation(BaseModel):
    recipient_email: EmailStr
    recipient_name: str
    survey_title: str
    survey_url: str
    invitation_message: str = "Nos gustaría contar con tu participación en esta encuesta."

@mail_router.post("/send-survey-invitation/")
async def send_survey_invitation(invitation: SurveyInvitation):
    try:
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
