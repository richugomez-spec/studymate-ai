import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai_provider.dart';
import '../rag/chunker.dart';
import '../rag/chroma_storage_service.dart';
import 'ai_provider_service.dart';

class EmbeddingProcessingResult {
  final int totalChunks;
  final int processedCount;
  final int skippedCount;
  final int failedCount;
  final bool chromaStored;
  final List<String> errors;

  const EmbeddingProcessingResult({
    required this.totalChunks,
    required this.processedCount,
    required this.skippedCount,
    required this.failedCount,
    required this.chromaStored,
    required this.errors,
  });

  bool get isSuccess => failedCount == 0 && chromaStored;
}

/// Service responsible for computing vector embeddings for document text chunks.
class EmbeddingService {
  final AIProvider? _provider;
  final Future<AIProvider> Function()? _providerResolver;
  final ChromaStorageService _chroma;

  EmbeddingService({
    AIProvider? provider,
    Future<AIProvider> Function()? providerResolver,
    ChromaStorageService? chromaStorageService,
  })  : _provider = provider,
        _providerResolver = providerResolver,
        _chroma = chromaStorageService ?? ChromaStorageService();

  /// Process chunks for a document:
  /// - Skips chunks that already have embeddings.
  /// - Associates every embedding with Document ID, Chunk ID, User ID, and Timestamp.
  /// - Retries API failures up to [maxRetries] per chunk without stopping the pipeline.
  /// - Returns success/failure status [EmbeddingProcessingResult] to DocumentProcessingService.
  Future<EmbeddingProcessingResult> processChunks(
    List<DocumentChunk> chunks, {
    required String documentId,
    required String userId,
    int maxRetries = 2,
  }) async {
    if (chunks.isEmpty) {
      return const EmbeddingProcessingResult(
        totalChunks: 0,
        processedCount: 0,
        skippedCount: 0,
        failedCount: 0,
        chromaStored: true,
        errors: [],
      );
    }

    int processed = 0;
    int skipped = 0;
    int failed = 0;
    final errors = <String>[];

    for (int i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];

      // Associate metadata
      chunk.documentId ??= documentId;
      chunk.chunkId ??= '${documentId}_chunk_${chunk.chunkIndex}';
      chunk.userId ??= userId;
      chunk.timestamp ??= DateTime.now();

      // Skip chunks that already have embeddings
      if (chunk.embedding != null && chunk.embedding!.isNotEmpty) {
        skipped++;
        continue;
      }

      final text = chunk.content.trim();
      if (text.isEmpty) {
        skipped++;
        continue;
      }

      bool success = false;
      for (int attempt = 0; attempt <= maxRetries; attempt++) {
        try {
          final vector = await embedChunk(text);
          chunk.embedding = vector;
          processed++;
          success = true;
          break;
        } catch (e) {
          if (attempt == maxRetries) {
            failed++;
            final err = 'Chunk ${chunk.chunkId} failed after $maxRetries retries: $e';
            errors.add(err);
            debugPrint(err);
          } else {
            await Future<void>.delayed(Duration(milliseconds: 300 * (attempt + 1)));
          }
        }
      }
      if (!success) {
        // Continue processing remaining chunks without stopping pipeline
      }
    }

    // Store all embedded chunks in ChromaDB
    bool chromaStored = true;
    if (processed > 0) {
      chromaStored = await _chroma.storeChunks(
        chunks: chunks,
        documentId: documentId,
        userId: userId,
      );
      if (!chromaStored) {
        errors.add('ChromaDB storage failed for document $documentId');
      }
    }

    return EmbeddingProcessingResult(
      totalChunks: chunks.length,
      processedCount: processed,
      skippedCount: skipped,
      failedCount: failed,
      chromaStored: chromaStored,
      errors: errors,
    );
  }

  /// Generates an embedding vector for a single [DocumentChunk] or raw text chunk.
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
