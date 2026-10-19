import '../ai_message.dart';
import 'chunker.dart';

/// Builds the full AI prompt for a RAG query.
///
/// Combines:
/// 1. System persona & teaching guidelines (ChatGPT / NotebookLM style)
/// 2. Student context & knowledge base grounding
/// 3. Conversational multi-turn history
/// 4. Current user query with typo & shorthand resilience
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

    // ── Context from notes (30% RAG / 70% Gemini Reasoning) ───────────────────
    if (retrievedChunks.isNotEmpty) {
      // Limit to top 3 most relevant chunks to optimize tokens and prevent prompt stuffing
      final topChunks = retrievedChunks.take(3).toList();
      final contextText = _buildContextBlock(topChunks);
      messages.add(AIMessage(
        role: AIRole.system,
        content:
            'REFERENCE MATERIAL (30% ANCHOR / 70% MODEL REASONING):\n\n$contextText\n\n'
            'INSTRUCTIONS:\n'
            '- Anchor your response to the student\'s notes where applicable.\n'
            '- Use model reasoning, general knowledge, real-world examples, and analogies to fill in any missing concepts.\n'
            '- NEVER say "I don\'t have enough information", "Not covered in your notes", or "Please upload more notes". Teach naturally like ChatGPT and an engaging professor.\n'
            '- Understand typos, shorthand, and one-word prompts ("cpu?", "why", "1", "expalin", "simple", "exam") effortlessly.',
      ));
    }

    // ── Compact Context Memory (Tokens optimized: summary + recent turns) ────
    if (conversationHistory.length > 6) {
      // Compress older exchanges into a compact summary memory to save 80% tokens
      final older = conversationHistory.sublist(0, conversationHistory.length - 6);
      final recent = conversationHistory.sublist(conversationHistory.length - 6);
      
      final olderSummary = older
          .where((m) => m.content.isNotEmpty)
          .map((m) => '${m.role.name}: ${m.content.length > 80 ? '${m.content.substring(0, 80)}...' : m.content}')
          .join(' | ');

      messages.add(AIMessage(
        role: AIRole.system,
        content: 'CONVERSATION CONTEXT MEMORY: $olderSummary',
      ));
      messages.addAll(recent);
    } else {
      messages.addAll(conversationHistory);
    }

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
    final contextSection = [
      if (subjectName != null && subjectName.isNotEmpty) 'Subject: $subjectName',
      if (topicName != null && topicName.isNotEmpty) 'Current Topic: $topicName',
    ].join(' | ');

    final weakSection = weakConcepts.isNotEmpty
        ? '\nStudent weak areas: ${weakConcepts.join(', ')}. Pay special attention to intuitive clarity on these topics.'
        : '';

    return '''You are StudyMate AI, an elite educational tutor, academic mentor, and personal professor (designed like ChatGPT / NotebookLM).
Your primary mission is to help students truly UNDERSTAND, REASON ABOUT, and MASTER concepts.

$contextSection$weakSection

CORE DIRECTIVES & TEACHING PHILOSOPHY:
1. ZERO REFUSAL POLICY:
   - NEVER refuse to answer a student.
   - NEVER say "This is not covered in your notes", "Please upload more content", or "I don't have enough context".
   - If retrieved notes are sparse, brief, or just contain a single keyword (e.g. "Binary Search" or "Semaphores"), use your full knowledge and reasoning engine to deliver a world-class educational lesson.

2. ROBUST PROMPT UNDERSTANDING & TYPO RESILIENCE:
   - Students frequently type in shorthand, with typos, abbreviations, or partial words (e.g., "binar serch" -> Binary Search, "dfs" -> Depth-First Search, "bst" -> Binary Search Tree, "recusion" -> Recursion, "expln" -> Explain, "why", "again", "idk", "confused").
   - Automatically infer user intent, correct misspellings, and resolve abbreviations immediately without asking unnecessary clarification questions.

3. CONVERSATIONAL MEMORY & MULTI-TURN CONTINUITY:
   - Maintain continuous awareness of previous turns in the chat session.
   - For example, if the student asks "Explain Stack", then follows with "Queue", then "Difference?", then "Example?", understand that they are comparing Stacks and Queues. Seamlessly build upon prior turns.

4. MASTER TEACHING STRUCTURE:
   When explaining or teaching a concept, structure your response naturally and educationally:
   - Direct, intuitive answer
   - Simple, crystal-clear explanation
   - Step-by-step breakdown or mechanics
   - Practical example (or code snippet / formula where applicable)
   - Real-world analogy (making the abstract tangible)
   - Common pitfalls or mistakes students make
   - Quick summary or exam / interview tip

5. CLEAN, NATURAL FORMATTING:
   - Deliver clean, readable text. Avoid markdown clutter, excessive asterisks, raw dividers (---), or repetitive bolding.
   - Use clean headings, clean bullet points, numbered steps, and syntax-highlighted code blocks where appropriate.''';
  }

  String _buildContextBlock(List<DocumentChunk> chunks) {
    return chunks.asMap().entries.map((e) {
      return '[Excerpt ${e.key + 1}]:\n${e.value.content}';
    }).join('\n\n');
  }
}
