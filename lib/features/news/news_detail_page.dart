import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'news_article.dart';

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({super.key, required this.article});

  final NewsArticle article;

  Future<void> _openFullArticle(BuildContext context) async {
    final link = article.link;
    if (link == null) return;
    final launched = await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the article')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (article.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                article.imageUrl!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(article.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '${article.source} · ${article.date}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(article.summary, style: theme.textTheme.bodyLarge),
          if (article.link != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _openFullArticle(context),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Read Full Article'),
            ),
          ],
        ],
      ),
    );
  }
}
