from typing import List, Optional, TYPE_CHECKING
import uuid
from sqlalchemy import ForeignKey, String, UUID

from src.database import Base
from sqlalchemy.orm import Mapped, mapped_column, relationship



if TYPE_CHECKING:
    from src.models.OrganizationModel import Organization
    from src.models.SurveyModel import Survey

class Category(Base):
    __tablename__ = "categories"


    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True, index=True, default=uuid.uuid4)   
    name: Mapped[str] = mapped_column(String(100), nullable=False)

    surveys: Mapped[Optional[List["Survey"]]] = relationship(back_populates="category", cascade="all, delete", lazy="selectin")

    