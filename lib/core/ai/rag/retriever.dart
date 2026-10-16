import 'dart:math';

import '../ai_provider.dart';
import 'chunker.dart';

/// Retrieves the most semantically relevant chunks for a query
/// using cosine similarity on embedding vectors.
class EmbeddingRetriever {
  final AIProvider provider;
  final int topK;
  final double similarityThreshold;

  const EmbeddingRetriever({
    required this.provider,
    this.topK = 5,
    this.similarityThreshold = 0.6,
  });

  /// Embed a query and find the top-K most relevant chunks
  Future<List<DocumentChunk>> retrieve(
    String query,
    List<DocumentChunk> chunks,
  ) async {
    if (chunks.isEmpty) return [];

    // Embed chunks that don't have embeddings yet
    final unembedded = chunks.where((c) => c.embedding == null).toList();
    if (unembedded.isNotEmpty) {
      final texts = unembedded.map((c) => c.content).toList();
      final embeddings = await provider.embed(texts);
      for (var i = 0; i < unembedded.length; i++) {
        unembedded[i].embedding = embeddings[i];
      }
    }

    // Embed the query
    final queryEmbeddings = await provider.embed([query]);
    final queryVector = queryEmbeddings.first;

    // Score all chunks
    final scored = chunks
        .where((c) => c.embedding != null)
        .map((c) => (
              chunk: c,
              score: _cosineSimilarity(queryVector, c.embedding!),
            ))
        .where((e) => e.score >= similarityThreshold)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return scored.take(topK).map((e) => e.chunk).toList();
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
