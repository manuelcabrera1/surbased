import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from routes.health.HealthController import health_router
from database import engine, init_models
from routes.user.UserController import user_router
from routes.surveyusers.SurveyUsersController import survey_users_router
from routes.organization.OrganizationController import org_router
from routes.category.CategoryController import category_router
from routes.survey.SurveyController import survey_router
from routes.metric.MetricController import metric_router
from routes.question.QuestionController import question_router
from routes.option.OptionController import option_router
from routes.answer.AnswerController import answer_router
from routes.mailing.MailController import mail_router
from routes.tag.TagController import tag_router
from routes.userfcmtoken.UserFcmTokenController import user_fcm_token_router
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
app.include_router(metric_router)
app.include_router(question_router)
app.include_router(option_router)
app.include_router(answer_router)
app.include_router(mail_router)
app.include_router(tag_router)
app.include_router(user_fcm_token_router)

