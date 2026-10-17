import 'package:flutter_test/flutter_test.dart';
import 'package:studymate_ai/core/ai/ai_message.dart';
import 'package:studymate_ai/core/ai/ai_provider.dart';
import 'package:studymate_ai/core/ai/rag/chunker.dart';
import 'package:studymate_ai/core/ai/services/embedding_service.dart';

class MockAIProvider implements AIProvider {
  final bool shouldFail;
  final List<double> mockVector;

  MockAIProvider({
    this.shouldFail = false,
    this.mockVector = const [0.12, 0.45, -0.67, 0.89],
  });

  @override
  String get name => 'MockAIProvider';

  @override
  bool get supportsStreaming => false;

  @override
  bool get supportsVision => false;

  @override
  bool get isOfflineCapable => true;

  @override
  Future<AIResponse> complete(AIRequest request) async {
    return const AIResponse(
      content: 'test',
      model: 'mock',
      promptTokens: 1,
      completionTokens: 1,
    );
  }

  @override
  Stream<String> stream(AIRequest request) async* {
    yield 'test';
  }

  @override
  Future<List<List<double>>> embed(List<String> texts) async {
    if (shouldFail) {
      throw Exception('Network provider timeout or rate limit');
    }
    return texts.map((_) => mockVector).toList();
  }

  @override
  Future<bool> validate() async => !shouldFail;
}

void main() {
  group('EmbeddingService Unit Tests', () {
    late EmbeddingService service;
    late MockAIProvider mockProvider;

    setUp(() {
      mockProvider = MockAIProvider();
      service = EmbeddingService(provider: mockProvider);
    });

    test('1. Accepts a String text chunk and returns embedding vector', () async {
      final text = 'Photosynthesis converts light into chemical energy.';
      final vector = await service.embedChunk(text);

      expect(vector, isNotEmpty);
      expect(vector, equals([0.12, 0.45, -0.67, 0.89]));
    });

    test('2. Accepts a DocumentChunk and assigns embedding vector to it', () async {
      final docChunk = DocumentChunk(
        content: 'Cellular respiration releases stored energy.',
        chunkIndex: 0,
        tokenCount: 8,
      );

      final vector = await service.embedChunk(docChunk);

      expect(vector, equals([0.12, 0.45, -0.67, 0.89]));
      expect(docChunk.embedding, equals(vector));
    });

    test('3. Throws ArgumentError when chunk is empty whitespace', () async {
      expect(
        () => service.embedChunk('   \n  '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('4. Proper error handling when provider fails', () async {
      final failingService = EmbeddingService(
        provider: MockAIProvider(shouldFail: true),
      );

      expect(
        () => failingService.embedChunk('Valid input text'),
        throwsA(isA<Exception>()),
      );
    });

    test('5. Batch embedding processes multiple chunks', () async {
      final chunks = [
        'First paragraph content',
        'Second paragraph content',
      ];

      final vectors = await service.embedBatch(chunks);

      expect(vectors.length, equals(2));
      expect(vectors.first, equals([0.12, 0.45, -0.67, 0.89]));
      expect(vectors.last, equals([0.12, 0.45, -0.67, 0.89]));
    });

    test('6. processChunks associates metadata, skips existing embeddings, and returns status', () async {
      final chunk1 = DocumentChunk(
        content: 'Chunk 1 text',
        chunkIndex: 0,
        tokenCount: 10,
      );
      final chunk2 = DocumentChunk(
        content: 'Chunk 2 text',
        chunkIndex: 1,
        tokenCount: 10,
        embedding: [0.99, 0.99], // already has embedding
      );

      final result = await service.processChunks(
        [chunk1, chunk2],
        documentId: 'doc_123',
        userId: 'user_456',
      );

      expect(result.totalChunks, equals(2));
      expect(result.processedCount, equals(1));
      expect(result.skippedCount, equals(1));
      expect(result.failedCount, equals(0));
      expect(result.isSuccess, isTrue);

      // Check metadata association
      expect(chunk1.documentId, equals('doc_123'));
      expect(chunk1.chunkId, equals('doc_123_chunk_0'));
      expect(chunk1.userId, equals('user_456'));
      expect(chunk1.timestamp, isNotNull);
      expect(chunk1.embedding, equals([0.12, 0.45, -0.67, 0.89]));

      // Verify existing embedding was not overwritten
      expect(chunk2.embedding, equals([0.99, 0.99]));
    });
  });
}
