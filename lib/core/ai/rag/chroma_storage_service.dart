import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'chunker.dart';

/// ChromaDB REST client for storing and managing embedding vectors.
/// Collection naming: one collection per user → `studymate_<userId>`.
class ChromaStorageService {
  final String baseUrl;
  final http.Client _client;

  ChromaStorageService({
    this.baseUrl = 'http://localhost:8000',
    http.Client? client,
  }) : _client = client ?? http.Client();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Store embeddings for all chunks of [documentId].
  /// Skips chunks without an embedding vector.
  /// Returns true if all eligible chunks were stored successfully.
  Future<bool> storeChunks({
    required List<DocumentChunk> chunks,
    required String documentId,
    required String userId,
  }) async {
    if (chunks.isEmpty) return true;

    final eligible = chunks
        .where((c) => c.embedding != null && c.embedding!.isNotEmpty)
        .toList();
    if (eligible.isEmpty) return true;

    final collectionId = await _ensureCollection(userId);
    if (collectionId == null) return false;

    final existingIds = await _existingIds(collectionId, eligible);

    final ids = <String>[];
    final embeddings = <List<double>>[];
    final documents = <String>[];
    final metadatas = <Map<String, dynamic>>[];

    for (final chunk in eligible) {
      final id = chunk.chunkId ?? '${documentId}_chunk_${chunk.chunkIndex}';
      if (existingIds.contains(id)) continue;

      ids.add(id);
      embeddings.add(chunk.embedding!);
      documents.add(chunk.content);
      metadatas.add({
        'documentId': documentId,
        'chunkId': id,
        'userId': userId,
        'chunkIndex': chunk.chunkIndex,
        'tokenCount': chunk.tokenCount,
        'timestamp': (chunk.timestamp ?? DateTime.now()).toIso8601String(),
      });
    }

    if (ids.isEmpty) return true;

    return _addItems(collectionId, ids, embeddings, documents, metadatas);
  }

  /// Delete all vectors associated with [documentId] for [userId].
  Future<bool> deleteDocument({
    required String documentId,
    required String userId,
  }) async {
    final collectionId = await _getCollectionId(userId);
    if (collectionId == null) return true;

    try {
      final url = Uri.parse('$baseUrl/api/v1/collections/$collectionId/delete');
      final resp = await _client.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({
          'where': {'documentId': documentId},
        }),
      );
      if (resp.statusCode == 200) return true;
      debugPrint('ChromaDB delete failed [${resp.statusCode}]: ${resp.body}');
      return false;
    } catch (e) {
      debugPrint('ChromaDB deleteDocument error: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  String _collectionName(String userId) => 'studymate_$userId';

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<String?> _ensureCollection(String userId) async {
    final existing = await _getCollectionId(userId);
    if (existing != null) return existing;
    return _createCollection(userId);
  }

  Future<String?> _getCollectionId(String userId) async {
    try {
      final name = _collectionName(userId);
      final url = Uri.parse('$baseUrl/api/v1/collections/$name');
      final resp = await _client.get(url, headers: _jsonHeaders);
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        return body['id'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('ChromaDB getCollection error: $e');
      return null;
    }
  }

  Future<String?> _createCollection(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/collections');
      final resp = await _client.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': _collectionName(userId),
          'metadata': {'hnsw:space': 'cosine'},
          'get_or_create': true,
        }),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        return body['id'] as String?;
      }
      debugPrint(
          'ChromaDB createCollection failed [${resp.statusCode}]: ${resp.body}');
      return null;
    } catch (e) {
      debugPrint('ChromaDB createCollection error: $e');
      return null;
    }
  }

  Future<Set<String>> _existingIds(
      String collectionId, List<DocumentChunk> chunks) async {
    try {
      final ids = chunks
          .map((c) => c.chunkId ?? '${c.documentId}_chunk_${c.chunkIndex}')
          .toList();
      final url =
          Uri.parse('$baseUrl/api/v1/collections/$collectionId/get');
      final resp = await _client.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({'ids': ids, 'include': []}),
      );
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final existing = (body['ids'] as List?)?.cast<String>() ?? [];
        return existing.toSet();
      }
      return {};
    } catch (e) {
      debugPrint('ChromaDB existingIds error: $e');
      return {};
    }
  }

  Future<bool> _addItems(
    String collectionId,
    List<String> ids,
    List<List<double>> embeddings,
    List<String> documents,
    List<Map<String, dynamic>> metadatas,
  ) async {
    try {
      final url =
          Uri.parse('$baseUrl/api/v1/collections/$collectionId/add');
      final resp = await _client.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({
          'ids': ids,
          'embeddings': embeddings,
          'documents': documents,
          'metadatas': metadatas,
        }),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) return true;
      debugPrint('ChromaDB add failed [${resp.statusCode}]: ${resp.body}');
      return false;
    } catch (e) {
      debugPrint('ChromaDB addItems error: $e');
      return false;
    }
  }
}
