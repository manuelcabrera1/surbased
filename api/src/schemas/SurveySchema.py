from typing import List, Optional
import uuid
from pydantic import BaseModel, Field, field_validator, model_validator
from datetime import date


class SurveyBase(BaseModel):
    name: str
    category_id: uuid.UUID
    researcher_id: uuid.UUID

class SurveyCreate(SurveyBase):
    description: Optional[str] = Field(default="")
    start_date: Optional[date] = Field(default_factory=date.today)
    end_date: Optional[date] = Field(default=None)

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
    end_date: Optional[date] = None
    researcher_id: uuid.UUID

class SurveyResponseWithLength(BaseModel):
    surveys: List[SurveyResponse]
    length: int
