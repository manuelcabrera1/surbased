from typing import List
import uuid
from pydantic import BaseModel, Field


class OrganizationBase(BaseModel):
    name: str

class OrganizationCreate(OrganizationBase): ...


class OrganizationResponse(OrganizationBase):
    id: uuid.UUID
    users_count: int | None = None
    surveys_count: int | None = None

class OrganizationResponseWithLength(BaseModel):
    organizations: List[OrganizationResponse]
    length: int
