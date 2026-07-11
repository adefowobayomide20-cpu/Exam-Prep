import 'package:flutter/material.dart';

import '../features/news/news_article.dart';
import '../features/news/news_service.dart';

/// Caches the live education-news fetch in memory so both the Home preview
/// and the News tab share a single request instead of hitting the (rate
/// limited) API independently. Falls back to [sampleNewsArticles] if no API
/// key is configured or the request fails.
class NewsStore extends ChangeNotifier {
  NewsStore._();

  static final NewsStore instance = NewsStore._();

  List<NewsArticle> _articles = sampleNewsArticles;
  bool _loading = false;
  Object? _error;
  bool _loadedOnce = false;

  List<NewsArticle> get articles => _articles;
  bool get loading => _loading;
  Object? get error => _error;

  /// True while showing the bundled sample articles rather than live data.
  bool get usingSampleData => _error != null || !_loadedOnce;

  /// Fetches once; safe to call from every screen that needs news, only the
  /// first call does any work.
  Future<void> ensureLoaded() {
    if (_loadedOnce || _loading) return Future.value();
    return refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final fetched = await NewsService.fetchEducationNews();
      _articles = fetched.isEmpty ? sampleNewsArticles : fetched;
      _loadedOnce = true;
    } catch (e) {
      _error = e;
      _articles = sampleNewsArticles;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
