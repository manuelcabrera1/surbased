from typing import List, TYPE_CHECKING
import uuid
from database import Base
from sqlalchemy import Boolean, ForeignKey,  String, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship



if TYPE_CHECKING:
    from .QuestionModel import Question
    from .AnswerModel import Answer


class Option(Base):
    __tablename__ = "options"


    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True, index=True, default=uuid.uuid4)
    description: Mapped[str] = mapped_column(String(250), nullable=False)
    is_correct: Mapped[bool] = mapped_column(Boolean, nullable=False)




    question_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("questions.id"), nullable=False)



    question: Mapped["Question"] = relationship(back_populates="options")
    answers: Mapped[List["Answer"]] = relationship(back_populates="option")


