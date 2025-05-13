import datetime
from typing import TYPE_CHECKING
import uuid
from src.database import Base
from sqlalchemy import DateTime, ForeignKey, Integer, UUID, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

if TYPE_CHECKING:
    from src.models.QuestionModel import Question
    from src.models.OptionModel import Option
    from src.models.UserModel import User



class Answer(Base):
    __tablename__ = "answers"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("users.id"), primary_key=True)
    option_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("options.id"))
    question_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("questions.id"), primary_key=True)
    text: Mapped[str] = mapped_column(String(250), nullable=True)



    option: Mapped["Option"] = relationship(back_populates="answers", lazy="selectin")
    participant: Mapped["User"] = relationship(back_populates="answers", lazy="selectin")
    question: Mapped["Question"] = relationship(back_populates="answers", lazy="selectin")


