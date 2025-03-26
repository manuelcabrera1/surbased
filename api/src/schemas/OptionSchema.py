from typing import List, Optional
from pydantic import BaseModel
from uuid import UUID

class OptionBase(BaseModel):
    description: str
    points: Optional[int] = None
    
class OptionCreateRequest(OptionBase):...

class OptionUpdateRequest(OptionBase):...

class OptionResponse(OptionBase):
    id: UUID
    question_id: UUID

class OptionResponseWithLength(BaseModel):
    options: List[OptionResponse]
    length: int

class OptionWithId(BaseModel):
    id: UUID


        
        
