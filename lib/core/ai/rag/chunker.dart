/// Splits a document into overlapping chunks suitable for RAG retrieval.
///
/// Strategy:
/// - Sentence-aware splitting to avoid cutting mid-sentence
/// - 512-token target with 50-token overlap
/// - Minimum chunk size of 100 tokens to avoid noise
class DocumentChunker {
  final int targetTokens;
  final int overlapTokens;
  final int minTokens;

  const DocumentChunker({
    this.targetTokens = 512,
    this.overlapTokens = 50,
    this.minTokens = 100,
  });

  /// Rough token count estimate (1 token ≈ 4 chars for English text)
  int _estimateTokens(String text) => (text.length / 4).ceil();

  /// Split text into semantically meaningful chunks
  List<DocumentChunk> chunk(String text, {String? sourceId}) {
    if (text.trim().isEmpty) return [];

    // Normalize whitespace
    final normalized = text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

    // Split into paragraphs first
    final paragraphs = normalized
        .split(RegExp(r'\n\n+'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    final chunks = <DocumentChunk>[];
    final buffer = StringBuffer();
    int bufferTokens = 0;
    int chunkIndex = 0;

    for (final paragraph in paragraphs) {
      final paraTokens = _estimateTokens(paragraph);

      // If paragraph alone exceeds target, split by sentences
      if (paraTokens > targetTokens) {
        if (buffer.isNotEmpty) {
          chunks.add(_makeChunk(buffer.toString(), chunkIndex++, sourceId));
          buffer.clear();
          bufferTokens = 0;
        }
        chunks.addAll(_chunkBySentence(paragraph, chunkIndex, sourceId));
        chunkIndex += chunks.length;
        continue;
      }

      // If adding this paragraph would exceed target, flush buffer first
      if (bufferTokens + paraTokens > targetTokens && bufferTokens >= minTokens) {
        chunks.add(_makeChunk(buffer.toString(), chunkIndex++, sourceId));

        // Keep overlap: last N tokens of previous chunk
        final overlapText = _extractLastTokens(buffer.toString(), overlapTokens);
        buffer.clear();
        buffer.write(overlapText);
        bufferTokens = _estimateTokens(overlapText);
      }

      buffer.write(buffer.isEmpty ? paragraph : '\n\n$paragraph');
      bufferTokens += paraTokens;
    }

    // Flush remaining
    if (buffer.isNotEmpty && bufferTokens >= minTokens) {
      chunks.add(_makeChunk(buffer.toString(), chunkIndex, sourceId));
    }

    return chunks;
  }

  List<DocumentChunk> _chunkBySentence(
      String text, int startIndex, String? sourceId) {
    final sentences = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final chunks = <DocumentChunk>[];
    final buffer = StringBuffer();
    int bufferTokens = 0;
    int idx = startIndex;

    for (final sentence in sentences) {
      final sentTokens = _estimateTokens(sentence);
      if (bufferTokens + sentTokens > targetTokens && bufferTokens >= minTokens) {
        chunks.add(_makeChunk(buffer.toString(), idx++, sourceId));
        final overlap = _extractLastTokens(buffer.toString(), overlapTokens);
        buffer.clear();
        buffer.write(overlap);
        bufferTokens = _estimateTokens(overlap);
      }
      buffer.write(buffer.isEmpty ? sentence : ' $sentence');
      bufferTokens += sentTokens;
    }

    if (buffer.isNotEmpty) {
      chunks.add(_makeChunk(buffer.toString(), idx, sourceId));
    }

    return chunks;
  }

  DocumentChunk _makeChunk(String content, int index, String? sourceId) {
    return DocumentChunk(
      content: content.trim(),
      chunkIndex: index,
      tokenCount: _estimateTokens(content),
      sourceId: sourceId,
    );
  }

  String _extractLastTokens(String text, int tokenCount) {
    final charCount = tokenCount * 4;
    if (text.length <= charCount) return text;
    return text.substring(text.length - charCount);
  }
}

/// A single semantic chunk from a document
class DocumentChunk {
  final String content;
  final int chunkIndex;
  final int tokenCount;
  final String? sourceId;
  List<double>? embedding;

  DocumentChunk({
    required this.content,
    required this.chunkIndex,
    required this.tokenCount,
    this.sourceId,
    this.embedding,
  });
}
