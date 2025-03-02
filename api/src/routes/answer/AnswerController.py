from typing import Annotated
import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import delete, or_, select, update, and_
from models.AnswerModel import Answer
from models.OptionModel import Option
from schemas.AnswerSchema import *
from models.CategoryModel import Category
from models.SurveyModel import Survey
from models.QuestionModel import Question
from database import get_db
from sqlalchemy.ext.asyncio import AsyncSession
from auth.Auth import get_current_user, required_roles
from models.UserModel import User
from models.SurveyParticipantModel import survey_participant
from datetime import datetime





answer_router = APIRouter(tags=["Answer"])


        

