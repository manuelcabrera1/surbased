from typing import List
import uuid
from pydantic import BaseModel, model_validator

class QuestionBase(BaseModel):
    number: int
    description: str
    multiple_answer: bool
    
    @model_validator(mode="after")
    def validate_number(self):
        if self.number < 1:
            raise ValueError("The number must be greater than 0")
        return self
    
class QuestionCreateRequest(QuestionBase):...

class QuestionUpdateRequest(QuestionBase):...

class QuestionResponse(QuestionBase):
    id: uuid.UUID
    survey_id: uuid.UUID

class QuestionResponseWithLength(BaseModel):
    questions: List[QuestionResponse]
    length: int

