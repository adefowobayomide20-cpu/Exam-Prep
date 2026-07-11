import 'package:flutter/material.dart';

import '../../data/news_store.dart';
import '../../widgets/slide_up_route.dart';
import 'news_detail_page.dart';
import 'news_service.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  void initState() {
    super.initState();
    NewsStore.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Education News')),
      body: ListenableBuilder(
        listenable: NewsStore.instance,
        builder: (context, _) {
          final store = NewsStore.instance;

          if (store.loading && store.articles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: store.refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (store.error is NewsApiKeyMissingException)
                  _InfoBanner(
                    icon: Icons.key_off_outlined,
                    message: 'Showing sample articles. Add a free newsdata.io API key in '
                        'lib/data/news_api_key.dart to pull in live education news.',
                  )
                else if (store.error != null)
                  _InfoBanner(
                    icon: Icons.wifi_off_outlined,
                    message: "Couldn't fetch live news, showing sample articles instead. "
                        'Pull down to try again.',
                  ),
                if (store.error != null) const SizedBox(height: 12),
                ...store.articles.map(
                  (article) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: article.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                article.imageUrl!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    Icon(Icons.newspaper, color: theme.colorScheme.primary),
                              ),
                            )
                          : Icon(Icons.newspaper, color: theme.colorScheme.primary),
                      title: Text(article.title),
                      subtitle: Text('${article.source} · ${article.date}'),
                      onTap: () {
                        Navigator.of(context).push(
                          SlideUpRoute(builder: (_) => NewsDetailPage(article: article)),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSecondaryContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
