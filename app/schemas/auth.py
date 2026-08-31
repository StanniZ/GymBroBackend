import uuid

from typing import Literal

from pydantic import BaseModel, Field


class AppleLoginRequest(BaseModel):
    identity_token: str = Field(min_length=1)
    raw_nonce: str = Field(min_length=16)
    display_name: str | None = Field(default=None, max_length=120)


class AuthTokenResponse(BaseModel):
    access_token: str
    token_type: Literal["bearer"] = "bearer"
    user_id: uuid.UUID
