# backend/app/auth/firebase.py
import firebase_admin
from firebase_admin import credentials, auth
from fastapi import Request, HTTPException, status
from typing import Optional, Dict, Any
import os

class FirebaseAuth:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(FirebaseAuth, cls).__new__(cls)
            # Initialize Firebase Admin SDK if not already initialized
            try:
                firebase_admin.get_app()
                print("Firebase already initialized")
            except ValueError:
                # Path to the Firebase credentials file
                cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "firebase-credentials.json")
                try:
                    cred = credentials.Certificate(cred_path)
                    firebase_admin.initialize_app(cred)
                    print("Firebase initialized successfully")
                except Exception as e:
                    print(f"Error initializing Firebase: {e}")
        return cls._instance
    
    async def verify_token(self, token: str) -> Dict[str, Any]:
        """Verify the Firebase ID token and return user information."""
        try:
            decoded_token = auth.verify_id_token(token)
            return decoded_token
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Invalid authentication credentials: {str(e)}",
                headers={"WWW-Authenticate": "Bearer"},
            )
    
    async def get_user_from_request(self, request: Request) -> Optional[Dict[str, Any]]:
        """Extract and verify token from the request."""
        authorization = request.headers.get("Authorization")
        if not authorization or not authorization.startswith("Bearer "):
            return None
        
        token = authorization.replace("Bearer ", "")
        return await self.verify_token(token)