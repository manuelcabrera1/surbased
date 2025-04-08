from datetime import datetime
from database import Base
from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Table

survey_user = Table(
    "survey_user",
    Base.metadata,
    Column("user_id", ForeignKey("users.id"), primary_key=True, index=True),
    Column("survey_id", ForeignKey("surveys.id"), primary_key=True, index=True),
    Column("status", String, default="pending"),
    Column("invitations_rejected", Integer, default=0)

    
)

