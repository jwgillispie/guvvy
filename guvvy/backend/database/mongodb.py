# backend/database/mongodb.py
from models.user_model import User
import motor.motor_asyncio
from beanie import init_beanie

import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Get MongoDB connection string from environment variables
MONGODB_CONNECTION_STRING = os.getenv("MONGODB_CONNECTION_STRING", "mongodb://localhost:27017/guvvy")
MONGODB_DB_NAME = os.getenv("MONGODB_DB_NAME","guvvy")

async def init_db():
    """Initialize MongoDB connection and register document models."""
    # Create Motor client
    client = motor.motor_asyncio.AsyncIOMotorClient(MONGODB_CONNECTION_STRING)
    
    # Get database name from connection string
    db_name = MONGODB_DB_NAME
    
    # Initialize Beanie with the document models
    await init_beanie(
        database=client[db_name],
        document_models=[
            User,
            # Add other document models here as needed
        ],
    )
    
    print(f"Connected to MongoDB database: {db_name}")
    return client