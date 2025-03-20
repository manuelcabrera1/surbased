from typing import List, Optional
import uuid
from pydantic import BaseModel, Field, field_validator, model_validator
from datetime import date

from .QuestionSchema import *

class SurveyScopeEnum(str, Enum):
    private = "private"
    organization = "organization"
    public = "public"

class SurveyBase(BaseModel):
    name: str
    scope: SurveyScopeEnum
    category_id: uuid.UUID
    owner_id: uuid.UUID
    organization_id: Optional[uuid.UUID] = Field(default=None)


class SurveyCreate(SurveyBase):
    description: Optional[str] = Field(default="")
    start_date: Optional[date] = Field(default_factory=date.today)
    end_date: Optional[date] = Field(default=None)
    questions: List[QuestionCreateRequest]

    @model_validator(mode="after")
    def validate_start_date(self):
        if self.start_date and self.start_date < date.today():
            raise ValueError("The date cannot be in the past")
        if self.start_date and self.end_date and self.start_date > self.end_date:
            raise ValueError("The start date cannot be after the end date")
        return self   

class SurveyResponse(SurveyBase):
    id: uuid.UUID
    description: str
    start_date: date
    end_date: Optional[date] = Field(default=None)
    questions: List[QuestionResponse]

class SurveyResponseWithLength(BaseModel):
    surveys: List[SurveyResponse]
    length: int
