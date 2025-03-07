from typing import List
import uuid
from pydantic import BaseModel, Field, model_validator

from .OptionSchema import OptionCreateRequest, OptionResponse

class QuestionBase(BaseModel):
    number: int
    description: str
    multiple_answer: bool
    required: bool = True
    has_correct_answer: bool 

    @model_validator(mode="after")
    def validate_number(self):
        if self.number < 1:
            raise ValueError("The number must be greater than 0")
        return self
    
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

