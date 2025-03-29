from datetime import datetime
from database import Base
from sqlalchemy import Column, DateTime, ForeignKey, Table

survey_tag = Table(
    "survey_tag",
    Base.metadata,
    Column("survey_id", ForeignKey("surveys.id"), primary_key=True, index=True),
    Column("tag_id", ForeignKey("tags.id"), primary_key=True, index=True),    
)

