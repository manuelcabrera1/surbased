from typing import Optional
from pydantic import BaseModel, EmailStr

class MailBase(BaseModel):
    email: EmailStr

class MailSurveyInvitation(MailBase):
    survey_title: str
    survey_url: str
    invitation_message: str = "Nos gustaría contar con tu participación en esta encuesta."

class MailForgotPassword(MailBase):...

class MailForgotPasswordCode(MailBase):
    reset_code: str

    
