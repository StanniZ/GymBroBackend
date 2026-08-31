from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from jwt.exceptions import PyJWTError
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import create_access_token
from app.db.session import get_db
from app.models.auth_identity import AuthIdentity
from app.models.user import User
from app.schemas.auth import AppleLoginRequest, AuthTokenResponse
from app.services.apple_token_verifier import (
    AppleTokenVerifier,
    get_apple_token_verifier,
)


router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/apple", response_model=AuthTokenResponse)
def apple_login(
    request: AppleLoginRequest,
    db: Annotated[Session, Depends(get_db)],
    verifier: Annotated[
        AppleTokenVerifier,
        Depends(get_apple_token_verifier),
    ],
) -> AuthTokenResponse:
    try:
        claims = verifier.verify(
            request.identity_token,
            request.raw_nonce,
        )
    except PyJWTError as error:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Apple identity token",
        ) from error

    apple_user_id = claims["sub"]
    email = claims.get("email")

    identity = db.scalar(
        select(AuthIdentity).where(
            AuthIdentity.provider == "apple",
            AuthIdentity.provider_user_id == apple_user_id,
        )
    )

    if identity is None:
        user = User(display_name=request.display_name)

        identity = AuthIdentity(
            user=user,
            provider="apple",
            provider_user_id=apple_user_id,
            email=email,
        )

        db.add_all([user, identity])
        db.commit()
        db.refresh(user)
    else:
        user = identity.user

    return AuthTokenResponse(
        access_token=create_access_token(user.id),
        user_id=user.id,
    )
