from typing import Annotated, List

from api.src.models.UserModel import Usuario
from fastapi import Depends, HTTPException
from auth.Auth import get_current_user


class RoleChecker:
    def __init__(self, roles: List[str]):
        self.roles = roles
    
    def __call__(self, current_user: Annotated[Usuario, Depends(get_current_user)] = None):
        if current_user.tipo not in self.roles:
            raise HTTPException(status_code=403, detail="Forbidden")

        return current_user
