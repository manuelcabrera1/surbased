import uuid
from pydantic import BaseModel

class MetricBase(BaseModel):
    name: str

class MetricCreateRequest(MetricBase):
    description: str
    formula: str

class MetricUpdateRequest(MetricBase):
    description: str
    formula: str

class MetricResponse(MetricBase):
    id: uuid.UUID
    description: str
    formula: str