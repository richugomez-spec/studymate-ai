"""Central configuration – reads from .env"""
from pydantic_settings import BaseSettings
from pydantic import Field
from typing import List
import os

class Settings(BaseSettings):
    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    debug: bool = False
    cors_origins: str = "http://localhost:8080,http://localhost:3000"

    # Database
    database_url: str = "sqlite+aiosqlite:///./studymate.db"

    # Storage
    upload_dir: str = "./uploads"
    max_file_size_mb: int = 50

    # ChromaDB
    chroma_persist_dir: str = "./chroma_db"
    chroma_collection: str = "studymate_chunks"

    # Embeddings
    embedding_model: str = "all-MiniLM-L6-v2"
    embedding_device: str = "cpu"

    # AI Provider
    default_ai_provider: str = "gemini"
    gemini_api_key: str = ""
    openai_api_key: str = ""
    grok_api_key: str = ""
    openrouter_api_key: str = ""
    ollama_base_url: str = "http://localhost:11434"

    # AI Models
    gemini_model: str = "gemini-1.5-flash"
    openai_model: str = "gpt-4o-mini"
    grok_model: str = "grok-2-latest"
    openrouter_model: str = "meta-llama/llama-3.1-8b-instruct:free"
    ollama_model: str = "llama3.2"

    # RAG
    chunk_size: int = 800
    chunk_overlap: int = 150
    top_k_chunks: int = 6
    max_context_tokens: int = 6000

    # OCR
    tesseract_cmd: str = "tesseract"

    @property
    def cors_origins_list(self) -> List[str]:
        return [o.strip() for o in self.cors_origins.split(",")]

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()

# Ensure upload dir exists
os.makedirs(settings.upload_dir, exist_ok=True)
os.makedirs(settings.chroma_persist_dir, exist_ok=True)
