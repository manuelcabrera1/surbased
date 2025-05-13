import uuid
from typing import List, Optional, TYPE_CHECKING
from src.database import Base
from sqlalchemy import String, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from src.models.SurveyTagModel import survey_tag

if TYPE_CHECKING:    
    from src.models.SurveyModel import Survey




class Tag(Base):
    __tablename__ = "tags"

    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True, index=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(50), nullable=True, unique=True)
        

    surveys: Mapped[Optional[List["Survey"]]]=relationship(secondary=survey_tag, back_populates="tags", lazy="selectin")


    



