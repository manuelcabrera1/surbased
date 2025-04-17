from typing import Optional
from pydantic import BaseModel, EmailStr

class MailBase(BaseModel):
    email: EmailStr

class MailSurveyInvitation(MailBase):
    survey_name: str
    survey_url: str

class MailForgotPassword(MailBase):...

class MailForgotPasswordCode(MailBase):
    reset_code: str

    
