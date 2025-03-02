from typing import List, TYPE_CHECKING
import uuid
from database import Base
from sqlalchemy import Boolean, CheckConstraint, Column, ForeignKey, Integer, String, Date, UUID
from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.orm import Mapped, mapped_column, relationship


if TYPE_CHECKING:
    from .SurveyModel import Survey
    from .OptionModel import Option


class Question(Base):
    __tablename__ = "questions"



    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True, index=True, default=uuid.uuid4)
    number: Mapped[int] = mapped_column(Integer, nullable=False)
    description: Mapped[str] = mapped_column(String(250), nullable=False)
    multiple_answer: Mapped[bool] = mapped_column(Boolean, nullable=False)






    survey_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("surveys.id"), nullable=False)



    survey: Mapped["Survey"] = relationship(back_populates="questions")
    options: Mapped[List["Option"]] = relationship(back_populates="question")


    __table_args__ = (
        CheckConstraint("number > 0", name="number_check"),
    )


