# backend/app/routers/auth.py
from fastapi import APIRouter, Depends, HTTPException, status, Request
from app.auth.dependencies import get_current_user
from app.models.user_model import User
from pydantic import BaseModel, EmailStr
from typing import Optional

router = APIRouter(prefix="/auth", tags=["Authentication"])

class UserResponse(BaseModel):
    firebase_uid: str
    email: EmailStr
    display_name: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None

class UserUpdate(BaseModel):
    display_name: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None

@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """Get the current authenticated user's information."""
    return current_user

@router.put("/me", response_model=UserResponse)
async def update_user_info(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user)
):
    """Update the current user's information."""
    # Update only specified fields
    update_data = user_update.dict(exclude_unset=True)
    
    for field, value in update_data.items():
        setattr(current_user, field, value)
    
    await current_user.save()
    return current_user