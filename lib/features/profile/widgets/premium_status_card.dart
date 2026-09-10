import 'package:flutter/material.dart';

import '../../../data/models/ai_usage.dart';
import '../../../data/models/premium_status.dart';
import '../../../widgets/slide_up_route.dart';
import '../../premium/paywall_page.dart';

const _freeDailyAiActions = 3;

/// Shows the student's current plan: Premium (with expiry) or free plan
/// (with today's remaining AI-help count), matching the free limit enforced
/// server-side in functions/entitlements.js.
class PremiumStatusCard extends StatelessWidget {
  const PremiumStatusCard({super.key, required this.premium, required this.aiUsage});

  final PremiumStatus premium;
  final AiUsage aiUsage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = premium.active;
    final expiresAt = premium.expiresAt;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Icon(
          active ? Icons.workspace_premium : Icons.workspace_premium_outlined,
          color: active ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(active ? 'Premium' : 'Free plan'),
        subtitle: Text(
          active
              ? (expiresAt != null
                  ? 'Active until ${_formatDate(expiresAt)}'
                  : 'Unlimited Snap & Solve and Theory help')
              : '${_freeDailyAiActions - aiUsage.countToday}/$_freeDailyAiActions '
                  'AI helps left today',
        ),
        trailing: active
            ? null
            : FilledButton(
                onPressed: () => Navigator.of(context).push(
                  SlideUpRoute(builder: (_) => const PaywallPage()),
                ),
                child: const Text('Go Premium'),
              ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
