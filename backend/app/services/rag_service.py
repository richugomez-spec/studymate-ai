"""
RAG Service - Retrieval Augmented Generation
Retrieves relevant chunks from ChromaDB and builds grounded answers.
NEVER hallucinates - answers strictly from uploaded material.
"""
import logging
from typing import List, Dict, Any, Optional

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, insert
from datetime import datetime

from app.database.models import ChatSession, ChatMessage, Document
from app.services.embedding_service import embedding_service
from app.services.ai_providers import get_ai_provider
from app.core.config import settings

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = """You are StudyMate AI — an elite, Socratic academic tutor.

CRITICAL RULES:
1. Answer ONLY from the provided document context below.
2. If the answer is not in the context, say: "I could not find information about this in your uploaded notes. Please check your materials or ask a different question."
3. Do NOT hallucinate, invent facts, or use outside knowledge unless the user explicitly says "use your general knowledge".
4. Be concise, clear, and pedagogical — use examples, analogies, and follow-up questions to deepen understanding.
5. Cite [Page X] or [Slide Y] when visible in context.

DOCUMENT CONTEXT:
{context}
"""


class RAGService:

    async def chat(
        self,
        db: AsyncSession,
        session_id: str,
        user_message: str,
        document_id: Optional[str] = None,
        user_id: Optional[str] = None,
        provider_name: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Full RAG pipeline:
        1. Retrieve relevant chunks
        2. Build context
        3. Call AI provider
        4. Persist messages
        5. Return response + sources
        """
        # 1. Retrieve chunks
        chunks = embedding_service.retrieve_chunks(
            query       = user_message,
            document_id = document_id,
            user_id     = user_id,
            top_k       = settings.top_k_chunks,
        )

        # 2. Build grounded context
        if chunks:
            context_parts = []
            for i, c in enumerate(chunks):
                context_parts.append(f"[Source {i+1} | score={c['score']}]\n{c['text']}")
            context_block = "\n\n---\n\n".join(context_parts)
        else:
            context_block = "No relevant sections found in the uploaded document."

        system_prompt = SYSTEM_PROMPT.format(context=context_block)

        # 3. Load conversation history
        history_stmt = (
            select(ChatMessage)
            .where(ChatMessage.session_id == session_id)
            .order_by(ChatMessage.created_at.asc())
            .limit(20)
        )
        result   = await db.execute(history_stmt)
        history  = result.scalars().all()

        messages = [{"role": "system", "content": system_prompt}]
        for msg in history:
            messages.append({"role": msg.role, "content": msg.content})
        messages.append({"role": "user", "content": user_message})

        # 4. Call AI provider
        provider = get_ai_provider(provider_name)
        try:
            answer = await provider.complete(messages, temperature=0.5, max_tokens=2048)
        except Exception as e:
            logger.error(f"AI provider error: {e}", exc_info=True)
            # Fallback: synthesize answer from top chunk
            if chunks:
                answer = f"Based on your notes:\n\n{chunks[0]['text'][:800]}\n\n[AI provider unavailable - showing raw excerpt]"
            else:
                answer = "I could not find relevant information in your uploaded notes."

        # 5. Persist messages
        user_msg = ChatMessage(
            session_id = session_id,
            role       = "user",
            content    = user_message,
            created_at = datetime.utcnow(),
        )
        ai_msg = ChatMessage(
            session_id  = session_id,
            role        = "assistant",
            content     = answer,
            sources     = [{"text": c["text"][:200], "score": c["score"]} for c in chunks],
            created_at  = datetime.utcnow(),
        )
        db.add_all([user_msg, ai_msg])
        await db.commit()

        return {
            "answer":   answer,
            "sources":  chunks,
            "provider": provider.provider_name,
            "model":    provider.model_name,
        }

    async def create_session(
        self,
        db: AsyncSession,
        user_id: str,
        document_id: Optional[str] = None,
        title: Optional[str] = None,
    ) -> ChatSession:
        session = ChatSession(
            user_id     = user_id,
            document_id = document_id,
            title       = title or "New Chat",
            ai_provider = settings.default_ai_provider,
        )
        db.add(session)
        await db.commit()
        await db.refresh(session)
        return session


rag_service = RAGService()
