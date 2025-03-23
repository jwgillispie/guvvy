# backend/services/user_service.py
from datetime import datetime
from typing import List, Optional
from models.user_model import User, UserCreate, UserUpdate, Address, AddressUpdate
from fastapi import HTTPException


async def create_user(user_data: UserCreate) -> User:
    """Create a new user in the database."""
    # Check if user already exists with this firebase_uid
    existing_user = await User.find_one({"firebase_uid": user_data.firebase_uid})
    if existing_user:
        raise HTTPException(status_code=400, detail="User already exists")
    
    # Create new user
    user = User(
        firebase_uid=user_data.firebase_uid,
        email=user_data.email,
        first_name=user_data.first_name,
        last_name=user_data.last_name,
        district_ids=[],
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
        last_login_at=datetime.utcnow(),
    )
    
    # Save to database
    await user.insert()
    return user


async def get_user_by_firebase_uid(firebase_uid: str) -> Optional[User]:
    """Get a user by their Firebase UID."""
    user = await User.find_one({"firebase_uid": firebase_uid})
    return user


async def update_user(firebase_uid: str, user_data: UserUpdate) -> Optional[User]:
    """Update a user's information."""
    user = await get_user_by_firebase_uid(firebase_uid)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Update user fields
    update_data = user_data.dict(exclude_unset=True)
    
    # Always update the updated_at timestamp
    if "updated_at" not in update_data:
        update_data["updated_at"] = datetime.utcnow()
    
    # Update user document
    await user.update({"$set": update_data})
    
    # Refresh user from database
    return await get_user_by_firebase_uid(firebase_uid)


async def update_user_address(firebase_uid: str, address_data: AddressUpdate) -> Optional[User]:
    """Update a user's address."""
    user = await get_user_by_firebase_uid(firebase_uid)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Create Address model
    address = Address(
        street=address_data.street,
        city=address_data.city,
        state=address_data.state,
        zipCode=address_data.zipCode,
        coordinates=address_data.coordinates,
    )
    
    # Update user
    await user.update({
        "$set": {
            "address": address.dict(),
            "updated_at": datetime.utcnow()
        }
    })
    
    # Refresh user from database
    return await get_user_by_firebase_uid(firebase_uid)


async def delete_user(firebase_uid: str) -> bool:
    """Delete a user from the database."""
    user = await get_user_by_firebase_uid(firebase_uid)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    await user.delete()
    return True


async def update_login_timestamp(firebase_uid: str) -> Optional[User]:
    """Update a user's last login timestamp."""
    user = await get_user_by_firebase_uid(firebase_uid)
    if not user:
        return None
    
    # Update login timestamp
    await user.update({
        "$set": {
            "last_login_at": datetime.utcnow()
        }
    })
    
    return await get_user_by_firebase_uid(firebase_uid)