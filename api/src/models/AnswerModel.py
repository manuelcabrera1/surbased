import datetime
from typing import TYPE_CHECKING
import uuid
from database import Base
from sqlalchemy import DateTime, ForeignKey, Integer, UUID, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

if TYPE_CHECKING:
    from .OptionModel import Option
    from .UserModel import User



class Answer(Base):
    __tablename__ = "answers"

    participant_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("users.id"), primary_key=True)
    option_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("options.id"), primary_key=True)
    question_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("questions.id"), primary_key=True)



    option: Mapped["Option"] = relationship(back_populates="answers", cascade="all, delete", lazy="selectin")
    participant: Mapped["User"] = relationship(back_populates="answers", cascade="all, delete", lazy="selectin")


