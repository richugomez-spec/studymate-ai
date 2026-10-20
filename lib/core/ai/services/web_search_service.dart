import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class WebSearchService {
  const WebSearchService({http.Client? client}) : _client = client;
  final http.Client? _client;

  /// Uses Google Programmable Search when credentials are configured.
  Future<List<Map<String, String>>> search(String query,
      {int limit = 5}) async {
    const apiKey = String.fromEnvironment('GOOGLE_CSE_API_KEY');
    const engineId = String.fromEnvironment('GOOGLE_CSE_ENGINE_ID');
    if (apiKey.isEmpty || engineId.isEmpty) {
      return _searchDuckDuckGo(query, limit);
    }
    final uri = Uri.https('www.googleapis.com', '/customsearch/v1', {
      'key': apiKey,
      'cx': engineId,
      'q': query,
      'num': '${limit.clamp(1, 10)}',
    });
    final client = _client;
    final response = await (client == null ? http.get(uri) : client.get(uri))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw StateError('Web search returned ${response.statusCode}.');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List? ?? const [];
    return items
        .whereType<Map>()
        .map((item) => {
              'title': (item['title'] ?? '').toString(),
              'url': (item['link'] ?? '').toString(),
              'snippet': (item['snippet'] ?? '').toString(),
            })
        .toList();
  }

  Future<List<Map<String, String>>> _searchDuckDuckGo(
      String query, int limit) async {
    final uri = Uri.https('api.duckduckgo.com', '/', {
      'q': query,
      'format': 'json',
      'no_html': '1',
      'skip_disambig': '1',
    });
    final client = _client;
    final response = await (client == null ? http.get(uri) : client.get(uri))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw StateError('Web search returned ${response.statusCode}.');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = <Map<String, String>>[];
    final answer = (data['AbstractText'] ?? '').toString();
    if (answer.isNotEmpty) {
      results.add({
        'title': (data['Heading'] ?? 'Web result').toString(),
        'url': (data['AbstractURL'] ?? '').toString(),
        'snippet': answer
      });
    }
    void collect(dynamic entries) {
      if (entries is! List || results.length >= limit) return;
      for (final entry in entries) {
        if (entry is! Map) continue;
        if (entry['Topics'] is List) {
          collect(entry['Topics']);
          continue;
        }
        final text = (entry['Text'] ?? '').toString();
        if (text.isNotEmpty) {
          results.add({
            'title': text,
            'url': (entry['FirstURL'] ?? '').toString(),
            'snippet': text
          });
        }
        if (results.length >= limit) break;
      }
    }

    collect(data['RelatedTopics']);
    return results.take(limit).toList();
  }
}

final webSearchServiceProvider =
    Provider<WebSearchService>((ref) => const WebSearchService());
