"""Quiz API – generate questions, submit answers"""
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database.database import get_db
from app.database.models import QuizQuestion, QuestionType, DifficultyLevel
from app.services.quiz_engine import quiz_engine

router = APIRouter(prefix="/quiz", tags=["Quiz"])


class GenerateRequest(BaseModel):
    document_id:   str
    user_id:       str
    question_type: str = "mcq"
    difficulty:    str = "medium"
    count:         int = 5
    topic:         Optional[str] = None
    provider:      Optional[str] = None


class AnswerRequest(BaseModel):
    user_id:      str
    question_id:  str
    user_answer:  str
    time_taken_s: Optional[int] = None


@router.post("/generate", summary="Generate quiz questions from document")
async def generate_quiz(req: GenerateRequest, db: AsyncSession = Depends(get_db)):
    try:
        qtype = QuestionType(req.question_type)
        diff  = DifficultyLevel(req.difficulty)
    except ValueError as e:
        raise HTTPException(400, str(e))

    questions = await quiz_engine.generate_questions(
        db            = db,
        document_id   = req.document_id,
        question_type = qtype,
        difficulty    = diff,
        count         = min(req.count, 20),
        topic         = req.topic,
        provider_name = req.provider,
    )
    return [
        {
            "id":            q.id,
            "question":      q.question_text,
            "type":          q.question_type.value,
            "difficulty":    q.difficulty.value,
            "options":       q.options,
            "explanation":   q.explanation,
        }
        for q in questions
    ]


@router.post("/answer", summary="Submit quiz answer")
async def submit_answer(req: AnswerRequest, db: AsyncSession = Depends(get_db)):
    result = await quiz_engine.submit_answer(
        db           = db,
        user_id      = req.user_id,
        question_id  = req.question_id,
        user_answer  = req.user_answer,
        time_taken_s = req.time_taken_s,
    )
    return result


@router.get("/{document_id}", summary="Get existing questions for document")
async def get_questions(document_id: str, db: AsyncSession = Depends(get_db)):
    stmt   = select(QuizQuestion).where(QuizQuestion.document_id == document_id).limit(50)
    result = await db.execute(stmt)
    qs     = result.scalars().all()
    return [
        {
            "id":         q.id,
            "question":   q.question_text,
            "type":       q.question_type.value,
            "difficulty": q.difficulty.value,
            "options":    q.options,
        }
        for q in qs
    ]
