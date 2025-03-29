import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI
from routes.health.HealthController import health_router
from database import engine, init_models
from routes.user.UserController import user_router
import models
from routes.surveyusers.SurveyUsersController import survey_users_router
from routes.organization.OrganizationController import org_router
from routes.category.CategoryController import category_router
from routes.survey.SurveyController import survey_router
from routes.metric.MetricController import metric_router
from routes.question.QuestionController import question_router
from routes.option.OptionController import option_router
from routes.answer.AnswerController import answer_router
from routes.mailing.MailController import mail_router


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
