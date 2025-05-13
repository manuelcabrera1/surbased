import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from src.routes.health.HealthController import health_router
from src.database import engine, init_models
from src.routes.user.UserController import user_router
from src.routes.surveyusers.SurveyUsersController import survey_users_router
from src.routes.organization.OrganizationController import org_router
from src.routes.category.CategoryController import category_router
from src.routes.survey.SurveyController import survey_router
from src.routes.answer.AnswerController import answer_router
from src.routes.mailing.MailController import mail_router
from src.routes.tag.TagController import tag_router
from src.routes.userfcmtoken.UserFcmTokenController import user_fcm_token_router
import firebase_admin
from firebase_admin import credentials
import os
from google.oauth2 import service_account

@asynccontextmanager
async def lifespan(app:FastAPI):
    await init_models()
    yield


app = FastAPI(lifespan=lifespan)
app.title = "Surbased API"


app.include_router(health_router)
app.include_router(user_router)
app.include_router(org_router)
app.include_router(category_router)
app.include_router(survey_router)
app.include_router(survey_users_router)
app.include_router(answer_router)
app.include_router(mail_router)
app.include_router(tag_router)
app.include_router(user_fcm_token_router)

