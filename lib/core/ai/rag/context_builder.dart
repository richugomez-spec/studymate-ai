import '../models/hierarchical_document_model.dart';
import '../ai_message.dart';
import 'chunker.dart';

/// Builds the full AI prompt for an AI-First query.
///
/// Combines:
/// 1. System persona & teaching guidelines (ChatGPT / NotebookLM style)
/// 2. Hierarchical document intelligence across all chapters & pages
/// 3. Conversational multi-turn history with token compression
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
    HierarchicalDocumentModel? hierarchicalModel,
    String? topicName,
    String? subjectName,
    String? explanationStyle,
    List<String>? weakConcepts,
    String? webContext,
  }) {
    final messages = <AIMessage>[];

    messages.add(AIMessage(
      role: AIRole.system,
      content: _buildSystemPrompt(
        topicName: topicName,
        subjectName: subjectName,
        explanationStyle: explanationStyle ?? 'intermediate',
        weakConcepts: weakConcepts ?? [],
        hasNotes: hierarchicalModel != null,
        hasWeb: webContext != null && webContext.isNotEmpty,
      ),
    ));

    // ── Hierarchical Knowledge Base Grounding (AI-First) ──────────────────────
    if (hierarchicalModel != null) {
      messages.add(AIMessage(
        role: AIRole.system,
        content: hierarchicalModel.generateHolisticReasoningPrompt(),
      ));
    }

    if (webContext != null && webContext.isNotEmpty) {
      messages.add(AIMessage(
        role: AIRole.system,
        content: 'LIVE WEB (use when notes are incomplete or recency is required):\n$webContext',
      ));
    }

    if (retrievedChunks.isNotEmpty) {
      final topChunks = retrievedChunks.take(2).toList();
      final contextText = _buildContextBlock(topChunks);
      messages.add(AIMessage(
        role: AIRole.system,
        content:
            'CITATION EXCERPTS (supporting retrieval only, not the primary reasoning engine):\n\n$contextText\n\n'
            'Synthesize a tutor answer. Prefer structured knowledge + your own teaching knowledge. Cite excerpts only when quoting the student\'s notes.',
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
    bool hasNotes = false,
    bool hasWeb = false,
  }) {
    final contextSection = [
      if (subjectName != null && subjectName.isNotEmpty) 'Subject: $subjectName',
      if (topicName != null && topicName.isNotEmpty) 'Current Topic: $topicName',
    ].join(' | ');

    final weakSection = weakConcepts.isNotEmpty
        ? '\nStudent weak areas: ${weakConcepts.join(', ')}. Pay special attention to intuitive clarity on these topics.'
        : '';

    return '''You are StudyMate AI, an elite educational tutor and personal professor.
Teach any topic. Notes personalize you; if notes are missing, teach from your own knowledge.
Sources in priority order: (1) uploaded notes (2) your knowledge (3) live web if provided (4) conversation (5) course structure.
${hasNotes ? 'Personal notes are attached — synthesize them; do not copy chunks.' : 'No notes attached — teach fully from built-in knowledge.'}
${hasWeb ? 'Live web results are attached for current information.' : ''}

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
