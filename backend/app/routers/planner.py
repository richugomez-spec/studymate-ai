"""Study Planner API"""
from typing import List, Optional
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database.database import get_db
from app.database.models import StudyPlan, StudySession
from app.services.study_planner import study_planner

router = APIRouter(prefix="/planner", tags=["Planner"])


class PlanRequest(BaseModel):
    user_id:     str
    exam_date:   datetime
    daily_hours: float
    subject_ids: List[str]
    provider:    Optional[str] = None


class LogSessionRequest(BaseModel):
    user_id:        str
    plan_id:        Optional[str] = None
    document_id:    Optional[str] = None
    duration_min:   int
    topics_covered: Optional[List[str]] = None
    notes:          Optional[str] = None


@router.post("/generate", summary="Generate personalized study plan")
async def generate_plan(req: PlanRequest, db: AsyncSession = Depends(get_db)):
    plan = await study_planner.generate_plan(
        db           = db,
        user_id      = req.user_id,
        exam_date    = req.exam_date,
        daily_hours  = req.daily_hours,
        subject_ids  = req.subject_ids,
        provider_name= req.provider,
    )
    return {
        "id":         plan.id,
        "exam_date":  plan.exam_date.isoformat(),
        "daily_hours":plan.daily_hours,
        "schedule":   plan.plan_data.get("schedule", []),
        "tips":       plan.plan_data.get("tips", []),
        "created_at": plan.created_at.isoformat(),
    }


@router.post("/session/log", summary="Log a completed study session")
async def log_session(req: LogSessionRequest, db: AsyncSession = Depends(get_db)):
    session = await study_planner.log_session(
        db             = db,
        user_id        = req.user_id,
        plan_id        = req.plan_id,
        document_id    = req.document_id,
        duration_min   = req.duration_min,
        topics_covered = req.topics_covered,
        notes          = req.notes,
    )
    return {"id": session.id, "duration_min": session.duration_min}


@router.get("/", summary="List user study plans")
async def list_plans(user_id: str, db: AsyncSession = Depends(get_db)):
    stmt = select(StudyPlan).where(StudyPlan.user_id == user_id).order_by(StudyPlan.created_at.desc())
    result = await db.execute(stmt)
    plans = result.scalars().all()
    return [
        {"id": p.id, "exam_date": p.exam_date.isoformat(), "created_at": p.created_at.isoformat()}
        for p in plans
    ]
