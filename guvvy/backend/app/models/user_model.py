# backend/app/models/user_model.py
from beanie import Document, Indexed
from pydantic import EmailStr, Field
from typing import Optional, List
from datetime import datetime

class User(Document):
    class Settings:
        collection = "users"
        
    firebase_uid: Indexed(str, unique=True)
    email: Indexed(EmailStr, unique=True)
    display_name: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    is_active: bool = True
    is_verified: bool = False
    
    class Config:
        schema_extra = {
            "example": {
                "firebase_uid": "aBcDeFgHiJkLmNoPqRsT",
                "email": "user@example.com",
                "display_name": "John Doe",
                "first_name": "John",
                "last_name": "Doe"
            }
        }