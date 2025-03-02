from typing import TYPE_CHECKING
from database import Base
from sqlalchemy import Column, ForeignKey, Integer, Table
from sqlalchemy.orm import Mapped, mapped_column, relationship

if TYPE_CHECKING:
    from .SurveyModel import Survey
    from .MetricModel import Metric



survey_metric = Table(
    "survey_metric",
    Base.metadata,
    Column("survey_id", ForeignKey("surveys.id"), primary_key=True, index=True),
    Column("metric_id", ForeignKey("metrics.id"), primary_key=True, index=True)
)



