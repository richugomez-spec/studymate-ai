# StudyMate AI 🧠

> **An AI-powered Learning Operating System for university students.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## What is StudyMate AI?

StudyMate AI is not a chatbot. It is a **Learning Operating System** that:

- Understands your own uploaded study materials (PDFs, PPTs, handwritten notes, audio)
- Answers questions grounded in **your notes** (not generic internet knowledge)
- Actively tracks what you know, what you don't, and what to study next
- Generates quizzes, flashcards, summaries, and mind maps from your material
- Acts as a **personal learning coach** — not just a Q&A tool

---

## Platforms

| Platform | Status |
|---|---|
| Android | ✅ Supported |
| Web | ✅ Supported |
| iOS | 🔜 Architecture-ready |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x + Dart |
| State Management | Riverpod 2.x |
| Navigation | GoRouter |
| Local Database | Drift (SQLite ORM) |
| Cloud Backend | Firebase (Auth, Firestore, Storage, Functions) |
| AI (Cloud) | Gemini / OpenAI / Grok / OpenRouter |
| AI (Local/Offline) | Ollama (llama3, mistral) |
| OCR | Google ML Kit |
| Audio | Whisper API |
| Design | Material 3 + Custom Theme |

---

## Project Structure

```
lib/
├── main.dart              # Entry point
├── app.dart               # MaterialApp + Router
├── firebase_options.dart  # Firebase config (replace with your project)
├── core/                  # Shared infrastructure
│   ├── ai/                # AI provider abstraction + RAG pipeline
│   ├── database/          # Drift database + all table definitions
│   ├── routing/           # GoRouter configuration
│   ├── storage/           # Hive + SecureStorage
│   ├── theme/             # Design system (colors, typography, spacing)
│   └── widgets/           # Shared reusable widgets
└── features/              # Feature-first organization (24 modules)
    ├── auth/
    ├── dashboard/
    ├── semester/
    ├── subject/
    ├── unit/
    ├── topic/
    ├── ai_chat/
    ├── analytics/
    ├── settings/
    └── ... (and 15 more)
```

---

## Getting Started

### 1. Prerequisites

- Flutter 3.24+ installed
- Dart 3.4+
- Firebase project created
- AI provider API key (Gemini recommended for start)

### 2. Clone & Install

```bash
git clone https://github.com/your-org/studymate-ai.git
cd studymate-ai
flutter pub get
```

### 3. Firebase Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure your Firebase project
flutterfire configure --project=your-firebase-project-id
```

This replaces `lib/firebase_options.dart` with real credentials.

### 4. Configure AI Provider

In the app Settings → AI Provider, enter your API key. Supported providers:

| Provider | Notes |
|---|---|
| **Gemini** (recommended) | Free tier available |
| OpenAI | GPT-4o, GPT-4o-mini |
| Grok (xAI) | Fast inference |
| OpenRouter | Multi-model routing |
| **Ollama** | Fully offline, local models |

### 5. Run

```bash
# Android
flutter run -d android

# Web
flutter run -d chrome

# Release build
flutter build apk --release
flutter build web --release
```

### 6. Code Generation

After editing Drift tables, Riverpod providers, or Freezed models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## AI Provider Configuration

Changing the AI provider requires **only one config change** — no code rewrites:

```dart
// In Settings → AI Provider, or programmatically:
final config = AIConfig(
  providerType: AIProviderType.gemini,  // or openai, grok, ollama, openRouter
  apiKey: 'your-api-key',
  model: 'gemini-1.5-flash',
);
```

The `AIProvider` interface abstracts all providers identically.

---

## RAG Pipeline

```
Upload file → Extract text → Chunk (512 tokens, 50 overlap)
     → Embed → Store in local vector DB
     → At query time: embed query → cosine similarity search
     → Top-K chunks → assemble prompt → stream response
```

---

## Architecture

Clean Architecture with feature-first organization:

```
Presentation (Flutter Widgets + Riverpod)
     ↓
Application (Use Cases)
     ↓
Domain (Entities + Repository Interfaces)
     ↓
Infrastructure (Firebase + Drift + AI APIs)
```

---

## Development Roadmap

- [x] Phase 0 — Foundation (design system, routing, database, AI abstraction)
- [ ] Phase 1 — Core content (auth, semester/subject/topic CRUD, upload)
- [ ] Phase 2 — AI features (chat, summaries, quiz, flashcards)
- [ ] Phase 3 — Intelligence (weak topics, adaptive revision, planner)
- [ ] Phase 4 — Engagement (streaks, goals, achievements)
- [ ] Phase 5 — Polish & Play Store release

---

## License

MIT © StudyMate AI Team
