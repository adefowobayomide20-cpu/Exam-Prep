import '../../data/models/app_notification.dart';

class NewsArticle {
  const NewsArticle({
    required this.title,
    required this.source,
    required this.date,
    required this.summary,
    this.imageUrl,
    this.link,
    this.publishedAt,
  });

  final String title;
  final String source;
  final String date;
  final String summary;

  /// Thumbnail image URL, if the source provided one.
  final String? imageUrl;

  /// External URL to the full article, if available (used for "Read full
  /// article" since the API only gives us a short summary).
  final String? link;

  /// Raw publish timestamp, used to sort merged results from multiple API
  /// queries chronologically. Null for the bundled sample articles.
  final DateTime? publishedAt;

  factory NewsArticle.fromNewsDataJson(Map<String, dynamic> json) {
    final sourceId = json['source_id'] as String?;
    return NewsArticle(
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : 'Untitled',
      source: sourceId == null || sourceId.isEmpty
          ? 'Unknown source'
          : sourceId[0].toUpperCase() + sourceId.substring(1).replaceAll('-', ' '),
      date: _formatDate(json['pubDate'] as String?),
      summary: (json['description'] as String?)?.trim().isNotEmpty == true
          ? json['description'] as String
          : 'No summary available for this article.',
      imageUrl: json['image_url'] as String?,
      link: json['link'] as String?,
      publishedAt: DateTime.tryParse(json['pubDate'] as String? ?? ''),
    );
  }

  /// Rebuilds the full article from a persisted [AppNotification] (i.e. a
  /// news alert opened from the notification bell) using the same
  /// newsdata.io-shaped fields the notification carried.
  factory NewsArticle.fromAppNotification(AppNotification notification) {
    return NewsArticle.fromNewsDataJson({
      'title': notification.title,
      'source_id': notification.newsSourceId,
      'pubDate': notification.newsPubDate,
      'description': notification.newsDescription,
      'image_url': notification.newsImageUrl,
      'link': notification.link,
    });
  }

  static String _formatDate(String? pubDate) {
    if (pubDate == null) return '';
    final parsed = DateTime.tryParse(pubDate);
    if (parsed == null) return pubDate;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }
}

/// Bundled sample articles, shown when no API key is configured or the
/// live fetch fails, so the News tab never looks broken.
const sampleNewsArticles = [
  NewsArticle(
    title: 'JAMB releases 2026 UTME registration timetable',
    source: 'JAMB',
    date: 'Jun 18, 2026',
    summary:
        'The Joint Admissions and Matriculation Board has released the registration timetable '
        'for the 2026 Unified Tertiary Matriculation Examination, with registration opening '
        'next month and the examination expected to hold in April.',
  ),
  NewsArticle(
    title: 'WAEC announces new exam centres for May/June diet',
    source: 'WAEC',
    date: 'Jun 15, 2026',
    summary:
        'The West African Examinations Council has added new examination centres across '
        'several states ahead of the upcoming May/June West African Senior School Certificate '
        'Examination to ease overcrowding reported in previous diets.',
  ),
  NewsArticle(
    title: 'FG approves new minimum entry requirements for tertiary admission',
    source: 'Federal Ministry of Education',
    date: 'Jun 10, 2026',
    summary:
        'The Federal Government has approved updated minimum entry requirements for admission '
        'into universities, polytechnics, and colleges of education, effective from the next '
        'admission cycle.',
  ),
  NewsArticle(
    title: 'NECO to introduce computer-based testing for GCE candidates',
    source: 'NECO',
    date: 'Jun 6, 2026',
    summary:
        'The National Examinations Council has disclosed plans to pilot computer-based testing '
        'for selected subjects in the next General Certificate Examination, as part of efforts '
        'to modernise its assessment process.',
  ),
  NewsArticle(
    title: 'Post-JAMB screening dates announced for top federal universities',
    source: 'Campus Update',
    date: 'Jun 2, 2026',
    summary:
        'Several federal universities have released their post-JAMB screening dates and '
        'requirements for the 2026/2027 admission session, with most exercises scheduled to '
        'begin in August.',
  ),
  NewsArticle(
    title: 'ASUU threatens fresh strike over unpaid 2025 agreement',
    source: 'ASUU',
    date: 'May 29, 2026',
    summary:
        'The Academic Staff Union of Universities has issued a warning over the Federal '
        "Government's delay in implementing the 2025 agreement, threatening industrial action "
        'if outstanding issues are not resolved within weeks.',
  ),
  NewsArticle(
    title: 'Several state polytechnics begin sale of admission forms',
    source: 'Campus Update',
    date: 'May 24, 2026',
    summary:
        'A number of state-owned polytechnics have commenced the sale of admission forms for '
        'the 2026/2027 academic session, with application portals now open and deadlines set '
        'for the coming weeks.',
  ),
];
