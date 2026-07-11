import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/app_notification.dart';
import '../../data/notification_store.dart';
import '../../widgets/slide_up_route.dart';
import '../news/news_article.dart';
import '../news/news_detail_page.dart';

class NotificationCenterPage extends StatelessWidget {
  const NotificationCenterPage({super.key});

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.news:
        return Icons.newspaper;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  Future<void> _onTap(BuildContext context, AppNotification notification) async {
    if (!notification.read) {
      NotificationStore.instance.markRead(notification.id);
    }
    if (notification.type == NotificationType.news) {
      Navigator.of(context).push(
        SlideUpRoute(
          builder: (_) => NewsDetailPage(article: NewsArticle.fromAppNotification(notification)),
        ),
      );
      return;
    }
    final link = notification.link;
    if (link != null && link.isNotEmpty) {
      final launched = await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          ListenableBuilder(
            listenable: NotificationStore.instance,
            builder: (context, _) => NotificationStore.instance.unreadCount > 0
                ? TextButton(
                    onPressed: NotificationStore.instance.markAllRead,
                    child: const Text('Mark all read'),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: NotificationStore.instance,
        builder: (context, _) {
          final notifications = NotificationStore.instance.notifications;
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                color: notification.read
                    ? null
                    : theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Icon(_iconFor(notification.type), color: theme.colorScheme.primary),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.read ? FontWeight.normal : FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(notification.body),
                  onTap: () => _onTap(context, notification),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
