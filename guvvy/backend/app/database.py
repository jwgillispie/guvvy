# backend/app/database.py
from beanie import init_beanie
import motor.motor_asyncio
from app.models.user_model import User
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

async def init_db():
    # Get MongoDB connection string from environment variable or use default
    mongodb_url = os.getenv("MONGODB_URL", "mongodb+srv://username:password@cluster.mongodb.net/guvvy")
    
    # Create the MongoDB client
    client = motor.motor_asyncio.AsyncIOMotorClient(mongodb_url)
    
    # Initialize Beanie with the document models
    await init_beanie(
        database=client.guvvy,
        document_models=[User]
    )

    print("Connected to MongoDB: guvvy database")