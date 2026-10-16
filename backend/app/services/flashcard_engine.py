"""
Flashcard Engine with Spaced Repetition (SM-2 algorithm)
Generates flashcards from study material and schedules reviews.
"""
import json, re, logging
from datetime import datetime, timedelta
from typing import List, Optional, Dict

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.database.models import Flashcard, Document
from app.services.embedding_service import embedding_service
from app.services.ai_providers import get_ai_provider

logger = logging.getLogger(__name__)

FLASHCARD_PROMPT = """You are an expert study card creator.
Generate {count} flashcards from the text below. Each card should capture one key concept.

TEXT:
{context}

Return ONLY valid JSON array:
[
  {{
    "front": "Term or question on the front of the card.",
    "back": "Definition, answer, or explanation on the back.",
    "hint": "Optional memory hook or mnemonic."
  }}
]"""


def _sm2_update(card: Flashcard, quality: int) -> Flashcard:
    """
    SM-2 spaced repetition update.
    quality: 0-5 (0=blackout, 3=correct with effort, 5=perfect)
    """
    if quality < 3:
        card.repetitions = 0
        card.interval    = 1
    else:
        if card.repetitions == 0:
            card.interval = 1
        elif card.repetitions == 1:
            card.interval = 6
        else:
            card.interval = round(card.interval * card.ease_factor)
        card.repetitions += 1

    card.ease_factor = max(1.3, card.ease_factor + 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
    card.next_review = datetime.utcnow() + timedelta(days=card.interval)
    return card


class FlashcardEngine:

    async def generate_flashcards(
        self,
        db: AsyncSession,
        document_id: str,
        user_id: str,
        count: int = 15,
        topic: Optional[str] = None,
        provider_name: Optional[str] = None,
    ) -> List[Flashcard]:

        query = topic or "key concepts definitions terms important facts"
        chunks = embedding_service.retrieve_chunks(
            query       = query,
            document_id = document_id,
            top_k       = 8,
        )

        if not chunks:
            stmt = select(Document).where(Document.id == document_id)
            res = await db.execute(stmt)
            doc = res.scalar_one_or_none()
            if not doc or not doc.raw_text:
                raise ValueError("Document not processed yet.")
            context = doc.raw_text[:4000]
        else:
            context = "\n\n".join(c["text"] for c in chunks)[:4000]

        filled = FLASHCARD_PROMPT.format(count=count, context=context)
        provider = get_ai_provider(provider_name)
        raw = await provider.complete(
            messages    = [{"role": "user", "content": filled}],
            temperature = 0.5,
            max_tokens  = 3000,
        )

        raw = raw.strip()
        raw = re.sub(r"^```(?:json)?\s*", "", raw)
        raw = re.sub(r"\s*```$",          "", raw)
        start, end = raw.find("["), raw.rfind("]") + 1
        cards_data = json.loads(raw[start:end]) if start != -1 else []

        db_cards: List[Flashcard] = []
        for cd in cards_data[:count]:
            card = Flashcard(
                document_id = document_id,
                user_id     = user_id,
                front       = cd.get("front", ""),
                back        = cd.get("back", ""),
                source_text = cd.get("hint", ""),
            )
            db_cards.append(card)

        db.add_all(db_cards)
        await db.commit()
        for c in db_cards:
            await db.refresh(c)

        logger.info(f"Generated {len(db_cards)} flashcards for doc {document_id}")
        return db_cards

    async def review_card(
        self,
        db: AsyncSession,
        card_id: str,
        quality: int,           # 0-5
    ) -> Flashcard:
        stmt = select(Flashcard).where(Flashcard.id == card_id)
        result = await db.execute(stmt)
        card = result.scalar_one_or_none()
        if not card:
            raise ValueError(f"Flashcard {card_id} not found")

        card = _sm2_update(card, quality)
        await db.commit()
        await db.refresh(card)
        return card

    async def get_due_cards(
        self,
        db: AsyncSession,
        user_id: str,
        document_id: Optional[str] = None,
        limit: int = 20,
    ) -> List[Flashcard]:
        stmt = (
            select(Flashcard)
            .where(
                Flashcard.user_id     == user_id,
                Flashcard.next_review <= datetime.utcnow(),
            )
        )
        if document_id:
            stmt = stmt.where(Flashcard.document_id == document_id)
        stmt = stmt.limit(limit)
        result = await db.execute(stmt)
        return result.scalars().all()


flashcard_engine = FlashcardEngine()
