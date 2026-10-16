"""
Quiz Engine
Generates MCQ, Short Answer, Long Answer questions from uploaded study material.
All questions are grounded in the document chunks - no hallucination.
"""
import json
import logging
import re
import uuid
from typing import List, Optional, Dict, Any
from datetime import datetime

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database.models import Document, QuizQuestion, QuizAttempt, QuestionType, DifficultyLevel
from app.services.embedding_service import embedding_service
from app.services.ai_providers import get_ai_provider
from app.core.config import settings

logger = logging.getLogger(__name__)


MCQ_PROMPT = """You are an expert exam paper setter.
Generate {count} multiple-choice questions from the text below.
Difficulty: {difficulty}

TEXT:
{context}

Return ONLY valid JSON array. No extra text. Format:
[
  {{
    "question": "Question text here?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correct_index": 0,
    "correct_answer": "Option A",
    "explanation": "Brief explanation why this is correct."
  }}
]"""

SHORT_ANSWER_PROMPT = """You are an expert exam paper setter.
Generate {count} short-answer questions (1-3 sentence answers) from the text below.
Difficulty: {difficulty}

TEXT:
{context}

Return ONLY valid JSON array:
[
  {{
    "question": "Question text here?",
    "correct_answer": "Model answer here.",
    "explanation": "Key points to include."
  }}
]"""

LONG_ANSWER_PROMPT = """You are an expert exam paper setter.
Generate {count} essay/long-answer questions from the text below.
Difficulty: {difficulty}

TEXT:
{context}

Return ONLY valid JSON array:
[
  {{
    "question": "Essay question here?",
    "correct_answer": "Full model answer / marking scheme.",
    "explanation": "Key concepts to address."
  }}
]"""


def _extract_json(raw: str) -> list:
    """Robustly extract JSON array from LLM output."""
    raw = raw.strip()
    # Strip markdown code fences
    raw = re.sub(r"^```(?:json)?\s*", "", raw)
    raw = re.sub(r"\s*```$", "", raw)
    # Find first [ ... ] block
    start = raw.find("[")
    end   = raw.rfind("]") + 1
    if start == -1 or end == 0:
        raise ValueError("No JSON array found in response")
    return json.loads(raw[start:end])


class QuizEngine:

    async def generate_questions(
        self,
        db: AsyncSession,
        document_id: str,
        question_type: QuestionType = QuestionType.mcq,
        difficulty: DifficultyLevel = DifficultyLevel.medium,
        count: int = 5,
        topic: Optional[str] = None,
        provider_name: Optional[str] = None,
    ) -> List[QuizQuestion]:
        """Generate questions from document chunks, persist to DB."""

        # Retrieve relevant chunks
        query = topic or "main concepts key ideas important topics"
        chunks = embedding_service.retrieve_chunks(
            query       = query,
            document_id = document_id,
            top_k       = min(count + 2, 8),
        )

        if not chunks:
            # Fallback: load raw text from DB
            stmt = select(Document).where(Document.id == document_id)
            result = await db.execute(stmt)
            doc = result.scalar_one_or_none()
            if not doc or not doc.raw_text:
                raise ValueError("Document has no processed text. Please wait for processing to complete.")
            context = doc.raw_text[:4000]
        else:
            context = "\n\n".join(c["text"] for c in chunks)[:4000]

        # Select prompt template
        if question_type == QuestionType.mcq:
            prompt = MCQ_PROMPT
        elif question_type == QuestionType.short_answer:
            prompt = SHORT_ANSWER_PROMPT
        else:
            prompt = LONG_ANSWER_PROMPT

        filled_prompt = prompt.format(
            count      = count,
            difficulty = difficulty.value,
            context    = context,
        )

        provider = get_ai_provider(provider_name)
        raw = await provider.complete(
            messages    = [{"role": "user", "content": filled_prompt}],
            temperature = 0.4,
            max_tokens  = 3000,
        )

        questions_data = _extract_json(raw)

        db_questions: List[QuizQuestion] = []
        for qd in questions_data[:count]:
            options = qd.get("options")
            correct = qd.get("correct_answer") or (
                options[qd["correct_index"]] if options and "correct_index" in qd else ""
            )
            q = QuizQuestion(
                document_id   = document_id,
                question_type = question_type,
                difficulty    = difficulty,
                question_text = qd["question"],
                options       = options,
                correct_answer= correct,
                explanation   = qd.get("explanation", ""),
                source_chunk  = chunks[0]["metadata"].get("document_id") if chunks else None,
            )
            db_questions.append(q)

        db.add_all(db_questions)
        await db.commit()
        for q in db_questions:
            await db.refresh(q)

        logger.info(f"Generated {len(db_questions)} {question_type.value} questions for doc {document_id}")
        return db_questions

    async def submit_answer(
        self,
        db: AsyncSession,
        user_id: str,
        question_id: str,
        user_answer: str,
        time_taken_s: Optional[int] = None,
    ) -> Dict:
        stmt = select(QuizQuestion).where(QuizQuestion.id == question_id)
        result = await db.execute(stmt)
        q = result.scalar_one_or_none()
        if not q:
            raise ValueError(f"Question {question_id} not found")

        is_correct = user_answer.strip().lower() == q.correct_answer.strip().lower()

        attempt = QuizAttempt(
            user_id     = user_id,
            document_id = q.document_id,
            question_id = question_id,
            user_answer = user_answer,
            is_correct  = is_correct,
            time_taken_s= time_taken_s,
        )
        db.add(attempt)
        await db.commit()

        return {
            "is_correct":      is_correct,
            "correct_answer":  q.correct_answer,
            "explanation":     q.explanation,
        }


quiz_engine = QuizEngine()
