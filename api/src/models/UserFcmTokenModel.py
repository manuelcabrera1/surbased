from datetime import date, datetime
import uuid
from typing import List, Optional, TYPE_CHECKING
from models.UserModel import User
from database import Base
from sqlalchemy import CheckConstraint, DateTime, ForeignKey, Integer, String, Date, UUID, UniqueConstraint
from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.orm import Mapped, mapped_column, relationship


if TYPE_CHECKING:
   
    from .SurveyModel import Survey
    from .OrganizationModel import Organization
    from .AnswerModel import Answer





class UserFcmToken(Base):
    __tablename__ = "user_fcm_tokens"

    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True, index=True, default=uuid.uuid4)
    fcm_token: Mapped[str] = mapped_column(String(255), nullable=False)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID, ForeignKey("users.id"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, default=datetime.now)
    updated_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)

    
    user: Mapped["User"] = relationship(back_populates="fcm_tokens", lazy="selectin")

    __table_args__ = (
        UniqueConstraint("fcm_token", "user_id", name="fcm_token_user_unique"),
    )

    



