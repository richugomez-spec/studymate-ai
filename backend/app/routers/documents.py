"""Documents API – upload, process, list, delete"""
import asyncio
from typing import List, Optional
from fastapi import APIRouter, Depends, File, Form, UploadFile, HTTPException, BackgroundTasks
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel

from app.database.database import get_db
from app.database.models import Document, DocumentStatus
from app.services.document_processor import DocumentProcessor
from app.services.embedding_service import embedding_service
from app.core.config import settings

router = APIRouter(prefix="/documents", tags=["Documents"])


class DocumentOut(BaseModel):
    id:           str
    file_name:    str
    file_type:    str
    file_size_bytes: int
    status:       str
    page_count:   Optional[int]
    chunk_count:  int
    created_at:   str

    class Config:
        from_attributes = True


@router.post("/upload", summary="Upload a document")
async def upload_document(
    background_tasks: BackgroundTasks,
    file:       UploadFile = File(...),
    user_id:    str        = Form(...),
    subject_id: str        = Form(None),
    db:         AsyncSession = Depends(get_db),
):
    # Validate size
    contents = await file.read()
    size_mb = len(contents) / (1024 * 1024)
    if size_mb > settings.max_file_size_mb:
        raise HTTPException(413, f"File too large: {size_mb:.1f}MB > {settings.max_file_size_mb}MB limit")

    filename  = file.filename or "upload"
    doc_type  = DocumentProcessor.detect_type(filename)
    file_path = await DocumentProcessor.save_file(contents, filename, user_id)

    doc = Document(
        user_id         = user_id,
        subject_id      = subject_id,
        file_name       = filename,
        file_path       = file_path,
        file_type       = doc_type,
        file_size_bytes = len(contents),
        status          = DocumentStatus.pending,
    )
    db.add(doc)
    await db.commit()
    await db.refresh(doc)

    # Process in background (extract + embed)
    background_tasks.add_task(
        _process_background, doc.id, db
    )

    return {
        "id":       doc.id,
        "status":   doc.status.value,
        "file_name":doc.file_name,
        "message":  "Upload received. Processing started in background.",
    }


async def _process_background(document_id: str, db: AsyncSession):
    """Background task: extract text + generate embeddings."""
    try:
        await DocumentProcessor.process_document(db, document_id, embedding_service)
    except Exception as e:
        pass  # status already set to failed in processor


@router.get("/{document_id}", summary="Get document details")
async def get_document(
    document_id: str,
    user_id:     str,
    db:          AsyncSession = Depends(get_db),
):
    stmt   = select(Document).where(Document.id == document_id, Document.user_id == user_id)
    result = await db.execute(stmt)
    doc    = result.scalar_one_or_none()
    if not doc:
        raise HTTPException(404, "Document not found")
    return {
        "id":           doc.id,
        "file_name":    doc.file_name,
        "file_type":    doc.file_type.value,
        "status":       doc.status.value,
        "page_count":   doc.page_count,
        "chunk_count":  doc.chunk_count,
        "file_size_bytes": doc.file_size_bytes,
        "created_at":   doc.created_at.isoformat(),
        "processed_at": doc.processed_at.isoformat() if doc.processed_at else None,
        "has_text":     bool(doc.raw_text),
    }


@router.get("/", summary="List user documents")
async def list_documents(
    user_id:    str,
    subject_id: Optional[str] = None,
    db:         AsyncSession = Depends(get_db),
):
    stmt = select(Document).where(Document.user_id == user_id)
    if subject_id:
        stmt = stmt.where(Document.subject_id == subject_id)
    stmt = stmt.order_by(Document.created_at.desc())
    result = await db.execute(stmt)
    docs = result.scalars().all()
    return [
        {
            "id":        d.id,
            "file_name": d.file_name,
            "file_type": d.file_type.value,
            "status":    d.status.value,
            "chunk_count": d.chunk_count,
            "created_at":  d.created_at.isoformat(),
        }
        for d in docs
    ]


@router.delete("/{document_id}", summary="Delete a document")
async def delete_document(
    document_id: str,
    user_id:     str,
    db:          AsyncSession = Depends(get_db),
):
    stmt   = select(Document).where(Document.id == document_id, Document.user_id == user_id)
    result = await db.execute(stmt)
    doc    = result.scalar_one_or_none()
    if not doc:
        raise HTTPException(404, "Document not found")

    # Remove from ChromaDB
    try:
        from app.services.embedding_service import _get_chroma
        chroma = _get_chroma()
        existing = chroma.get(where={"document_id": document_id})
        if existing["ids"]:
            chroma.delete(ids=existing["ids"])
    except Exception:
        pass

    await db.delete(doc)
    await db.commit()
    return {"message": "Document deleted successfully"}
