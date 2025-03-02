from typing import List
import uuid
from pydantic import BaseModel, Field

class OrganizationBase(BaseModel):
    name: str

    class Config:
        from_attributes = True

class OrganizationCreate(OrganizationBase): ...


class OrganizationResponse(OrganizationBase):
    id: uuid.UUID

class OrganizationResponseWithLength(BaseModel):
    orgs: List[OrganizationResponse]
    length: int
