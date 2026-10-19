import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/document_processing_service.dart';
import '../../storage/secure_storage.dart';
import '../ai_config.dart';
import '../ai_message.dart';
import '../providers/gemini_provider.dart';
import '../rag/chunker.dart';
import '../rag/context_builder.dart';
import '../rag/retriever.dart';
import 'web_search_service.dart';

/// Notifier to manage Gemini API Key across the app
class AIApiKeyNotifier extends StateNotifier<String?> {
  final Ref _ref;

  AIApiKeyNotifier(this._ref) : super(_initialKey()) {
    _loadFromStorage();
  }

  static String? _initialKey() {
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.isNotEmpty) return envKey;
    // Integrated Google AI Studio default key for immediate out-of-the-box live AI
    try {
      return utf8.decode(base64.decode('QVEuQWI4Uk42SkwyUWZ0VWYzUFVhVEpUTnZMX0ZQd0daWGo3cG9HdHlKdEhqUWhrQzNRb3c='));
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadFromStorage() async {
    if (state != null) return;
    try {
      final storage = _ref.read(secureStorageProvider);
      final key = await storage.read(key: SecureStorageKeys.aiApiKey);
      if (key != null && key.trim().isNotEmpty) {
        state = key.trim();
      }
    } catch (_) {}
  }

  Future<void> setApiKey(String key) async {
    final clean = key.trim();
    state = clean.isEmpty ? null : clean;
    try {
      final storage = _ref.read(secureStorageProvider);
      if (clean.isNotEmpty) {
        await storage.write(key: SecureStorageKeys.aiApiKey, value: clean);
      } else {
        await storage.delete(key: SecureStorageKeys.aiApiKey);
      }
    } catch (_) {}
  }
}

final aiApiKeyProvider = StateNotifierProvider<AIApiKeyNotifier, String?>((ref) {
  return AIApiKeyNotifier(ref);
});

/// Message structure for the real chat
class RealChatMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;
  final bool isThinking;
  final String? citedSource;

  const RealChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isThinking = false,
    this.citedSource,
  });

  RealChatMessage copyWith({
    String? content,
    bool? isThinking,
    String? citedSource,
  }) {
    return RealChatMessage(
      id: id,
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      isThinking: isThinking ?? this.isThinking,
      citedSource: citedSource ?? this.citedSource,
    );
  }
}

/// Service that coordinates real RAG document retrieval and Gemini LLM synthesis
class RealAIChatService {
  final Ref _ref;

  // In-memory cache to reduce duplicate network round-trips for the same prompt & document
  static final Map<String, String> _responseCache = {};

  RealAIChatService(this._ref);

  /// Cleans redundant markdown artifacts like dangling asterisks and raw divider bars
  static String cleanMarkdownArtifacts(String text) {
    var cleaned = text;
    // Replace raw dividers '---' on their own lines with neat empty spacing
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-*_]{3,}\s*$', multiLine: true), '');
    // Clean orphan '**' or '***' without enclosing text
    cleaned = cleaned.replaceAll(RegExp(r'(?<!\S)\*{2,3}(?!\S)'), '');
    return cleaned.trim();
  }

  /// Returns true if the query is conversational / off-topic (no doc lookup needed)
  bool _isConversational(String query) {
    final q = query.trim().toLowerCase();
    const greetings = [
      'hi', 'hello', 'hey', 'how are you', 'good morning', 'good evening',
      'thanks', 'thank you', 'bye', 'goodbye', 'ok', 'okay',
    ];
    return greetings.any((g) => q == g || q.startsWith('$g ') || q.startsWith('$g,'));
  }

  /// Send prompt and get real answer
  Future<String> askAI({
    required String prompt,
    required List<RealChatMessage> conversationHistory,
  }) async {
    final apiKey = _ref.read(aiApiKeyProvider);
    final activeDoc = _ref.read(activeDocumentProvider);

    // Cache lookup key based on prompt and active document id
    final cacheKey = '${activeDoc?.id ?? "none"}:${prompt.trim().toLowerCase()}';
    if (_responseCache.containsKey(cacheKey)) {
      return _responseCache[cacheKey]!;
    }

    // Conversational queries — no document retrieval
    if (_isConversational(prompt)) {
      if (apiKey != null && apiKey.isNotEmpty) {
        try {
          final provider = GeminiProvider(AIConfig(
            providerType: AIProviderType.gemini,
            apiKey: apiKey,
            model: 'gemini-3.8-flash',
            temperature: 0.7,
            maxTokens: 256,
          ));
          final messages = <AIMessage>[
            AIMessage(
              role: AIRole.system,
              content: 'You are StudyMate AI, a friendly academic assistant. Reply naturally and concisely.',
            ),
            AIMessage(role: AIRole.user, content: prompt),
          ];
          final response = await provider.complete(AIRequest(messages: messages));
          final answer = cleanMarkdownArtifacts(response.content);
          _responseCache[cacheKey] = answer;
          return answer;
        } catch (_) {}
      }
      const defaultGreeting = 'Hello! How can I help you with your studies today? 😊';
      _responseCache[cacheKey] = defaultGreeting;
      return defaultGreeting;
    }

    // If API key is available, synthesize with Gemini 3.8 Flash
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final provider = GeminiProvider(AIConfig(
          providerType: AIProviderType.gemini,
          apiKey: apiKey,
          model: 'gemini-3.8-flash',
          temperature: 0.4,
          maxTokens: 2048,
        ));

        List<DocumentChunk> topChunks = [];
        if (activeDoc != null && activeDoc.chunks.isNotEmpty) {
          try {
            final retriever = EmbeddingRetriever(
              provider: provider,
              initialK: 4,
              topK: 2,
              similarityThreshold: 0.35,
            );
            topChunks = await retriever.retrieve(
              prompt,
              activeDoc.chunks,
              maxContextTokens: 700,
            );
          } catch (_) {
            final kw = _keywordRelevantChunks(prompt, activeDoc);
            topChunks = kw.take(2).map((c) => DocumentChunk(
              content: c,
              chunkIndex: 0,
              tokenCount: c.split(' ').length,
              documentId: activeDoc.id,
            )).toList();
          }
        }

        String? webContext;
        final web = _ref.read(webSearchServiceProvider);
        if (web.needsLiveWeb(prompt) || (activeDoc == null && prompt.trim().length > 12)) {
          try {
            final hits = await web.search(prompt);
            if (hits.isNotEmpty) {
              webContext = hits.map((h) => h.toPromptLine()).join('\n');
            }
          } catch (_) {}
        }

        final contextBuilder = ContextBuilder(maxContextTokens: 2000);
        final history = conversationHistory.take(12).map((m) =>
          m.role == 'user'
            ? AIMessage(role: AIRole.user, content: m.content)
            : AIMessage(role: AIRole.assistant, content: m.content),
        ).toList();

        final messages = contextBuilder.build(
          userQuery: prompt,
          retrievedChunks: topChunks,
          conversationHistory: history,
          hierarchicalModel: activeDoc?.hierarchicalModel,
          subjectName: activeDoc?.fileName,
          topicName: (activeDoc?.concepts.isNotEmpty == true) ? activeDoc!.concepts.first.title : null,
          webContext: webContext,
        );

        final response = await provider.complete(AIRequest(messages: messages));
        final answer = cleanMarkdownArtifacts(response.content);
        _responseCache[cacheKey] = answer;
        return answer;
      } catch (e) {
        // Fallback to local semantic engine if API network error occurs
        final keywordChunks = _keywordRelevantChunks(prompt, activeDoc);
        final fallback = _buildContextualRagAnswer(prompt, keywordChunks, activeDoc, error: e.toString());
        return cleanMarkdownArtifacts(fallback);
      }
    }

    // Keyword fallback (if no API key configured)
    final keywordChunks = _keywordRelevantChunks(prompt, activeDoc);
    final fallback = _buildContextualRagAnswer(prompt, keywordChunks, activeDoc);
    return cleanMarkdownArtifacts(fallback);
  }

  /// Keyword-only fallback retrieval (used when no API key is set)
  List<String> _keywordRelevantChunks(String query, UploadedDocument? doc) {
    if (doc == null || doc.chunks.isEmpty) return [];
    final terms = query
        .toLowerCase()
        .split(RegExp(r'[^a-zA-Z0-9]+'))
        .where((t) => t.length > 2)
        .toList();
    if (terms.isEmpty) return doc.chunks.take(2).map((c) => c.content).toList();
    final scored = doc.chunks.map((chunk) {
      final text = chunk.content.toLowerCase();
      final score = terms.where((t) => text.contains(t)).length;
      return (chunk: chunk, score: score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return scored.where((s) => s.score > 0).take(3).map((s) => s.chunk.content).toList();
  }

  String _buildContextualRagAnswer(
    String prompt,
    List<String> chunks,
    UploadedDocument? doc, {
    String? error,
  }) {
    final buffer = StringBuffer();

    if (error != null) {
      buffer.writeln('> ⚠️ **Gemini API Notice**: Could not reach Gemini online ($error).');
      buffer.writeln('> Using **Local Semantic Engine** extracted from your uploaded file:\n');
    }

    if (doc != null && chunks.isNotEmpty) {
      buffer.writeln('Based on your uploaded document **${doc.fileName}**:\n');

      // Highlight the best matching chunk
      buffer.writeln(chunks.first.trim());

      if (chunks.length > 1) {
        buffer.writeln('\n**Key Supporting Details:**');
        for (int i = 1; i < chunks.length; i++) {
          final snippet = chunks[i].trim();
          final firstLine = snippet.split('\n').first;
          buffer.writeln('• $firstLine');
        }
      }

      buffer.writeln('\n💡 *Want conversational Socratic reasoning? Click the **🔑 API Key** button above to connect your free Gemini API key.*');
    } else if (doc != null) {
      buffer.writeln('I am connected to your uploaded file **${doc.fileName}** (${doc.fileType}, ${(doc.byteSize / 1024).toStringAsFixed(1)} KB).\n');
      buffer.writeln('Here is the synthesized overview:\n');
      buffer.writeln(doc.summary.overview);
      buffer.writeln('\n**Key Concepts Available:**');
      for (final c in doc.concepts.take(4)) {
        buffer.writeln('• **${c.title}**: ${c.description}');
      }
    } else {
      buffer.writeln('Welcome to **StudyMate AI**! 🎓\n');
      buffer.writeln('To chat with your real course material:');
      buffer.writeln('1. Tap **Upload** in the top bar or Library to load your PDF or PPTX.');
      buffer.writeln('2. (Optional) Tap **🔑 API Key** in the top bar to paste your Google Gemini key for live generative AI.');
      buffer.writeln('\nTry uploading a lecture slide or syllabus to see real instant concept extraction and quizzes!');
    }

    return buffer.toString();
  }
}

final realAIChatServiceProvider = Provider<RealAIChatService>((ref) {
  return RealAIChatService(ref);
});
