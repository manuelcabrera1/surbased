from typing import List, TYPE_CHECKING, Optional
import uuid
from src.database import Base
from sqlalchemy import String, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship



if TYPE_CHECKING:
    from src.models.UserModel import User
    from src.models.SurveyModel import Survey



class Organization(Base):
    __tablename__ = "organizations"

    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True, index=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(100), nullable=False, unique=True)



    users: Mapped[List["User"]] = relationship(back_populates="organization", lazy="selectin")
    surveys: Mapped[Optional[List["Survey"]]] = relationship(back_populates="organization", lazy="selectin")
