import 'package:flutter/material.dart';

class InviteFriendCard extends StatelessWidget {
  const InviteFriendCard({super.key, this.onInvite});

  final VoidCallback? onInvite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.sports_kabaddi, color: theme.colorScheme.onSecondaryContainer, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite a friend to a Duel Quiz',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Challenge a friend and see who scores higher',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: onInvite,
              child: const Text('Invite'),
            ),
          ],
        ),
      ),
    );
  }
}
