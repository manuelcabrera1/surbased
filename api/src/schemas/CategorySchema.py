from typing import List
import uuid
from pydantic import BaseModel, Field

class CategoryBase(BaseModel):
    name: str

    class Config:
        from_attributes = True

class CategoryCreate(CategoryBase):...
    

class CategoryUpdate(CategoryBase):...

class CategoryResponse(CategoryBase):
    id: uuid.UUID

class CategoryResponseList(BaseModel):
    categories: List[CategoryResponse]
