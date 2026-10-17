import '../ai_message.dart';
import 'chunker.dart';

/// Builds the full AI prompt for a RAG query.
///
/// Combines:
/// 1. System persona & role instructions
/// 2. User's AI memory (weak topics, preferences)
/// 3. Retrieved document chunks (grounding context)
/// 4. Conversation history (short-term memory)
/// 5. Current user query
class ContextBuilder {
  /// Max tokens to use for retrieved context
  final int maxContextTokens;

  const ContextBuilder({this.maxContextTokens = 3000});

  /// Build the full message list to send to the AI provider
  List<AIMessage> build({
    required String userQuery,
    required List<DocumentChunk> retrievedChunks,
    required List<AIMessage> conversationHistory,
    String? topicName,
    String? subjectName,
    String? explanationStyle,
    List<String>? weakConcepts,
  }) {
    final messages = <AIMessage>[];

    // ── System Prompt ─────────────────────────────────────────────────────────
    messages.add(AIMessage(
      role: AIRole.system,
      content: _buildSystemPrompt(
        topicName: topicName,
        subjectName: subjectName,
        explanationStyle: explanationStyle ?? 'intermediate',
        weakConcepts: weakConcepts ?? [],
      ),
    ));

    // ── Context from notes (RAG) ───────────────────────────────────────────────
    if (retrievedChunks.isNotEmpty) {
      final contextText = _buildContextBlock(retrievedChunks);
      messages.add(AIMessage(
        role: AIRole.system,
        content:
            'RELEVANT CONTENT FROM STUDENT\'S NOTES:\n\n$contextText\n\n'
            'Base your response primarily on this content. '
            'If you use information outside these notes, clearly indicate that.',
      ));
    }

    // ── Conversation history (last 8 turns) ────────────────────────────────────
    final history = conversationHistory.length > 8
        ? conversationHistory.sublist(conversationHistory.length - 8)
        : conversationHistory;
    messages.addAll(history);

    // ── Current query ──────────────────────────────────────────────────────────
    messages.add(AIMessage(role: AIRole.user, content: userQuery));

    return messages;
  }

  String _buildSystemPrompt({
    String? topicName,
    String? subjectName,
    required String explanationStyle,
    required List<String> weakConcepts,
  }) {
    final style = switch (explanationStyle) {
      'beginner' => 'Use simple language, analogies, and real-world examples. '
          'Avoid jargon. Explain as if teaching a first-year student.',
      'expert' => 'Use precise technical terminology. '
          'Assume strong background knowledge. Be concise and rigorous.',
      _ => 'Use clear, balanced explanations suitable for an undergraduate student. '
          'Include examples when helpful.',
    };

    final contextSection = [
      if (subjectName != null) 'Subject: $subjectName',
      if (topicName != null) 'Current Topic: $topicName',
    ].join(' | ');

    final weakSection = weakConcepts.isNotEmpty
        ? '\nThe student has shown weakness in: ${weakConcepts.join(', ')}. '
            'Pay extra attention to clarity on these concepts.'
        : '';

    return '''You are StudyMate AI, a personal learning coach for university students. 
Your role is NOT to just answer questions — you actively help students UNDERSTAND and MASTER their subject.

$contextSection$weakSection

Your communication style: $style

Guidelines:
- CRITICAL: Always prioritize the student's uploaded notes over general model knowledge. Answer directly and specifically based on the provided notes.
- If the specific answer is NOT found in the provided notes, explicitly state: "This is not covered in your uploaded notes," and do not fabricate facts.
- Explain clearly like an expert academic mentor, keeping explanations grounded, structured, and factual.
- If a concept is complex, break it down into clean numbered steps or bullet points.
- Use markdown formatting: **bold** for key concepts and terms, code blocks for syntax or formulas.
- End with a targeted follow-up question or check-in to test the student's understanding.''';
  }

  String _buildContextBlock(List<DocumentChunk> chunks) {
    return chunks.asMap().entries.map((e) {
      return '[Source ${e.key + 1}]:\n${e.value.content}';
    }).join('\n\n---\n\n');
  }
}
