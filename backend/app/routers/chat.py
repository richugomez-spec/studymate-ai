"""Chat API – RAG-powered AI chat"""
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database.database import get_db
from app.database.models import ChatSession, ChatMessage
from app.services.rag_service import rag_service

router = APIRouter(prefix="/chat", tags=["Chat"])


class ChatRequest(BaseModel):
    session_id:    Optional[str] = None
    user_id:       str
    message:       str
    document_id:   Optional[str] = None
    provider:      Optional[str] = None


class NewSessionRequest(BaseModel):
    user_id:     str
    document_id: Optional[str] = None
    title:       Optional[str] = None


@router.post("/session", summary="Create chat session")
async def create_session(req: NewSessionRequest, db: AsyncSession = Depends(get_db)):
    session = await rag_service.create_session(
        db, req.user_id, req.document_id, req.title
    )
    return {"session_id": session.id, "title": session.title}


@router.post("/message", summary="Send message – RAG response")
async def send_message(req: ChatRequest, db: AsyncSession = Depends(get_db)):
    # Auto-create session if not provided
    if not req.session_id:
        session = await rag_service.create_session(db, req.user_id, req.document_id)
        session_id = session.id
    else:
        session_id = req.session_id

    result = await rag_service.chat(
        db            = db,
        session_id    = session_id,
        user_message  = req.message,
        document_id   = req.document_id,
        user_id       = req.user_id,
        provider_name = req.provider,
    )
    return {
        "session_id": session_id,
        "answer":     result["answer"],
        "sources":    result["sources"],
        "provider":   result["provider"],
        "model":      result["model"],
    }


@router.get("/session/{session_id}/history", summary="Get chat history")
async def get_history(session_id: str, user_id: str, db: AsyncSession = Depends(get_db)):
    stmt = (
        select(ChatMessage)
        .where(ChatMessage.session_id == session_id)
        .order_by(ChatMessage.created_at.asc())
    )
    result = await db.execute(stmt)
    messages = result.scalars().all()
    return [
        {
            "id":       m.id,
            "role":     m.role,
            "content":  m.content,
            "sources":  m.sources,
            "created_at": m.created_at.isoformat(),
        }
        for m in messages
    ]


@router.get("/sessions", summary="List user chat sessions")
async def list_sessions(user_id: str, db: AsyncSession = Depends(get_db)):
    stmt = (
        select(ChatSession)
        .where(ChatSession.user_id == user_id)
        .order_by(ChatSession.created_at.desc())
        .limit(50)
    )
    result = await db.execute(stmt)
    sessions = result.scalars().all()
    return [
        {"id": s.id, "title": s.title, "created_at": s.created_at.isoformat()}
        for s in sessions
    ]
