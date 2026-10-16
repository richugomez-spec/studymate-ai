"""
Embedding & ChromaDB Service
- Chunks document text using LangChain text splitter
- Generates embeddings via sentence-transformers (local, no API cost)
- Stores and retrieves from ChromaDB
"""
import logging
import uuid
from typing import List, Dict, Any

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database.models import Document, Chunk
from app.core.config import settings

logger = logging.getLogger(__name__)

# Lazy singletons
_embedder   = None
_chroma_col = None


def _get_embedder():
    global _embedder
    if _embedder is None:
        from sentence_transformers import SentenceTransformer
        _embedder = SentenceTransformer(
            settings.embedding_model,
            device=settings.embedding_device,
        )
        logger.info(f"Loaded embedding model: {settings.embedding_model}")
    return _embedder


def _get_chroma():
    global _chroma_col
    if _chroma_col is None:
        import chromadb
        client = chromadb.PersistentClient(path=settings.chroma_persist_dir)
        _chroma_col = client.get_or_create_collection(
            name=settings.chroma_collection,
            metadata={"hnsw:space": "cosine"},
        )
        logger.info(f"ChromaDB collection ready: {settings.chroma_collection}")
    return _chroma_col


def _chunk_text(text: str) -> List[str]:
    """Split text into overlapping chunks."""
    try:
        from langchain_text_splitters import RecursiveCharacterTextSplitter
        splitter = RecursiveCharacterTextSplitter(
            chunk_size=settings.chunk_size,
            chunk_overlap=settings.chunk_overlap,
            separators=["\n\n", "\n", ". ", " ", ""],
        )
        return splitter.split_text(text)
    except ImportError:
        # Fallback: simple fixed-size chunks
        size, overlap = settings.chunk_size, settings.chunk_overlap
        chunks, start = [], 0
        while start < len(text):
            chunks.append(text[start:start + size])
            start += size - overlap
        return chunks


class EmbeddingService:

    async def embed_document(self, db: AsyncSession, doc: Document) -> int:
        """
        Chunk document text, embed, store in ChromaDB & DB Chunk table.
        Returns number of chunks created.
        """
        if not doc.raw_text:
            return 0

        text_chunks = _chunk_text(doc.raw_text)
        if not text_chunks:
            return 0

        embedder = _get_embedder()
        chroma   = _get_chroma()

        # Delete any previous chunks for this document
        try:
            existing = chroma.get(where={"document_id": doc.id})
            if existing["ids"]:
                chroma.delete(ids=existing["ids"])
        except Exception:
            pass

        # Build batch
        ids, texts, metadatas, embeddings = [], [], [], []
        db_chunks: List[Chunk] = []

        for idx, chunk_text in enumerate(text_chunks):
            chunk_id  = str(uuid.uuid4())
            embedding = embedder.encode(chunk_text).tolist()

            ids.append(chunk_id)
            texts.append(chunk_text)
            metadatas.append({
                "document_id": doc.id,
                "user_id":     doc.user_id,
                "chunk_index": idx,
                "file_name":   doc.file_name,
            })
            embeddings.append(embedding)

            db_chunks.append(Chunk(
                id          = chunk_id,
                document_id = doc.id,
                chunk_index = idx,
                text        = chunk_text,
                token_count = len(chunk_text.split()),
                chroma_id   = chunk_id,
            ))

        # Insert into ChromaDB
        chroma.add(
            ids        = ids,
            documents  = texts,
            metadatas  = metadatas,
            embeddings = embeddings,
        )

        # Insert into SQLite
        db.add_all(db_chunks)
        await db.commit()

        logger.info(f"Embedded {len(db_chunks)} chunks for doc {doc.id}")
        return len(db_chunks)

    def retrieve_chunks(
        self,
        query: str,
        document_id: str | None = None,
        user_id: str | None = None,
        top_k: int | None = None,
    ) -> List[Dict[str, Any]]:
        """Semantic retrieval from ChromaDB. Returns list of {text, score, metadata}."""
        top_k    = top_k or settings.top_k_chunks
        embedder = _get_embedder()
        chroma   = _get_chroma()

        query_embedding = embedder.encode(query).tolist()

        where: Dict[str, Any] = {}
        if document_id:
            where["document_id"] = document_id
        elif user_id:
            where["user_id"] = user_id

        results = chroma.query(
            query_embeddings = [query_embedding],
            n_results        = top_k,
            where            = where if where else None,
            include          = ["documents", "metadatas", "distances"],
        )

        chunks = []
        if results["documents"] and results["documents"][0]:
            for doc_text, meta, dist in zip(
                results["documents"][0],
                results["metadatas"][0],
                results["distances"][0],
            ):
                chunks.append({
                    "text":     doc_text,
                    "score":    round(1 - dist, 4),   # cosine → similarity
                    "metadata": meta,
                })

        return chunks


embedding_service = EmbeddingService()
