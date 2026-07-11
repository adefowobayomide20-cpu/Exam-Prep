import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../data/news_api_key.dart';
import 'news_article.dart';

/// Thrown when [newsDataApiKey] hasn't been set yet.
class NewsApiKeyMissingException implements Exception {}

/// Fetches real news for Nigerian students from newsdata.io, targeted at
/// WAEC, NECO, GCE, JAMB, Post-JAMB, tertiary admission, ASUU/ASUP strikes,
/// and scholarships/bursaries.
class NewsService {
  NewsService._();

  static const _endpoint = 'https://newsdata.io/api/1/latest';

  // Matching against the title only (qInTitle) instead of full body text
  // (q) is much more precise for a niche topic like this — searching body
  // text pulls in unrelated articles that merely mention "university" or
  // "strike" in passing. Free-tier search is capped at 100 characters per
  // query, so topics are split across three separate searches and merged
  // below. "NYSC" and "resumption date" were tried and dropped: NYSC is
  // currently swamped by an unrelated uniform-controversy story, and
  // "resumption date" mostly matched football pre-season training news.
  static const _examKeywords =
      'WAEC OR NECO OR JAMB OR GCE OR "Post-JAMB" OR "Post-UTME" OR admission';
  static const _campusKeywords =
      'ASUU OR ASUP OR "school fees" OR "admission form" OR "cut-off mark"';
  static const _fundingKeywords = 'scholarship OR bursary OR "admission list" OR CAPS';

  static Future<List<NewsArticle>> fetchEducationNews() async {
    if (newsDataApiKey.isEmpty) {
      throw NewsApiKeyMissingException();
    }

    final results = await Future.wait([
      _fetch({'qInTitle': _examKeywords}),
      _fetch({'qInTitle': _campusKeywords}),
      _fetch({'qInTitle': _fundingKeywords}),
    ]);
    final merged = _dedupeAndSort([...results[0], ...results[1], ...results[2]]);
    if (merged.isNotEmpty) return merged;

    // Both keyword searches can come back empty if nothing matched in the
    // free tier's 12h-delayed window; fall back to the broader education
    // category so the tab still has something relevant to show.
    return _fetch({'category': 'education'});
  }

  static List<NewsArticle> _dedupeAndSort(List<NewsArticle> articles) {
    final seen = <String>{};
    final deduped = articles.where((a) => seen.add(a.link ?? a.title)).toList();
    deduped.sort((a, b) {
      if (a.publishedAt == null || b.publishedAt == null) return 0;
      return b.publishedAt!.compareTo(a.publishedAt!);
    });
    return deduped;
  }

  static Future<List<NewsArticle>> _fetch(Map<String, String> extraParams) async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'apikey': newsDataApiKey,
      'country': 'ng',
      'language': 'en',
      ...extraParams,
    });

    final response = await http.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['status'] != 'success') {
      final message = body['results'] is Map
          ? (body['results'] as Map)['message']
          : body['message'];
      throw Exception(message ?? 'Failed to load news (HTTP ${response.statusCode})');
    }

    final results = (body['results'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    return results.map(NewsArticle.fromNewsDataJson).toList();
  }
}
