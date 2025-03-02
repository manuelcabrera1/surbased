from typing import List
from pydantic import BaseModel
from uuid import UUID

class OptionBase(BaseModel):
    description: str
    is_correct: bool
    question_id: UUID

class OptionCreateRequest(OptionBase): ...

class OptionUpdateRequest(OptionBase): ...
class OptionResponse(OptionBase):
    id: UUID

class OptionResponseWithLength(BaseModel):
    options: List[OptionResponse]
    length: int


        
        
