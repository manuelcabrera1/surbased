import datetime
from typing import List
from pydantic import BaseModel
from uuid import UUID

class AnswerBase(BaseModel):
    participant_id: UUID
    option_id: UUID

class AnswerCreate(AnswerBase): ...

class AnswerUpdate(AnswerBase): ...

class AnswerResponse(AnswerBase):
    id: UUID
    updated_at: datetime.datetime

class AnswerResponseWithLength(AnswerBase):
    answers: List[AnswerResponse]
    length: int



