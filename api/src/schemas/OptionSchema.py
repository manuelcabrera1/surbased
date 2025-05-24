from typing import List, Optional
from pydantic import BaseModel, Field
from uuid import UUID

class OptionBase(BaseModel):
    description: str
    points: Optional[int] = None
    
class OptionCreateRequest(OptionBase):...

class OptionUpdateRequest(BaseModel):
    id: Optional[UUID] = Field(default=None)
    description: Optional[str] = Field(default=None)
    points: Optional[int] = Field(default=None)

class OptionResponse(OptionBase):
    id: UUID
    question_id: UUID

class OptionResponseList(BaseModel):
    options: List[OptionResponse]


class OptionWithId(BaseModel):
    id: UUID


        
        
