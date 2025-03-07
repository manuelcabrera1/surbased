from typing import List, Optional, TYPE_CHECKING
import uuid
from database import Base
from sqlalchemy import CheckConstraint, Column, ForeignKey, Integer, String, Date, UniqueConstraint, func, UUID
from sqlalchemy.ext.hybrid import hybrid_property

from sqlalchemy.orm import  Mapped, mapped_column, relationship
from .SurveyParticipantModel import survey_participant
from .SurveyMetricModel import survey_metric




if TYPE_CHECKING:
    from .UserModel import User
    from .CategoryModel import Category
    from .MetricModel import Metric
    from .QuestionModel import Question


class Survey(Base):
    __tablename__ = "surveys"
 

    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True, index=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str] = mapped_column(String(250), nullable=False)
    start_date: Mapped[Date] = mapped_column(Date, nullable=False) 
    end_date: Mapped[Optional[Date]] = mapped_column(Date, nullable=True)
    researcher_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("users.id"), nullable=False)
    category_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("categories.id"), nullable=False)

 

    participants: Mapped[Optional[List["User"]]] = relationship(secondary=survey_participant, back_populates="surveys_participant", cascade="all, delete", lazy="selectin")
    researcher: Mapped["User"] = relationship(back_populates="surveys_researcher", cascade="all, delete", lazy="selectin")
    category: Mapped["Category"] = relationship(back_populates="surveys", cascade="all, delete", lazy="selectin")
    metrics: Mapped[Optional[List["Metric"]]] = relationship(secondary=survey_metric, back_populates="surveys", cascade="all, delete", lazy="selectin")
    questions: Mapped[Optional[List["Question"]]] = relationship(back_populates="survey", cascade="all, delete", lazy="selectin")
    

    __table_args__ = (
        UniqueConstraint("name", "category_id", name="name_category_unique"),
        CheckConstraint("start_date <=CURRENT_DATE", name="start_date_check"),
        CheckConstraint("end_date >= start_date", name="end_date_check"),
    )

