from datetime import date
import uuid
from typing import List, Optional, TYPE_CHECKING
from src.database import Base
from sqlalchemy import Boolean, CheckConstraint, ForeignKey, Integer, String, Date, UUID
from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.orm import Mapped, mapped_column, relationship
from src.models.SurveyUserModel import survey_user


if TYPE_CHECKING:
    from src.models.UserFcmTokenModel import UserFcmToken
    from src.models.SurveyModel import Survey
    from src.models.OrganizationModel import Organization
    from src.models.AnswerModel import Answer





class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True, index=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(50), nullable=True)
    lastname: Mapped[str] = mapped_column(String(100), nullable=True)
    email: Mapped[str] = mapped_column(String(100), nullable=False, unique=True)
    password: Mapped[str] = mapped_column(String(100), nullable=False)
    role: Mapped[str] = mapped_column(String(50), nullable=False)
    birthdate: Mapped[date] = mapped_column(Date, nullable=True)
    gender: Mapped[str] = mapped_column(String(50), nullable=True)
    allow_notifications: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)


    organization_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("organizations.id"), nullable=True)
    
    

    organization: Mapped["Organization"] = relationship(back_populates="users", lazy="selectin")
    surveys_assigned: Mapped[Optional[List["Survey"]]]=relationship(secondary=survey_user, back_populates="assigned_users", lazy="selectin")
    surveys_owned: Mapped[Optional[List["Survey"]]] = relationship(back_populates="owner", cascade="all, delete", lazy="selectin")
    answers: Mapped[Optional[List["Answer"]]] = relationship(back_populates="participant", cascade="all, delete", lazy="selectin")
    fcm_tokens: Mapped[Optional[List["UserFcmToken"]]] = relationship(back_populates="user", cascade="all, delete", lazy="selectin")

    __table_args__ = (
        CheckConstraint("role IN ('researcher', 'participant', 'admin')", name="role_check"),
        CheckConstraint("gender IN ('male', 'female', 'other')", name="gender_check"),
        CheckConstraint("birthDate <=CURRENT_DATE", name="birthDate_check"),
    )

    @hybrid_property
    def age(self):
        today = date.today()
        if self.birthdate: 
            return today.year - self.birthdate.year - ((today.month, today.year) < (self.birthdate.month, self.birthdate.year))
        return None
    



