from typing import List, TYPE_CHECKING
import uuid
from src.models.AnswerModel import Answer
from src.database import Base
from sqlalchemy import Boolean, CheckConstraint, Column, ForeignKey, Integer, String, Date, UUID
from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.orm import Mapped, mapped_column, relationship


if TYPE_CHECKING:
    from src.models.SurveyModel import Survey
    from src.models.OptionModel import Option


class Question(Base):
    __tablename__ = "questions"



    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True, index=True, default=uuid.uuid4)
    number: Mapped[int] = mapped_column(Integer, nullable=False)
    description: Mapped[str] = mapped_column(String(250), nullable=False)
    type: Mapped[str] = mapped_column(String(100), nullable=False)
    required: Mapped[bool] = mapped_column(Boolean, nullable=False)
    survey_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("surveys.id"), nullable=False)



    survey: Mapped["Survey"] = relationship(back_populates="questions", lazy="selectin")
    options: Mapped[List["Option"]] = relationship(back_populates="question", cascade="all, delete", lazy="selectin")
    answers: Mapped[List["Answer"]] = relationship(back_populates="question", cascade="all, delete", lazy="selectin")


    __table_args__ = (
        CheckConstraint("type IN ('single_choice', 'multiple_choice', 'likert_scale', 'open')", name="type_check"),
        CheckConstraint("number > 0", name="number_check"),
    )


