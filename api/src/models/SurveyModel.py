from typing import List, Optional, TYPE_CHECKING
import uuid
from src.models.TagModel import Tag
from src.database import Base
from sqlalchemy import CheckConstraint, Column, ForeignKey, Integer, String, Date, UniqueConstraint, func, UUID
from sqlalchemy.ext.hybrid import hybrid_property
from datetime import date
from sqlalchemy.orm import  Mapped, mapped_column, relationship
from src.models.SurveyUserModel import survey_user
from src.models.SurveyTagModel import survey_tag


if TYPE_CHECKING:
    from src.models.OrganizationModel import Organization
    from src.models.UserModel import User
    from src.models.CategoryModel import Category
    from src.models.QuestionModel import Question

class Survey(Base):
    __tablename__ = "surveys"
 

    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True, index=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str] = mapped_column(String(250), nullable=False)
    scope: Mapped[str] = mapped_column(String(100), nullable=False)
    start_date: Mapped[date] = mapped_column(Date, nullable=False) 
    end_date: Mapped[Optional[date]] = mapped_column(Date, nullable=False)
    owner_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("users.id"), nullable=False)
    organization_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("organizations.id"), nullable=True)
    category_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("categories.id"), nullable=False)

 

    assigned_users: Mapped[Optional[List["User"]]] = relationship(secondary=survey_user, back_populates="surveys_assigned",lazy="selectin")
    owner: Mapped["User"] = relationship(back_populates="surveys_owned", lazy="selectin")
    category: Mapped["Category"] = relationship(back_populates="surveys", lazy="selectin")
    questions: Mapped[Optional[List["Question"]]] = relationship(back_populates="survey", cascade="all, delete", lazy="selectin")
    organization: Mapped[Optional["Organization"]] = relationship(back_populates="surveys", lazy="selectin")
    tags: Mapped[Optional[List["Tag"]]] = relationship(secondary=survey_tag, back_populates="surveys", lazy="selectin")


    __table_args__ = (
        CheckConstraint("scope IN ('private', 'organization', 'public')", name="scope_check"),
        CheckConstraint("(scope = 'organization' AND 'organization_id' IS NOT NULL) OR (scope <> 'organization')", name="check_org_scope"),
        CheckConstraint("end_date >= start_date", name="end_date_check"),
    )

