"""
AI Provider Abstraction Layer
Supports: Gemini, OpenAI, Grok, Ollama, OpenRouter
Swap providers via DEFAULT_AI_PROVIDER in .env - no code changes needed.
"""
import logging
from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional, AsyncIterator
import httpx

from app.core.config import settings

logger = logging.getLogger(__name__)


# ─── Base Provider ────────────────────────────────────────────────────────────

class BaseAIProvider(ABC):
    @abstractmethod
    async def complete(
        self,
        messages: List[Dict[str, str]],
        temperature: float = 0.7,
        max_tokens: int = 2048,
        stream: bool = False,
    ) -> str:
        ...

    @property
    @abstractmethod
    def provider_name(self) -> str:
        ...

    @property
    @abstractmethod
    def model_name(self) -> str:
        ...


# ─── Gemini ───────────────────────────────────────────────────────────────────

class GeminiProvider(BaseAIProvider):
    provider_name = "gemini"
    model_name    = settings.gemini_model

    async def complete(self, messages, temperature=0.7, max_tokens=2048, stream=False) -> str:
        import google.generativeai as genai
        genai.configure(api_key=settings.gemini_api_key)
        model = genai.GenerativeModel(settings.gemini_model)

        # Convert messages to Gemini chat format
        history = []
        system_text = ""
        for m in messages:
            if m["role"] == "system":
                system_text = m["content"]
            elif m["role"] == "user":
                history.append({"role": "user", "parts": [m["content"]]})
            elif m["role"] == "assistant":
                history.append({"role": "model", "parts": [m["content"]]})

        # Prepend system prompt to first user message
        if system_text and history and history[0]["role"] == "user":
            history[0]["parts"][0] = f"{system_text}\n\n{history[0]['parts'][0]}"

        if not history:
            raise ValueError("No user messages provided")

        last_user = history.pop()
        chat = model.start_chat(history=history)
        response = await chat.send_message_async(
            last_user["parts"][0],
            generation_config=genai.GenerationConfig(
                temperature=temperature,
                max_output_tokens=max_tokens,
            ),
        )
        return response.text


# ─── OpenAI ───────────────────────────────────────────────────────────────────

class OpenAIProvider(BaseAIProvider):
    provider_name = "openai"
    model_name    = settings.openai_model

    async def complete(self, messages, temperature=0.7, max_tokens=2048, stream=False) -> str:
        from openai import AsyncOpenAI
        client = AsyncOpenAI(api_key=settings.openai_api_key)
        response = await client.chat.completions.create(
            model       = settings.openai_model,
            messages    = messages,
            temperature = temperature,
            max_tokens  = max_tokens,
        )
        return response.choices[0].message.content or ""


# ─── Grok (xAI) ───────────────────────────────────────────────────────────────

class GrokProvider(BaseAIProvider):
    provider_name = "grok"
    model_name    = settings.grok_model

    async def complete(self, messages, temperature=0.7, max_tokens=2048, stream=False) -> str:
        from openai import AsyncOpenAI
        client = AsyncOpenAI(
            api_key  = settings.grok_api_key,
            base_url = "https://api.x.ai/v1",
        )
        response = await client.chat.completions.create(
            model       = settings.grok_model,
            messages    = messages,
            temperature = temperature,
            max_tokens  = max_tokens,
        )
        return response.choices[0].message.content or ""


# ─── OpenRouter ───────────────────────────────────────────────────────────────

class OpenRouterProvider(BaseAIProvider):
    provider_name = "openrouter"
    model_name    = settings.openrouter_model

    async def complete(self, messages, temperature=0.7, max_tokens=2048, stream=False) -> str:
        async with httpx.AsyncClient(timeout=60) as client:
            response = await client.post(
                "https://openrouter.ai/api/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {settings.openrouter_api_key}",
                    "HTTP-Referer": "https://studymate.ai",
                    "X-Title": "StudyMate AI",
                },
                json={
                    "model":       settings.openrouter_model,
                    "messages":    messages,
                    "temperature": temperature,
                    "max_tokens":  max_tokens,
                },
            )
            response.raise_for_status()
            return response.json()["choices"][0]["message"]["content"]


# ─── Ollama (Local) ───────────────────────────────────────────────────────────

class OllamaProvider(BaseAIProvider):
    provider_name = "ollama"
    model_name    = settings.ollama_model

    async def complete(self, messages, temperature=0.7, max_tokens=2048, stream=False) -> str:
        async with httpx.AsyncClient(timeout=120, base_url=settings.ollama_base_url) as client:
            response = await client.post("/api/chat", json={
                "model":    settings.ollama_model,
                "messages": messages,
                "stream":   False,
                "options":  {"temperature": temperature, "num_predict": max_tokens},
            })
            response.raise_for_status()
            return response.json()["message"]["content"]


# ─── Provider Factory ─────────────────────────────────────────────────────────

_PROVIDERS = {
    "gemini":      GeminiProvider,
    "openai":      OpenAIProvider,
    "grok":        GrokProvider,
    "openrouter":  OpenRouterProvider,
    "ollama":      OllamaProvider,
}

_provider_instance: Optional[BaseAIProvider] = None


def get_ai_provider(provider_name: Optional[str] = None) -> BaseAIProvider:
    """Return singleton AI provider. Swap by setting provider_name or DEFAULT_AI_PROVIDER."""
    global _provider_instance
    name = (provider_name or settings.default_ai_provider).lower()

    # Re-instantiate if different provider requested
    if _provider_instance is None or _provider_instance.provider_name != name:
        cls = _PROVIDERS.get(name)
        if not cls:
            raise ValueError(f"Unknown AI provider: {name}. Choose from: {list(_PROVIDERS.keys())}")
        _provider_instance = cls()
        logger.info(f"AI provider set to: {name} / {_provider_instance.model_name}")

    return _provider_instance
