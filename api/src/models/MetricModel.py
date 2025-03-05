from typing import List, TYPE_CHECKING, Optional
import uuid
from database import Base
from sqlalchemy import String, UUID
from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .SurveyMetricModel import survey_metric




if TYPE_CHECKING:
    from .SurveyModel import Survey




class Metric(Base):
    __tablename__ = "metrics"

    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True, index=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str] = mapped_column(String(200), nullable=True)
    formula: Mapped[str] = mapped_column(String(200), nullable=True)


    surveys: Mapped[Optional[List["Survey"]]] = relationship(secondary=survey_metric, back_populates="metrics", cascade="all, delete", lazy="selectin")
