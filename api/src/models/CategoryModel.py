from typing import List, Optional, TYPE_CHECKING
import uuid
from sqlalchemy import ForeignKey, String, UUID

from database import Base
from sqlalchemy.orm import Mapped, mapped_column, relationship



if TYPE_CHECKING:
    from .OrganizationModel import Organization
    from .SurveyModel import Survey

class Category(Base):
    __tablename__ = "categories"


    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True, index=True, default=uuid.uuid4)   
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    organization_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("organizations.id"), nullable=False)

    surveys: Mapped[Optional[List["Survey"]]] = relationship(back_populates="category")
    organization: Mapped["Organization"] = relationship(back_populates="categories")

    