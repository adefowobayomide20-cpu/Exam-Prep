import 'package:flutter/material.dart';

import '../../../data/news_store.dart';

class LatestNewsSection extends StatefulWidget {
  const LatestNewsSection({super.key, this.onSeeAll});

  final VoidCallback? onSeeAll;

  @override
  State<LatestNewsSection> createState() => _LatestNewsSectionState();
}

class _LatestNewsSectionState extends State<LatestNewsSection> {
  @override
  void initState() {
    super.initState();
    NewsStore.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: NewsStore.instance,
      builder: (context, _) {
        final headlines = NewsStore.instance.articles.take(3);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Latest News Update', style: theme.textTheme.titleMedium),
                TextButton(onPressed: widget.onSeeAll, child: const Text('See all')),
              ],
            ),
            const SizedBox(height: 4),
            ...headlines.map(
              (article) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.newspaper, color: theme.colorScheme.primary),
                  title: Text(article.title),
                  subtitle: Text('${article.source} · ${article.date}'),
                  onTap: widget.onSeeAll,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
