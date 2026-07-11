import 'package:flutter/material.dart';

import '../../data/app_data_store.dart';
import '../../widgets/slide_up_route.dart';
import 'duel_create_page.dart';
import 'duel_join_page.dart';
import 'lobby/school_lobby_page.dart';

/// Entry point for the duel feature: start a new duel or join one with a
/// code a friend shared.
class DuelHubPage extends StatelessWidget {
  const DuelHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Duel a Friend')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sports_kabaddi, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Challenge a friend to a quiz duel',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Same questions, same clock — whoever scores higher wins.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    SlideUpRoute(
                      builder: (_) => SchoolLobbyPage(
                        initialSchool: AppDataStore.instance.profile.school,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.groups_outlined),
                  label: const Text('Find an Opponent'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    SlideUpRoute(builder: (_) => const DuelCreatePage()),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Start a New Duel'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    SlideUpRoute(builder: (_) => const DuelJoinPage()),
                  ),
                  icon: const Icon(Icons.login),
                  label: const Text('Join with a Code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
