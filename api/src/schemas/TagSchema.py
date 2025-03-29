import uuid
from pydantic import BaseModel

class TagBase(BaseModel):
    name: str

class TagCreateRequest(TagBase):...

class TagResponse(TagBase):
    id: uuid.UUID



