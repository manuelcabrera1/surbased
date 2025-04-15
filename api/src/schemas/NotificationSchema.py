from typing import Optional
import uuid
from pydantic import BaseModel

class NotificationRequest(BaseModel):
    token: str
    title: str
    body: str
    email: Optional[str] = None
    survey_id: Optional[uuid.UUID] = None
    survey_name: Optional[str] = None
    user_id: Optional[uuid.UUID] = None
