"""Flashcard API – generate, review, list due cards"""
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database.database import get_db
from app.database.models import Flashcard
from app.services.flashcard_engine import flashcard_engine

router = APIRouter(prefix="/flashcards", tags=["Flashcards"])


class GenerateRequest(BaseModel):
    document_id: str
    user_id:     str
    count:       int = 15
    topic:       Optional[str] = None
    provider:    Optional[str] = None


class ReviewRequest(BaseModel):
    card_id: str
    quality: int   # 0-5 (SM-2)


@router.post("/generate", summary="Generate flashcards from document")
async def generate(req: GenerateRequest, db: AsyncSession = Depends(get_db)):
    cards = await flashcard_engine.generate_flashcards(
        db          = db,
        document_id = req.document_id,
        user_id     = req.user_id,
        count       = min(req.count, 50),
        topic       = req.topic,
        provider_name = req.provider,
    )
    return [
        {"id": c.id, "front": c.front, "back": c.back, "hint": c.source_text,
         "interval": c.interval, "next_review": c.next_review.isoformat()}
        for c in cards
    ]


@router.post("/review", summary="Submit flashcard review (SM-2)")
async def review(req: ReviewRequest, db: AsyncSession = Depends(get_db)):
    if req.quality < 0 or req.quality > 5:
        raise HTTPException(400, "quality must be 0-5")
    card = await flashcard_engine.review_card(db, req.card_id, req.quality)
    return {
        "id":          card.id,
        "interval":    card.interval,
        "ease_factor": card.ease_factor,
        "next_review": card.next_review.isoformat(),
        "repetitions": card.repetitions,
    }


@router.get("/due", summary="Get due flashcards for review")
async def due_cards(
    user_id:     str,
    document_id: Optional[str] = None,
    limit:       int = 20,
    db: AsyncSession = Depends(get_db),
):
    cards = await flashcard_engine.get_due_cards(db, user_id, document_id, limit)
    return [{"id": c.id, "front": c.front, "back": c.back} for c in cards]


@router.get("/", summary="List all flashcards")
async def list_cards(
    user_id:     str,
    document_id: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
):
    stmt = select(Flashcard).where(Flashcard.user_id == user_id)
    if document_id:
        stmt = stmt.where(Flashcard.document_id == document_id)
    result = await db.execute(stmt)
    cards = result.scalars().all()
    return [{"id": c.id, "front": c.front, "back": c.back, "interval": c.interval} for c in cards]
