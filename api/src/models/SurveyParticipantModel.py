from datetime import datetime
from database import Base
from sqlalchemy import Column, DateTime, ForeignKey, Table

survey_participant = Table(
    "survey_participant",
    Base.metadata,
    Column("participant_id", ForeignKey("users.id"), primary_key=True, index=True),
    Column("survey_id", ForeignKey("surveys.id"), primary_key=True, index=True),
    Column("updated_at", DateTime, default=datetime.now)

    
)

