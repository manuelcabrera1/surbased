from pydantic import BaseModel


class UserFcmToken(BaseModel):
    fcm_token: str
    user_id: str

class UserFcmTokenCreate(UserFcmToken):...

