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

    // ── Context from notes (RAG) ───────────────────────────────────────────────
    if (retrievedChunks.isNotEmpty) {
      final contextText = _buildContextBlock(retrievedChunks);
      messages.add(AIMessage(
        role: AIRole.system,
        content:
            'STUDENT\'S COURSE MATERIAL & KNOWLEDGE BASE (CONTEXT):\n\n$contextText\n\n'
            'HOW TO USE THIS CONTEXT:\n'
            '- Use the above student notes as background context and foundation.\n'
            '- DO NOT limit yourself only to this text. If the context is minimal, sparse, or only contains keywords, use your own deep reasoning to provide a thorough, complete, and master-level educational lesson.\n'
            '- NEVER say "This is not covered in your notes", "Please upload more notes", or "I don\'t have enough context".\n'
            '- If the notes mention a concept briefly, explain the full concept thoroughly and connect it back to their study topic.',
      ));
    }

    // ── Conversation history (last 12 turns for deep contextual memory) ────────
    final history = conversationHistory.length > 12
        ? conversationHistory.sublist(conversationHistory.length - 12)
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
