"""
Study Planner Engine
Accepts: exam date, subjects, daily hours
Generates: personalized study schedule with topics and time allocation.
"""
import json, re, logging
from datetime import datetime, timedelta, date
from typing import List, Optional, Dict, Any

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database.models import StudyPlan, Subject, Document, StudySession
from app.services.ai_providers import get_ai_provider

logger = logging.getLogger(__name__)

PLANNER_PROMPT = """You are an expert academic study planner.

Create a detailed day-by-day study schedule given:
- Exam date: {exam_date}
- Today: {today}
- Days available: {days_available}
- Daily study hours: {daily_hours}
- Subjects & topics: {subjects_info}

Rules:
1. Distribute topics evenly but spend more time on weak areas.
2. Include revision days before the exam.
3. Schedule breaks and rest days if the exam is more than 2 weeks away.
4. Each day entry should have specific topics to cover.

Return ONLY valid JSON:
{{
  "total_days": {days_available},
  "daily_hours": {daily_hours},
  "schedule": [
    {{
      "date": "YYYY-MM-DD",
      "day_label": "Day 1",
      "sessions": [
        {{
          "subject": "Subject name",
          "topic": "Topic to study",
          "duration_min": 60,
          "activity": "Read | Practice | Review | Mock Test"
        }}
      ],
      "notes": "Optional tip or focus point for the day."
    }}
  ],
  "revision_days": ["YYYY-MM-DD"],
  "tips": ["Study tip 1", "Study tip 2"]
}}"""


class StudyPlannerEngine:

    async def generate_plan(
        self,
        db: AsyncSession,
        user_id: str,
        exam_date: datetime,
        daily_hours: float,
        subject_ids: List[str],
        provider_name: Optional[str] = None,
    ) -> StudyPlan:

        today = datetime.utcnow().date()
        exam_day = exam_date.date()
        days_available = max(1, (exam_day - today).days)

        # Collect subject + topic info from DB
        subjects_info = []
        for sid in subject_ids:
            stmt = select(Subject).where(Subject.id == sid)
            res = await db.execute(stmt)
            subj = res.scalar_one_or_none()
            if subj:
                topics = [t.name for t in subj.topics] if subj.topics else ["General review"]
                subjects_info.append({"subject": subj.name, "topics": topics})

        if not subjects_info:
            subjects_info = [{"subject": "General Study", "topics": ["All topics"]}]

        filled = PLANNER_PROMPT.format(
            exam_date      = exam_day.isoformat(),
            today          = today.isoformat(),
            days_available = days_available,
            daily_hours    = daily_hours,
            subjects_info  = json.dumps(subjects_info, indent=2),
        )

        provider = get_ai_provider(provider_name)
        raw = await provider.complete(
            messages    = [{"role": "user", "content": filled}],
            temperature = 0.3,
            max_tokens  = 4000,
        )

        # Parse JSON
        raw = raw.strip()
        raw = re.sub(r"^```(?:json)?\s*", "", raw)
        raw = re.sub(r"\s*```$", "", raw)
        try:
            plan_data = json.loads(raw)
        except Exception:
            start = raw.find("{")
            end   = raw.rfind("}") + 1
            plan_data = json.loads(raw[start:end]) if start != -1 else {"schedule": [], "tips": []}

        plan = StudyPlan(
            user_id     = user_id,
            exam_date   = exam_date,
            daily_hours = daily_hours,
            plan_data   = plan_data,
        )
        db.add(plan)
        await db.commit()
        await db.refresh(plan)
        logger.info(f"Study plan generated: {days_available} days, {len(plan_data.get('schedule', []))} entries")
        return plan

    async def log_session(
        self,
        db: AsyncSession,
        user_id: str,
        plan_id: Optional[str],
        document_id: Optional[str],
        duration_min: int,
        topics_covered: Optional[List[str]] = None,
        notes: Optional[str] = None,
    ) -> StudySession:
        now = datetime.utcnow()
        session = StudySession(
            user_id        = user_id,
            plan_id        = plan_id,
            document_id    = document_id,
            duration_min   = duration_min,
            notes          = notes,
            topics_covered = topics_covered or [],
            started_at     = now - timedelta(minutes=duration_min),
            ended_at       = now,
        )
        db.add(session)
        await db.commit()
        await db.refresh(session)
        return session


study_planner = StudyPlannerEngine()
