# backend/app/auth/dependencies.py
from typing import Optional
from fastapi import Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.auth.firebase import FirebaseAuth
from app.models.user_model import User


# HTTP Bearer authentication scheme
security = HTTPBearer()

async def get_current_user(
    request: Request,
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> User:
    """
    Get the current authenticated user.
    Validates the Firebase token and finds/creates the user in our database.
    """
    try:
        # Verify the Firebase token
        firebase_auth = FirebaseAuth()
        token_data = await firebase_auth.verify_token(credentials.credentials)
        
        # Get user from database
        firebase_uid = token_data["uid"]
        user = await User.find_one({"firebase_uid": firebase_uid})
        
        if user:
            return user
        
        # If user doesn't exist in our database, create new user from Firebase data
        email = token_data.get("email", "")
        name = token_data.get("name", email.split("@")[0] if email else "User")
        
        new_user = User(
            firebase_uid=firebase_uid,
            email=email,
            display_name=name,
            is_verified=token_data.get("email_verified", False)
        )
        
        await new_user.save()
        return new_user
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid authentication credentials: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )

async def get_optional_user(
    request: Request,
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> Optional[User]:
    """Similar to get_current_user but returns None if no authentication is provided."""
    try:
        return await get_current_user(request, credentials)
    except HTTPException:
        return None