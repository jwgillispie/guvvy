# backend/main.py
from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from database.mongodb import init_db
import os
from routes.user_route import router as user_router

# Create FastAPI app
app = FastAPI(
    title="Guvvy API",
    description="Backend API for Guvvy Civic Engagement App",
    version="1.0.0",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(user_router)

# Startup event to initialize database
@app.on_event("startup")
async def startup_db_client():
    await init_db()

# Root endpoint
@app.get("/")
async def root():
    return {"message": "Welcome to Guvvy API"}

# Health check endpoint
@app.get("/health")
async def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    
    # Get port from environment variable or use default
    port = int(os.getenv("PORT", 8000))
    
    # Run the application
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)