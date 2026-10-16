"""SQLAlchemy ORM models – all database tables for StudyMate AI"""
from datetime import datetime
from sqlalchemy import (
    Column, String, Integer, Float, Boolean, DateTime,
    Text, ForeignKey, JSON, Enum as SAEnum
)
from sqlalchemy.orm import DeclarativeBase, relationship
import enum
import uuid


def gen_uuid():
    return str(uuid.uuid4())


class Base(DeclarativeBase):
    pass


# ─── Enums ────────────────────────────────────────────────────────────────────

class DocumentStatus(str, enum.Enum):
    pending    = "pending"
    processing = "processing"
    ready      = "ready"
    failed     = "failed"

class DocumentType(str, enum.Enum):
    pdf   = "pdf"
    docx  = "docx"
    pptx  = "pptx"
    txt   = "txt"
    image = "image"

class QuestionType(str, enum.Enum):
    mcq           = "mcq"
    short_answer  = "short_answer"
    long_answer   = "long_answer"

class DifficultyLevel(str, enum.Enum):
    easy   = "easy"
    medium = "medium"
    hard   = "hard"


# ─── User ─────────────────────────────────────────────────────────────────────

class User(Base):
    __tablename__ = "users"
    id           = Column(String, primary_key=True, default=gen_uuid)
    email        = Column(String, unique=True, nullable=False, index=True)
    display_name = Column(String, nullable=False)
    avatar_url   = Column(String, nullable=True)
    created_at   = Column(DateTime, default=datetime.utcnow)
    updated_at   = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    subjects      = relationship("Subject",      back_populates="user", cascade="all, delete-orphan")
    documents     = relationship("Document",     back_populates="user", cascade="all, delete-orphan")
    chats         = relationship("ChatSession",  back_populates="user", cascade="all, delete-orphan")
    quiz_attempts = relationship("QuizAttempt",  back_populates="user", cascade="all, delete-orphan")
    study_plans   = relationship("StudyPlan",    back_populates="user", cascade="all, delete-orphan")
    study_sessions= relationship("StudySession", back_populates="user", cascade="all, delete-orphan")


# ─── Subject / Topic ──────────────────────────────────────────────────────────

class Subject(Base):
    __tablename__ = "subjects"
    id          = Column(String, primary_key=True, default=gen_uuid)
    user_id     = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    name        = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    color       = Column(String, nullable=True)
    icon        = Column(String, nullable=True)
    exam_date   = Column(DateTime, nullable=True)
    created_at  = Column(DateTime, default=datetime.utcnow)

    user      = relationship("User",     back_populates="subjects")
    topics    = relationship("Topic",    back_populates="subject", cascade="all, delete-orphan")
    documents = relationship("Document", back_populates="subject")


class Topic(Base):
    __tablename__ = "topics"
    id          = Column(String, primary_key=True, default=gen_uuid)
    subject_id  = Column(String, ForeignKey("subjects.id", ondelete="CASCADE"), nullable=False, index=True)
    name        = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    mastery_pct = Column(Float,   default=0.0)
    is_weak     = Column(Boolean, default=False)
    is_strong   = Column(Boolean, default=False)
    created_at  = Column(DateTime, default=datetime.utcnow)

    subject = relationship("Subject", back_populates="topics")


# ─── Document ─────────────────────────────────────────────────────────────────

class Document(Base):
    __tablename__ = "documents"
    id              = Column(String, primary_key=True, default=gen_uuid)
    user_id         = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    subject_id      = Column(String, ForeignKey("subjects.id", ondelete="SET NULL"), nullable=True, index=True)
    file_name       = Column(String, nullable=False)
    file_path       = Column(String, nullable=False)
    file_type       = Column(SAEnum(DocumentType), nullable=False)
    file_size_bytes = Column(Integer, nullable=False)
    status          = Column(SAEnum(DocumentStatus), default=DocumentStatus.pending, nullable=False)
    raw_text        = Column(Text, nullable=True)
    page_count      = Column(Integer, nullable=True)
    chunk_count     = Column(Integer, default=0)
    error_message   = Column(Text, nullable=True)
    created_at      = Column(DateTime, default=datetime.utcnow)
    processed_at    = Column(DateTime, nullable=True)

    user    = relationship("User",    back_populates="documents")
    subject = relationship("Subject", back_populates="documents")
    chunks  = relationship("Chunk",   back_populates="document", cascade="all, delete-orphan")
    flashcards = relationship("Flashcard", back_populates="document", cascade="all, delete-orphan")
    quiz_questions = relationship("QuizQuestion", back_populates="document", cascade="all, delete-orphan")


# ─── Chunks & Embeddings ──────────────────────────────────────────────────────

class Chunk(Base):
    __tablename__ = "chunks"
    id            = Column(String, primary_key=True, default=gen_uuid)
    document_id   = Column(String, ForeignKey("documents.id", ondelete="CASCADE"), nullable=False, index=True)
    chunk_index   = Column(Integer, nullable=False)
    text          = Column(Text,    nullable=False)
    token_count   = Column(Integer, nullable=True)
    page_number   = Column(Integer, nullable=True)
    chroma_id     = Column(String,  nullable=True)   # ID inside ChromaDB
    created_at    = Column(DateTime, default=datetime.utcnow)

    document = relationship("Document", back_populates="chunks")


# ─── Chat ─────────────────────────────────────────────────────────────────────

class ChatSession(Base):
    __tablename__ = "chat_sessions"
    id          = Column(String, primary_key=True, default=gen_uuid)
    user_id     = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    document_id = Column(String, ForeignKey("documents.id", ondelete="SET NULL"), nullable=True)
    title       = Column(String, nullable=True)
    ai_provider = Column(String, default="gemini")
    created_at  = Column(DateTime, default=datetime.utcnow)

    user     = relationship("User", back_populates="chats")
    messages = relationship("ChatMessage", back_populates="session", cascade="all, delete-orphan")


class ChatMessage(Base):
    __tablename__ = "chat_messages"
    id          = Column(String, primary_key=True, default=gen_uuid)
    session_id  = Column(String, ForeignKey("chat_sessions.id", ondelete="CASCADE"), nullable=False, index=True)
    role        = Column(String, nullable=False)   # user | assistant | system
    content     = Column(Text,   nullable=False)
    sources     = Column(JSON,   nullable=True)    # retrieved chunk IDs + snippets
    tokens_used = Column(Integer, nullable=True)
    created_at  = Column(DateTime, default=datetime.utcnow)

    session = relationship("ChatSession", back_populates="messages")


# ─── Quiz ─────────────────────────────────────────────────────────────────────

class QuizQuestion(Base):
    __tablename__ = "quiz_questions"
    id            = Column(String, primary_key=True, default=gen_uuid)
    document_id   = Column(String, ForeignKey("documents.id", ondelete="CASCADE"), nullable=False, index=True)
    topic_id      = Column(String, ForeignKey("topics.id", ondelete="SET NULL"), nullable=True)
    question_type = Column(SAEnum(QuestionType), nullable=False)
    difficulty    = Column(SAEnum(DifficultyLevel), default=DifficultyLevel.medium)
    question_text = Column(Text, nullable=False)
    options       = Column(JSON, nullable=True)     # list[str] for MCQ
    correct_answer= Column(Text, nullable=False)
    explanation   = Column(Text, nullable=True)
    source_chunk  = Column(String, nullable=True)   # chunk id
    created_at    = Column(DateTime, default=datetime.utcnow)

    document = relationship("Document", back_populates="quiz_questions")


class QuizAttempt(Base):
    __tablename__ = "quiz_attempts"
    id           = Column(String, primary_key=True, default=gen_uuid)
    user_id      = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    document_id  = Column(String, ForeignKey("documents.id", ondelete="SET NULL"), nullable=True)
    question_id  = Column(String, ForeignKey("quiz_questions.id", ondelete="SET NULL"), nullable=True)
    user_answer  = Column(Text, nullable=False)
    is_correct   = Column(Boolean, nullable=False)
    time_taken_s = Column(Integer, nullable=True)
    created_at   = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="quiz_attempts")


# ─── Flashcards ───────────────────────────────────────────────────────────────

class Flashcard(Base):
    __tablename__ = "flashcards"
    id          = Column(String, primary_key=True, default=gen_uuid)
    document_id = Column(String, ForeignKey("documents.id", ondelete="CASCADE"), nullable=False, index=True)
    user_id     = Column(String, ForeignKey("users.id",     ondelete="CASCADE"), nullable=False, index=True)
    front       = Column(Text, nullable=False)    # question / term
    back        = Column(Text, nullable=False)    # answer / definition
    source_text = Column(Text, nullable=True)
    ease_factor = Column(Float,   default=2.5)   # SRS
    interval    = Column(Integer, default=1)      # days
    repetitions = Column(Integer, default=0)
    next_review = Column(DateTime, default=datetime.utcnow)
    created_at  = Column(DateTime, default=datetime.utcnow)

    document = relationship("Document", back_populates="flashcards")


# ─── Study Plan ───────────────────────────────────────────────────────────────

class StudyPlan(Base):
    __tablename__ = "study_plans"
    id            = Column(String, primary_key=True, default=gen_uuid)
    user_id       = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    subject_id    = Column(String, ForeignKey("subjects.id", ondelete="SET NULL"), nullable=True)
    exam_date     = Column(DateTime, nullable=False)
    daily_hours   = Column(Float, nullable=False)
    plan_data     = Column(JSON,  nullable=False)   # generated schedule JSON
    created_at    = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="study_plans")
    sessions = relationship("StudySession", back_populates="plan")


class StudySession(Base):
    __tablename__ = "study_sessions"
    id             = Column(String, primary_key=True, default=gen_uuid)
    user_id        = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    plan_id        = Column(String, ForeignKey("study_plans.id", ondelete="SET NULL"), nullable=True)
    document_id    = Column(String, ForeignKey("documents.id",   ondelete="SET NULL"), nullable=True)
    duration_min   = Column(Integer, nullable=False)
    notes          = Column(Text, nullable=True)
    topics_covered = Column(JSON, nullable=True)    # list of topic ids
    started_at     = Column(DateTime, nullable=False)
    ended_at       = Column(DateTime, nullable=True)

    user = relationship("User", back_populates="study_sessions")
    plan = relationship("StudyPlan", back_populates="sessions")
