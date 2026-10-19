import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class WebSearchHit {
  final String title;
  final String snippet;
  final String url;
  final String source;

  const WebSearchHit({
    required this.title,
    required this.snippet,
    required this.url,
    required this.source,
  });

  String toPromptLine() => '- $title ($source): $snippet${url.isNotEmpty ? ' [$url]' : ''}';
}

/// Live web lookup used only when the tutor needs current or missing information.
class WebSearchService {
  static const _recency = [
    'latest',
    'today',
    'current',
    'news',
    'recent',
    'update',
    'updated',
    'this year',
    'this month',
    '2024',
    '2025',
    '2026',
    'now',
    'breaking',
    'published',
    'research paper',
  ];

  bool needsLiveWeb(String query) {
    final q = query.toLowerCase();
    return _recency.any(q.contains);
  }

  Future<List<WebSearchHit>> search(String query, {int limit = 5}) async {
    final hits = <WebSearchHit>[];
    try {
      hits.addAll(await _duckDuckGo(query));
    } catch (_) {}
    if (hits.length < 2) {
      try {
        hits.addAll(await _wikipedia(query));
      } catch (_) {}
    }
    return hits.take(limit).toList();
  }

  Future<List<WebSearchHit>> _duckDuckGo(String query) async {
    final uri = Uri.parse(
      'https://api.duckduckgo.com/?q=${Uri.encodeQueryComponent(query)}&format=json&no_html=1&skip_disambig=1',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return const [];
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final hits = <WebSearchHit>[];

    final abstract = (json['AbstractText'] as String?) ?? '';
    final heading = (json['Heading'] as String?) ?? query;
    final abstractUrl = (json['AbstractURL'] as String?) ?? '';
    if (abstract.trim().isNotEmpty) {
      hits.add(WebSearchHit(
        title: heading,
        snippet: abstract.trim(),
        url: abstractUrl,
        source: 'DuckDuckGo',
      ));
    }

    final related = json['RelatedTopics'] as List? ?? [];
    for (final item in related.take(4)) {
      if (item is! Map) continue;
      final text = (item['Text'] as String?) ?? '';
      final url = (item['FirstURL'] as String?) ?? '';
      if (text.isEmpty) continue;
      hits.add(WebSearchHit(
        title: text.split(' - ').first,
        snippet: text,
        url: url,
        source: 'DuckDuckGo',
      ));
    }
    return hits;
  }

  Future<List<WebSearchHit>> _wikipedia(String query) async {
    final searchUri = Uri.parse(
      'https://en.wikipedia.org/w/api.php?action=opensearch&search=${Uri.encodeQueryComponent(query)}&limit=3&namespace=0&format=json',
    );
    final searchRes = await http.get(searchUri, headers: {
      'User-Agent': 'StudyMateAI/1.0 (educational)',
    }).timeout(const Duration(seconds: 8));
    if (searchRes.statusCode != 200) return const [];
    final data = jsonDecode(searchRes.body) as List;
    if (data.length < 4) return const [];
    final titles = List<String>.from(data[1] as List);
    final snippets = List<String>.from(data[2] as List);
    final urls = List<String>.from(data[3] as List);
    final hits = <WebSearchHit>[];
    for (var i = 0; i < titles.length; i++) {
      hits.add(WebSearchHit(
        title: titles[i],
        snippet: i < snippets.length && snippets[i].isNotEmpty ? snippets[i] : 'Wikipedia article: ${titles[i]}',
        url: i < urls.length ? urls[i] : '',
        source: 'Wikipedia',
      ));
    }
    return hits;
  }
}

final webSearchServiceProvider = Provider<WebSearchService>((ref) {
  return WebSearchService();
});
