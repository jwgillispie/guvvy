# backend/routes/user_routes.py
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from models.user_model import User, UserCreate, UserUpdate, AddressUpdate

from services.user_service import (
    create_user,
    get_user_by_firebase_uid,
    update_user,
    update_user_address,
    delete_user,
    update_login_timestamp,
)
from middleware.auth_middleware import verify_firebase_token, get_current_user

router = APIRouter(prefix="/api/users", tags=["users"])


@router.post("/", response_model=User, status_code=status.HTTP_201_CREATED)
async def create_new_user(
    user_data: UserCreate,
    current_user_id: str = Depends(verify_firebase_token)
):
    """
    Create a new user. 
    User must be authenticated with Firebase and the Firebase UID must match.
    """
    # Verify that the authenticated user is creating their own record
    if user_data.firebase_uid != current_user_id:
        raise HTTPException(
            status_code=403,
            detail="You can only create a user record for yourself"
        )
    
    return await create_user(user_data)


@router.get("/me", response_model=User)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """Get the current authenticated user's information."""
    return current_user


@router.get("/{firebase_uid}", response_model=User)
async def get_user_info(
    firebase_uid: str,
    current_user: User = Depends(get_current_user)
):
    """
    Get a user by Firebase UID.
    Regular users can only access their own data.
    """
    # Check if user is requesting their own data
    if firebase_uid != current_user.firebase_uid:
        # In a real app, you would check for admin permissions here
        raise HTTPException(
            status_code=403,
            detail="You can only access your own user data"
        )
    
    user = await get_user_by_firebase_uid(firebase_uid)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return user


@router.put("/{firebase_uid}", response_model=User)
async def update_user_info(
    firebase_uid: str,
    user_data: UserUpdate,
    current_user: User = Depends(get_current_user)
):
    """
    Update a user's information.
    Users can only update their own data.
    """
    # Check if user is updating their own data
    if firebase_uid != current_user.firebase_uid:
        raise HTTPException(
            status_code=403,
            detail="You can only update your own user data"
        )
    
    updated_user = await update_user(firebase_uid, user_data)
    return updated_user


@router.put("/{firebase_uid}/address", response_model=User)
async def update_address(
    firebase_uid: str,
    address_data: AddressUpdate,
    current_user: User = Depends(get_current_user)
):
    """
    Update a user's address.
    Users can only update their own address.
    """
    # Check if user is updating their own data
    if firebase_uid != current_user.firebase_uid:
        raise HTTPException(
            status_code=403,
            detail="You can only update your own address"
        )
    
    updated_user = await update_user_address(firebase_uid, address_data)
    return updated_user


@router.delete("/{firebase_uid}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user_account(
    firebase_uid: str,
    current_user: User = Depends(get_current_user)
):
    """
    Delete a user account.
    Users can only delete their own account.
    """
    # Check if user is deleting their own account
    if firebase_uid != current_user.firebase_uid:
        raise HTTPException(
            status_code=403,
            detail="You can only delete your own account"
        )
    
    await delete_user(firebase_uid)
    return {"message": "User deleted successfully"}


@router.post("/{firebase_uid}/login", response_model=User)
async def log_user_login(
    firebase_uid: str,
    current_user_id: str = Depends(verify_firebase_token)
):
    """
    Update a user's last login timestamp.
    This endpoint should be called when a user logs in.
    """
    # Verify the authenticated user matches the requested user
    if firebase_uid != current_user_id:
        raise HTTPException(
            status_code=403,
            detail="You can only update your own login timestamp"
        )
    
    user = await update_login_timestamp(firebase_uid)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return user