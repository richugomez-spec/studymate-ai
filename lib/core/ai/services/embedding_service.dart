import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai_provider.dart';
import '../rag/chunker.dart';
import 'ai_provider_service.dart';

/// Service responsible for computing vector embeddings for document text chunks.
class EmbeddingService {
  final AIProvider? _provider;
  final Future<AIProvider> Function()? _providerResolver;

  EmbeddingService({
    AIProvider? provider,
    Future<AIProvider> Function()? providerResolver,
  })  : _provider = provider,
        _providerResolver = providerResolver;

  /// Generates an embedding vector for a single [DocumentChunk] or raw text chunk.
  /// Throws [ArgumentError] if the chunk text is empty.
  /// Handles provider failures and returns the float vector [List<double>].
  Future<List<double>> embedChunk(dynamic chunk) async {
    final String text;
    if (chunk is DocumentChunk) {
      text = chunk.content;
    } else if (chunk is String) {
      text = chunk;
    } else {
      throw ArgumentError('Expected DocumentChunk or String, got ${chunk.runtimeType}');
    }

    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Cannot generate embedding for an empty text chunk.');
    }

    try {
      final provider = _provider ?? await _providerResolver?.call();
      if (provider == null) {
        throw StateError('No active AI provider configured for generating embeddings.');
      }

      final embeddings = await provider.embed([trimmed]);
      if (embeddings.isEmpty || embeddings.first.isEmpty) {
        throw StateError('Embedding provider returned an empty vector for the given text.');
      }

      final vector = embeddings.first;

      // If chunk is a DocumentChunk, assign the vector to it directly
      if (chunk is DocumentChunk) {
        chunk.embedding = vector;
      }

      return vector;
    } catch (e, stackTrace) {
      debugPrint('EmbeddingService error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Batch generates embedding vectors for multiple chunks.
  Future<List<List<double>>> embedBatch(List<dynamic> chunks) async {
    if (chunks.isEmpty) return [];

    final texts = chunks.map((c) {
      if (c is DocumentChunk) return c.content.trim();
      if (c is String) return c.trim();
      throw ArgumentError('Expected DocumentChunk or String');
    }).where((t) => t.isNotEmpty).toList();

    if (texts.isEmpty) return [];

    try {
      final provider = _provider ?? await _providerResolver?.call();
      if (provider == null) {
        throw StateError('No active AI provider configured for generating embeddings.');
      }

      final vectors = await provider.embed(texts);

      // Assign to DocumentChunks if matching length
      int textIdx = 0;
      for (final c in chunks) {
        if (c is DocumentChunk && c.content.trim().isNotEmpty && textIdx < vectors.length) {
          c.embedding = vectors[textIdx++];
        }
      }

      return vectors;
    } catch (e, stackTrace) {
      debugPrint('EmbeddingService batch error: $e\n$stackTrace');
      rethrow;
    }
  }
}

/// Riverpod provider for [EmbeddingService] hooked to the active configured AI provider.
final embeddingServiceProvider = Provider<EmbeddingService>((ref) {
  return EmbeddingService(
    providerResolver: () => ref.read(activeAIProviderProvider.future),
  );
});
