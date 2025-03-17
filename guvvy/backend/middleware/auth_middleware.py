# backend/middleware/auth_middleware.py
from fastapi import Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin import auth, credentials, initialize_app
import os
from typing import Optional
from models.user_model import User
from services.user_service import get_user_by_firebase_uid

# Initialize Firebase Admin SDK
try:
    firebase_cred = credentials.Certificate(os.getenv("FIREBASE_CREDENTIALS_PATH", "firebase-service-account.json"))
    firebase_app = initialize_app(firebase_cred)
except ValueError:
    # App already initialized
    pass

# Security scheme
security = HTTPBearer()


async def verify_firebase_token(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> str:
    """
    Verify Firebase ID token from Authorization header.
    Returns the Firebase UID if token is valid.
    """
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Could not validate credentials",
        )
    
    token = credentials.credentials
    try:
        # Verify the ID token
        decoded_token = auth.verify_id_token(token)
        return decoded_token["uid"]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid authentication credentials: {e}",
        )


async def get_current_user(
    firebase_uid: str = Depends(verify_firebase_token)
) -> User:
    """
    Get the current user from the database based on Firebase UID.
    Creates a user record if it doesn't exist.
    """
    user = await get_user_by_firebase_uid(firebase_uid)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found in database",
        )
    return user