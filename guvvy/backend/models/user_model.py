# backend/models/user.py
from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field
from beanie import Document, Indexed


class Coordinates(BaseModel):
    latitude: float
    longitude: float


class Address(BaseModel):
    street: str
    city: str
    state: str
    zipCode: str
    coordinates: Optional[Coordinates] = None


class User(Document):
    firebase_uid: Indexed(str, unique=True)
    email: Indexed(EmailStr, unique=True)
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    address: Optional[Address] = None
    district_ids: List[str] = Field(default_factory=list)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    last_login_at: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "users"
        indexes = [
            "firebase_uid",
            "email",
        ]


class UserCreate(BaseModel):
    firebase_uid: str
    email: EmailStr
    first_name: Optional[str] = None
    last_name: Optional[str] = None


class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    address: Optional[Address] = None
    district_ids: Optional[List[str]] = None
    updated_at: Optional[datetime] = Field(default_factory=datetime.utcnow)
    last_login_at: Optional[datetime] = None


class AddressUpdate(BaseModel):
    street: str
    city: str
    state: str
    zipCode: str
    coordinates: Optional[Coordinates] = None