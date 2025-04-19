from typing import List
import uuid
from enum import Enum
from pydantic import BaseModel, Field, model_validator

from .OptionSchema import *

class QuestionTypeEnum(str, Enum):
    single_choice = "single_choice"
    multiple_choice = "multiple_choice"
    likert_scale = "likert_scale"
    open = "open"

class QuestionBase(BaseModel):
    description: str
    type: QuestionTypeEnum
    required: bool = True

    
class QuestionCreateRequest(QuestionBase):
    options: List[OptionCreateRequest]

class QuestionUpdateRequest(BaseModel):
    id: Optional[uuid.UUID] = Field(default=None)
    number: Optional[int] = Field(default=None)
    description: Optional[str] = Field(default=None)
    type: Optional[QuestionTypeEnum] = Field(default=None)
    required: Optional[bool] = Field(default=None)
    options: Optional[List[OptionUpdateRequest]] = Field(default=None)

class QuestionResponse(QuestionBase):
    number: int
    id: uuid.UUID
    survey_id: uuid.UUID
    options: List[OptionResponse] = Field(default_factory=list)

class QuestionResponseWithLength(BaseModel):
    questions: List[QuestionResponse]
    length: int


class QuestionWithId(BaseModel):
    id: uuid.UUID
    options: List[OptionWithId]
class QuestionAnswer(BaseModel):
    id: uuid.UUID
    type: QuestionTypeEnum
    options: Optional[List[OptionWithId]]
    text: Optional[str]

