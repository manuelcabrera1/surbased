import datetime
from typing import List
from pydantic import BaseModel
from uuid import UUID

from schemas.QuestionSchema import *

class AnswerBase(BaseModel):...

class AnswerCreate(AnswerBase):
    questions: List[QuestionWithId]

class AnswerUpdate(AnswerBase): ...

class AnswerResponse(AnswerBase):
    id: UUID

class AnswerResponseWithLength(AnswerBase):
    answers: List[AnswerResponse]
    length: int



