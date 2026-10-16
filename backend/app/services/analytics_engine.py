"""
Analytics Engine
Tracks documents, quiz scores, study sessions, weak/strong topics, progress.
"""
import logging
from datetime import datetime, timedelta
from typing import Dict, Any, List, Optional

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, case

from app.database.models import (
    Document, QuizAttempt, QuizQuestion, Flashcard,
    StudySession, Topic, ChatSession, ChatMessage
)

logger = logging.getLogger(__name__)


class AnalyticsEngine:

    async def get_dashboard(self, db: AsyncSession, user_id: str) -> Dict[str, Any]:
        """Aggregate all analytics for the user dashboard."""
        docs     = await self._document_stats(db, user_id)
        quiz     = await self._quiz_stats(db, user_id)
        study    = await self._study_stats(db, user_id)
        topics   = await self._topic_stats(db, user_id)
        progress = await self._weekly_progress(db, user_id)

        return {
            "documents":      docs,
            "quiz":           quiz,
            "study_sessions": study,
            "topics":         topics,
            "weekly_progress": progress,
            "generated_at":   datetime.utcnow().isoformat(),
        }

    async def _document_stats(self, db: AsyncSession, user_id: str) -> Dict:
        stmt = (
            select(
                func.count(Document.id).label("total"),
                func.sum(Document.chunk_count).label("total_chunks"),
                func.sum(Document.file_size_bytes).label("total_bytes"),
            )
            .where(Document.user_id == user_id)
        )
        result = await db.execute(stmt)
        row = result.one()
        return {
            "total_documents": row.total or 0,
            "total_chunks":    row.total_chunks or 0,
            "total_bytes":     row.total_bytes or 0,
        }

    async def _quiz_stats(self, db: AsyncSession, user_id: str) -> Dict:
        stmt = (
            select(
                func.count(QuizAttempt.id).label("total_attempts"),
                func.sum(case((QuizAttempt.is_correct == True, 1), else_=0)).label("correct"),
                func.avg(QuizAttempt.time_taken_s).label("avg_time_s"),
            )
            .where(QuizAttempt.user_id == user_id)
        )
        result = await db.execute(stmt)
        row = result.one()
        total    = row.total_attempts or 0
        correct  = int(row.correct or 0)
        accuracy = round(correct / total * 100, 1) if total > 0 else 0

        return {
            "total_attempts":  total,
            "correct_answers": correct,
            "accuracy_pct":    accuracy,
            "avg_time_s":      round(row.avg_time_s or 0, 1),
        }

    async def _study_stats(self, db: AsyncSession, user_id: str) -> Dict:
        stmt = (
            select(
                func.count(StudySession.id).label("total_sessions"),
                func.sum(StudySession.duration_min).label("total_minutes"),
            )
            .where(StudySession.user_id == user_id)
        )
        result = await db.execute(stmt)
        row = result.one()
        total_min = row.total_minutes or 0
        return {
            "total_sessions":   row.total_sessions or 0,
            "total_hours":      round(total_min / 60, 1),
            "total_minutes":    total_min,
        }

    async def _topic_stats(self, db: AsyncSession, user_id: str) -> Dict:
        # Weak topics: attempted multiple times, low accuracy
        attempts_stmt = (
            select(
                QuizAttempt.question_id,
                func.count(QuizAttempt.id).label("attempts"),
                func.sum(case((QuizAttempt.is_correct == True, 1), else_=0)).label("correct"),
            )
            .where(QuizAttempt.user_id == user_id)
            .group_by(QuizAttempt.question_id)
            .having(func.count(QuizAttempt.id) >= 2)
        )
        result = await db.execute(attempts_stmt)
        rows = result.all()

        weak_qids, strong_qids = [], []
        for row in rows:
            accuracy = (row.correct or 0) / row.attempts
            if accuracy < 0.5:
                weak_qids.append(row.question_id)
            elif accuracy >= 0.8:
                strong_qids.append(row.question_id)

        return {
            "weak_question_ids":   weak_qids[:10],
            "strong_question_ids": strong_qids[:10],
            "total_weak":          len(weak_qids),
            "total_strong":        len(strong_qids),
        }

    async def _weekly_progress(self, db: AsyncSession, user_id: str) -> List[Dict]:
        """Daily quiz attempts + study minutes for last 7 days."""
        seven_days_ago = datetime.utcnow() - timedelta(days=7)
        progress = []

        for i in range(7):
            day_start = datetime.utcnow() - timedelta(days=6-i)
            day_start = day_start.replace(hour=0, minute=0, second=0, microsecond=0)
            day_end   = day_start + timedelta(days=1)

            quiz_stmt = (
                select(func.count(QuizAttempt.id))
                .where(
                    QuizAttempt.user_id   == user_id,
                    QuizAttempt.created_at >= day_start,
                    QuizAttempt.created_at <  day_end,
                )
            )
            study_stmt = (
                select(func.sum(StudySession.duration_min))
                .where(
                    StudySession.user_id   == user_id,
                    StudySession.started_at >= day_start,
                    StudySession.started_at <  day_end,
                )
            )
            q_res = await db.execute(quiz_stmt)
            s_res = await db.execute(study_stmt)

            progress.append({
                "date":          day_start.strftime("%Y-%m-%d"),
                "quiz_attempts": q_res.scalar() or 0,
                "study_minutes": s_res.scalar() or 0,
            })

        return progress

    async def get_document_analytics(
        self,
        db: AsyncSession,
        user_id: str,
        document_id: str,
    ) -> Dict[str, Any]:
        doc_stmt = select(Document).where(Document.id == document_id, Document.user_id == user_id)
        res = await db.execute(doc_stmt)
        doc = res.scalar_one_or_none()
        if not doc:
            raise ValueError("Document not found")

        quiz_stmt = (
            select(
                func.count(QuizAttempt.id).label("attempts"),
                func.sum(case((QuizAttempt.is_correct == True, 1), else_=0)).label("correct"),
            )
            .where(QuizAttempt.user_id == user_id, QuizAttempt.document_id == document_id)
        )
        qres = await db.execute(quiz_stmt)
        qrow = qres.one()
        total   = qrow.attempts or 0
        correct = int(qrow.correct or 0)

        return {
            "document": {
                "id":         doc.id,
                "file_name":  doc.file_name,
                "page_count": doc.page_count,
                "chunk_count":doc.chunk_count,
                "status":     doc.status.value,
            },
            "quiz_accuracy": round(correct / total * 100, 1) if total > 0 else None,
            "quiz_attempts": total,
        }


analytics_engine = AnalyticsEngine()
