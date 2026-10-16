"""
StudyMate AI - FastAPI Backend
Production-ready AI Learning OS backend.
"""
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.database.database import init_db
from app.routers import documents, chat, quiz, flashcards, planner, analytics

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)
logger = logging.getLogger("studymate")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup: init DB tables."""
    logger.info("Starting StudyMate AI Backend...")
    await init_db()
    logger.info("Database initialized")
    yield
    logger.info("Shutting down StudyMate AI Backend")


app = FastAPI(
    title       = "StudyMate AI Backend",
    description = "AI Learning Operating System — Document Processing, RAG, Quiz, Flashcard, Planner & Analytics APIs",
    version     = "1.0.0",
    lifespan    = lifespan,
    docs_url    = "/docs",
    redoc_url   = "/redoc",
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins     = settings.cors_origins_list,
    allow_credentials = True,
    allow_methods     = ["*"],
    allow_headers     = ["*"],
)

# Routers
app.include_router(documents.router, prefix="/api/v1")
app.include_router(chat.router,      prefix="/api/v1")
app.include_router(quiz.router,      prefix="/api/v1")
app.include_router(flashcards.router,prefix="/api/v1")
app.include_router(planner.router,   prefix="/api/v1")
app.include_router(analytics.router, prefix="/api/v1")


@app.get("/", tags=["Health"])
async def root():
    return {
        "service": "StudyMate AI Backend",
        "version": "1.0.0",
        "status":  "running",
        "docs":    "/docs",
    }


@app.get("/health", tags=["Health"])
async def health():
    return {"status": "ok"}


@app.get("/api/v1/providers", tags=["Config"])
async def list_providers():
    from app.services.ai_providers import _PROVIDERS
    return {
        "default":    settings.default_ai_provider,
        "available":  list(_PROVIDERS.keys()),
        "configured": {
            "gemini":     bool(settings.gemini_api_key),
            "openai":     bool(settings.openai_api_key),
            "grok":       bool(settings.grok_api_key),
            "openrouter": bool(settings.openrouter_api_key),
            "ollama":     True,   # always available if ollama is running locally
        },
    }
