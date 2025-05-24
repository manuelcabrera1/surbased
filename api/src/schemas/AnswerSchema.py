import datetime
from typing import List
from pydantic import BaseModel
from uuid import UUID

from src.schemas.QuestionSchema import *

class AnswerBase(BaseModel):...

class AvailableFormatsEnum(str, Enum):
    csv = "csv"
    excel = "excel"

class AnswerCreate(AnswerBase):
    questions: List[QuestionAnswer]

class AnswerUpdate(AnswerBase): ...

class AnswerResponse(AnswerBase):
    survey_id: UUID
    questions: List[QuestionAnswer]

class AnswerResponseList(AnswerBase):
    answers: List[AnswerResponse]



