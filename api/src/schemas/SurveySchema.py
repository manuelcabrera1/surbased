from typing import List, Optional
import uuid
from pydantic import BaseModel, Field, field_validator, model_validator
from datetime import date, timedelta

from src.schemas.TagSchema import *

from src.schemas.QuestionSchema import *

class SurveyScopeEnum(str, Enum):
    private = "private"
    organization = "organization"
    public = "public"


class SurveyScopeReducedEnum(str, Enum):
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
    end_date: Optional[date] = Field(default_factory=lambda: date.today() + timedelta(days=7))
    questions: Optional[List[QuestionCreateRequest]] = Field(default=None)
    tags: Optional[List[TagCreateRequest]] = Field(default=None)

    @model_validator(mode="after")
    def validate_start_date(self):
        print(self.start_date)
        print(date.today())

        if self.start_date and self.start_date < date.today():
            raise ValueError("The start date cannot be in the past")
        if self.start_date and self.end_date and self.start_date > self.end_date:
            raise ValueError("The start date cannot be after the end date")
        return self  

class SurveyUpdate(BaseModel):
    name: Optional[str] = Field(default=None)
    scope: Optional[SurveyScopeEnum] = Field(default=None)
    category_id: Optional[uuid.UUID] = Field(default=None)
    organization_id: Optional[uuid.UUID] = Field(default=None)
    description: Optional[str] = Field(default=None)
    start_date: Optional[date] = Field(default=None)
    end_date: Optional[date] = Field(default=None)
    questions: Optional[List[QuestionUpdateRequest]] = Field(default=None)
    tags: Optional[List[TagCreateRequest]] = Field(default=None)

class SurveyResponse(SurveyBase):
    id: uuid.UUID
    description: str
    start_date: date
    end_date: date
    assignment_status: Optional[str] = Field(default=None)
    invitations_rejected: Optional[int] = Field(default=None)
    questions: List[QuestionResponse]
    response_count: Optional[int] = Field(default=None)
    tags: Optional[List[TagResponse]] = Field(default=None)

class SurveyResponseList(BaseModel):
    surveys: List[SurveyResponse]
