from datetime import date
from enum import Enum
from typing import List, Optional
import uuid
from pydantic import BaseModel, EmailStr, model_validator


class GenderEnum(str, Enum):
    male="male"
    female="female"
    other="other"

class UserRoleEnum(str, Enum):
    admin="admin"
    researcher="researcher"
    participant="participant"


class UserRoleRequestEnum(str, Enum):
    researcher="researcher"
    participant="participant"

class AssignmentStatusEnum(str, Enum):
    requested_pending="requested_pending"
    invited_pending="invited_pending"
    accepted="accepted"
    rejected="rejected"


class UserBase(BaseModel):
    email: EmailStr


class AssignParticipantToSurvey(UserBase): 
    notification_title: str
    notification_body: str

class RequestSurveyAccess(BaseModel): 
    notification_title: str
    notification_body: str

class RemoveParticipantFromSurvey(UserBase): ...

class UserCreateRequest(UserBase):  
    role: UserRoleEnum
    name: str
    lastname: str
    organization: str
    password: str
    birthdate: Optional[date] = None
    gender: Optional[GenderEnum] = None

    @model_validator(mode="after")
    def validate_age(self):
        if self.birthdate and self.birthdate > date.today():
            raise ValueError("Birthdate cannot be after today")
        return self

class UserUpdateRequest(UserBase):
    role: Optional[UserRoleRequestEnum] = None
    name: Optional[str] = None
    lastname: Optional[str] = None
    birthdate: Optional[date] = None
    gender: Optional[GenderEnum] = None

    @model_validator(mode="after")
    def validate_age(self):
        if self.birthdate and self.birthdate > date.today():
            raise ValueError("Birthdate cannot be after today")
        return self

class UserResponse(UserBase):
    name: Optional[str] = None
    lastname: Optional[str] = None
    role: UserRoleEnum
    id: uuid.UUID
    organization_id: Optional[uuid.UUID] = None
    birthdate: Optional[date] = None
    gender: Optional[GenderEnum] = None
    age: Optional[int] = None

class UserByRoleRequest(BaseModel):
    role: UserRoleRequestEnum

class UserResponseWithLength(BaseModel):
    users: List[UserResponse]
    length: int

class UserResponseWithPendingAssignments(BaseModel):
    users: List[UserResponse]
    pending_assignments: dict[str, AssignmentStatusEnum]
    

class UserUpdatePasswordRequest(BaseModel):
    password: str

class UserResetPasswordRequest(BaseModel):
    email: EmailStr
    password: str


