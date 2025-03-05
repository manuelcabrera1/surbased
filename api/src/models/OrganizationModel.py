from typing import List, TYPE_CHECKING
import uuid
from database import Base
from sqlalchemy import String, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship



if TYPE_CHECKING:
    from .UserModel import User
    from .CategoryModel import Category



class Organization(Base):
    __tablename__ = "organizations"

    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True, index=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(100), nullable=False, unique=True)



    users: Mapped[List["User"]] = relationship(back_populates="organization", cascade="all, delete", lazy="selectin")
    categories: Mapped[List["Category"]] = relationship(back_populates="organization", cascade="all, delete", lazy="selectin")
