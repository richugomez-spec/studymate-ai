"""Analytics API"""
from typing import Optional
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database.database import get_db
from app.services.analytics_engine import analytics_engine

router = APIRouter(prefix="/analytics", tags=["Analytics"])


@router.get("/dashboard", summary="Full analytics dashboard")
async def dashboard(user_id: str, db: AsyncSession = Depends(get_db)):
    return await analytics_engine.get_dashboard(db, user_id)


@router.get("/document/{document_id}", summary="Analytics for a specific document")
async def document_analytics(document_id: str, user_id: str, db: AsyncSession = Depends(get_db)):
    return await analytics_engine.get_document_analytics(db, user_id, document_id)
