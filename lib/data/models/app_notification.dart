enum NotificationType { news, reminder, system }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.link,
    this.read = false,
    this.newsSourceId,
    this.newsPubDate,
    this.newsDescription,
    this.newsImageUrl,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;

  /// External link to open on tap, if any (e.g. a news article).
  final String? link;
  final bool read;

  /// Raw newsdata.io-shaped fields carried alongside [NotificationType.news]
  /// notifications so [NewsArticle.fromAppNotification] (see
  /// features/news/news_article.dart) can rebuild the full article for
  /// in-app display instead of jumping straight to [link].
  final String? newsSourceId;
  final String? newsPubDate;
  final String? newsDescription;
  final String? newsImageUrl;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        link: link,
        read: read ?? this.read,
        newsSourceId: newsSourceId,
        newsPubDate: newsPubDate,
        newsDescription: newsDescription,
        newsImageUrl: newsImageUrl,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'link': link,
        'read': read,
        'sourceId': newsSourceId,
        'pubDate': newsPubDate,
        'description': newsDescription,
        'imageUrl': newsImageUrl,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        type: NotificationType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => NotificationType.system,
        ),
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        link: json['link'] as String?,
        read: json['read'] as bool? ?? false,
        newsSourceId: json['sourceId'] as String?,
        newsPubDate: json['pubDate'] as String?,
        newsDescription: json['description'] as String?,
        newsImageUrl: json['imageUrl'] as String?,
      );
}
