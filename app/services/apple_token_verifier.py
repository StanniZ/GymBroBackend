import hashlib
import hmac

from functools import lru_cache
from typing import Any

import jwt

from app.core.config import settings


class AppleTokenVerifier:
    def __init__(self) -> None:
        self.jwks_client = jwt.PyJWKClient(settings.apple_jwks_url)

    def verify(
        self,
        identity_token: str,
        raw_nonce: str,
    ) -> dict[str, Any]:
        signing_key = self.jwks_client.get_signing_key_from_jwt(identity_token)

        claims = jwt.decode(
            identity_token,
            signing_key.key,
            algorithms=["RS256"],
            audience=settings.apple_client_id,
            issuer=settings.apple_issuer,
            options={
                "require": ["exp", "iat", "iss", "aud", "sub", "nonce"],
            },
        )

        expected_nonce = hashlib.sha256(
            raw_nonce.encode("utf-8")
        ).hexdigest()

        token_nonce = claims["nonce"]

        if not hmac.compare_digest(token_nonce, expected_nonce):
            raise jwt.InvalidTokenError("Invalid nonce")

        return claims


@lru_cache
def get_apple_token_verifier() -> AppleTokenVerifier:
    return AppleTokenVerifier()
