from typing import List
import uuid
from pydantic import BaseModel, Field

from schemas.SurveySchema import SurveyResponse
from schemas.UserSchema import UserResponse

class OrganizationBase(BaseModel):
    name: str

    class Config:
        from_attributes = True

class OrganizationCreate(OrganizationBase): ...


class OrganizationResponse(OrganizationBase):
    id: uuid.UUID
    users_count: int | None = None
    surveys_count: int | None = None

class OrganizationResponseWithLength(BaseModel):
    organizations: List[OrganizationResponse]
    length: int
