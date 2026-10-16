import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/document_processing_service.dart';
import '../../storage/secure_storage.dart';
import '../ai_config.dart';
import '../ai_message.dart';
import '../providers/gemini_provider.dart';

/// Notifier to manage Gemini API Key across the app
class AIApiKeyNotifier extends StateNotifier<String?> {
  final Ref _ref;

  AIApiKeyNotifier(this._ref) : super(_initialKey()) {
    _loadFromStorage();
  }

  static String? _initialKey() {
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.isNotEmpty) return envKey;
    return null;
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

  RealAIChatService(this._ref);

  /// Find top matching chunks from uploaded document
  List<String> _findRelevantChunks(String query, UploadedDocument? doc) {
    if (doc == null || doc.chunks.isEmpty) return [];

    final terms = query
        .toLowerCase()
        .split(RegExp(r'[^a-zA-Z0-9]+'))
        .where((t) => t.length > 2)
        .toList();

    if (terms.isEmpty) {
      return doc.chunks.take(3).map((c) => c.content).toList();
    }

    // Score chunks by keyword term frequency
    final scored = doc.chunks.map((chunk) {
      final text = chunk.content.toLowerCase();
      int matchCount = 0;
      for (final term in terms) {
        if (text.contains(term)) {
          matchCount += 1;
        }
      }
      return (chunk: chunk, score: matchCount);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));

    final top = scored.where((s) => s.score > 0).take(3).map((s) => s.chunk.content).toList();
    if (top.isNotEmpty) return top;

    return doc.chunks.take(2).map((c) => c.content).toList();
  }

  /// Send prompt and get real answer
  Future<String> askAI({
    required String prompt,
    required List<RealChatMessage> conversationHistory,
  }) async {
    final apiKey = _ref.read(aiApiKeyProvider);
    final activeDoc = _ref.read(activeDocumentProvider);

    final relevantChunks = _findRelevantChunks(prompt, activeDoc);
    final contextBlock = relevantChunks.isNotEmpty
        ? '\n\n--- DOCUMENT CONTEXT FROM ${activeDoc?.fileName ?? "STUDY MATERIAL"} ---\n${relevantChunks.join("\n\n")}\n--- END CONTEXT ---'
        : (activeDoc != null ? '\n\n--- UPLOADED DOCUMENT CONTENT ---\n${activeDoc.fullText.substring(0, activeDoc.fullText.length.clamp(0, 1500))}\n--- END ---' : '');

    // If Gemini API Key is available, invoke real Gemini 1.5 Flash!
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final provider = GeminiProvider(
          AIConfig(
            providerType: AIProviderType.gemini,
            apiKey: apiKey,
            model: 'gemini-1.5-flash',
            temperature: 0.6,
            maxTokens: 2048,
          ),
        );

        final systemPrompt = '''You are StudyMate AI, an elite Socratic learning OS and academic mentor.
You have direct access to the student's study materials.
Your goal is not just to give dry summaries, but to actively help the student master the concepts through intuitive explanations, clear examples, and check-in questions.
When answering, prioritize the uploaded document context below whenever relevant.

$contextBlock
''';

        final messages = <AIMessage>[
          AIMessage(role: AIRole.system, content: systemPrompt),
          ...conversationHistory.take(8).map((m) =>
              m.role == 'user'
                  ? AIMessage(role: AIRole.user, content: m.content)
                  : AIMessage(role: AIRole.assistant, content: m.content)),
          AIMessage(role: AIRole.user, content: prompt),
        ];

        final response = await provider.complete(AIRequest(messages: messages));
        if (response.content.trim().isNotEmpty) {
          return response.content.trim();
        }
      } catch (e) {
        // Fall back to contextual RAG synthesis if API fails or quota exceeded
        return _buildContextualRagAnswer(prompt, relevantChunks, activeDoc, error: e.toString());
      }
    }

    // Extractive RAG when no Gemini API key is configured yet
    return _buildContextualRagAnswer(prompt, relevantChunks, activeDoc);
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
