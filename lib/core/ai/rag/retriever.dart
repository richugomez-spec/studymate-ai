import 'dart:math';

import '../ai_provider.dart';
import 'chunker.dart';

/// Intelligent RAG 2.0 retriever
///
/// Pipeline:
/// User Question
/// ↓
/// Semantic Search (Retrieve Top 8 Chunks)
/// ↓
/// Re-rank by relevance (semantic score + query term overlap)
/// ↓
/// Remove duplicate / overlapping chunks (Jaccard similarity threshold)
/// ↓
/// Merge related/contiguous chunks
/// ↓
/// Compress context (keep key factual sentences within token budget)
/// ↓
/// Gemini
class EmbeddingRetriever {
  final AIProvider provider;
  final int topK;
  final double similarityThreshold;
  final int initialK;

  const EmbeddingRetriever({
    required this.provider,
    this.topK = 5,
    this.initialK = 8,
    this.similarityThreshold = 0.50,
  });

  /// Retrieve, re-rank, deduplicate, merge, and compress chunks
  Future<List<DocumentChunk>> retrieve(
    String query,
    List<DocumentChunk> chunks, {
    int maxContextTokens = 1500,
  }) async {
    if (chunks.isEmpty) return [];

    // 1. Embed chunks that don't have embeddings yet
    final unembedded = chunks.where((c) => c.embedding == null).toList();
    if (unembedded.isNotEmpty) {
      final texts = unembedded.map((c) => c.content).toList();
      final embeddings = await provider.embed(texts);
      for (var i = 0; i < unembedded.length; i++) {
        unembedded[i].embedding = embeddings[i];
      }
    }

    // 2. Embed the query
    final queryEmbeddings = await provider.embed([query]);
    final queryVector = queryEmbeddings.first;

    // 3. Initial Semantic Search: Retrieve Top 8 Chunks
    final scored = chunks
        .where((c) => c.embedding != null)
        .map((c) {
          final cosine = _cosineSimilarity(queryVector, c.embedding!);
          final lexicalBonus = _lexicalMatchScore(query, c.content);
          // Combined relevance score (semantic dominant, lexical boosted)
          final finalScore = (cosine * 0.75) + (lexicalBonus * 0.25);
          return (chunk: c, score: finalScore, cosine: cosine);
        })
        .where((e) => e.cosine >= similarityThreshold)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    if (scored.isEmpty) return [];

    final candidateChunks = scored.take(initialK).map((e) => e.chunk).toList();

    // 4. Remove duplicate / heavily overlapping chunks
    final deduplicated = _removeDuplicates(candidateChunks);

    // 5. Merge related contiguous chunks & preserve document structure
    final merged = _mergeRelatedChunks(deduplicated);

    // 6. Compress context to keep important facts within token budget
    final compressed = _compressChunks(merged, query, maxTokens: maxContextTokens);

    return compressed.take(topK).toList();
  }

  /// Remove chunks that share > 60% word overlap with higher-ranking chunks
  List<DocumentChunk> _removeDuplicates(List<DocumentChunk> chunks) {
    final result = <DocumentChunk>[];
    for (final chunk in chunks) {
      final isDuplicate = result.any((existing) {
        return _textOverlapScore(existing.content, chunk.content) > 0.60;
      });
      if (!isDuplicate) {
        result.add(chunk);
      }
    }
    return result;
  }

  /// Merge adjacent chunks (ordered by chunkIndex) to maintain document flow
  List<DocumentChunk> _mergeRelatedChunks(List<DocumentChunk> chunks) {
    if (chunks.length <= 1) return chunks;

    // Sort by original chunkIndex to preserve document structure
    final ordered = List<DocumentChunk>.from(chunks)
      ..sort((a, b) => a.chunkIndex.compareTo(b.chunkIndex));

    final merged = <DocumentChunk>[];
    DocumentChunk? current;

    for (final next in ordered) {
      if (current == null) {
        current = next;
        continue;
      }

      // If adjacent chunks in document order, merge them
      if ((next.chunkIndex - current.chunkIndex).abs() <= 1) {
        final combinedContent = '${current.content}\n\n${next.content}'.trim();
        current = DocumentChunk(
          content: combinedContent,
          chunkIndex: current.chunkIndex,
          tokenCount: current.tokenCount + next.tokenCount,
          sourceId: current.sourceId,
          documentId: current.documentId,
          embedding: current.embedding,
        );
      } else {
        merged.add(current);
        current = next;
      }
    }

    if (current != null) {
      merged.add(current);
    }

    return merged;
  }

  /// Compress chunks by selecting query-relevant sentences to minimize token usage
  List<DocumentChunk> _compressChunks(
    List<DocumentChunk> chunks,
    String query, {
    required int maxTokens,
  }) {
    final queryTerms = query
        .toLowerCase()
        .split(RegExp(r'[^a-zA-Z0-9]+'))
        .where((t) => t.length > 2)
        .toSet();

    int totalEstimatedTokens = 0;
    final compressedChunks = <DocumentChunk>[];

    for (final chunk in chunks) {
      if (totalEstimatedTokens >= maxTokens) break;

      final sentences = chunk.content.split(RegExp(r'(?<=[.?!])\s+'));
      if (sentences.length <= 2) {
        compressedChunks.add(chunk);
        totalEstimatedTokens += chunk.tokenCount;
        continue;
      }

      // Score sentences by query term density and informative length
      final selectedSentences = <String>[];
      for (final s in sentences) {
        final clean = s.trim();
        if (clean.isEmpty) continue;
        final words = clean.toLowerCase().split(RegExp(r'[^a-zA-Z0-9]+'));
        final matches = words.where(queryTerms.contains).length;
        if (matches > 0 || sentences.length <= 3) {
          selectedSentences.add(clean);
        }
      }

      final compressedText = (selectedSentences.isNotEmpty
              ? selectedSentences.join(' ')
              : sentences.take(3).join(' '))
          .trim();

      final estTokens = (compressedText.split(RegExp(r'\s+')).length * 1.3).ceil();

      compressedChunks.add(DocumentChunk(
        content: compressedText,
        chunkIndex: chunk.chunkIndex,
        tokenCount: estTokens,
        sourceId: chunk.sourceId,
        documentId: chunk.documentId,
        embedding: chunk.embedding,
      ));

      totalEstimatedTokens += estTokens;
    }

    return compressedChunks.isNotEmpty ? compressedChunks : chunks;
  }

  /// Lexical term overlap ratio [0.0, 1.0]
  double _lexicalMatchScore(String query, String text) {
    final qWords = query
        .toLowerCase()
        .split(RegExp(r'[^a-zA-Z0-9]+'))
        .where((w) => w.length > 2)
        .toSet();
    if (qWords.isEmpty) return 0.0;
    final tWords = text
        .toLowerCase()
        .split(RegExp(r'[^a-zA-Z0-9]+'))
        .toSet();
    final overlap = qWords.intersection(tWords).length;
    return (overlap / qWords.length).clamp(0.0, 1.0);
  }

  /// Jaccard similarity for deduplication
  double _textOverlapScore(String a, String b) {
    final wordsA = a.toLowerCase().split(RegExp(r'\s+')).toSet();
    final wordsB = b.toLowerCase().split(RegExp(r'\s+')).toSet();
    if (wordsA.isEmpty || wordsB.isEmpty) return 0.0;
    final intersection = wordsA.intersection(wordsB).length;
    final union = wordsA.union(wordsB).length;
    return union == 0 ? 0.0 : intersection / union;
  }

  /// Cosine similarity between two equal-length vectors
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0;
    double dot = 0;
    double normA = 0;
    double normB = 0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    final denom = sqrt(normA) * sqrt(normB);
    return denom == 0 ? 0 : dot / denom;
  }
}
