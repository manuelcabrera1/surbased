from typing import List
import uuid
from pydantic import BaseModel, Field, model_validator

from .OptionSchema import OptionCreateRequest, OptionResponse

class QuestionBase(BaseModel):
    description: str
    multiple_answer: bool
    required: bool = True
    has_correct_answer: bool 

    
class QuestionCreateRequest(QuestionBase):
    options: List[OptionCreateRequest]

class QuestionUpdateRequest(QuestionBase):...

class QuestionResponse(QuestionBase):
    id: uuid.UUID
    survey_id: uuid.UUID
    options: List[OptionResponse] = Field(default_factory=list)

class QuestionResponseWithLength(BaseModel):
    questions: List[QuestionResponse]
    length: int

