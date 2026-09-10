import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/premium_service.dart';
import 'ads/rewarded_ad.dart';

/// Shown when a student hits today's free AI-help limit (Snap & Solve /
/// Theory), or from a "Go Premium" entry point in Settings.
class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  bool _subscribing = false;
  bool _watchingAd = false;
  String? _error;

  Future<void> _subscribe() async {
    setState(() {
      _subscribing = true;
      _error = null;
    });
    try {
      final url = await PremiumService.instance.initializePayment();
      final launched = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        setState(() => _error = 'Could not open the checkout page.');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not start checkout. Try again shortly.');
    } finally {
      if (mounted) setState(() => _subscribing = false);
    }
  }

  Future<void> _watchAd() async {
    setState(() {
      _watchingAd = true;
      _error = null;
    });
    try {
      final earned = await RewardedAdController.instance.show();
      if (!mounted) return;
      if (earned) {
        await PremiumService.instance.claimRewardedAdBonus();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('+1 free AI help added for today!')),
        );
        Navigator.of(context).pop();
      } else {
        setState(() => _error = "Ad wasn't completed — no bonus added.");
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load an ad right now. Try again shortly.');
    } finally {
      if (mounted) setState(() => _watchingAd = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Go Premium')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.workspace_premium, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Exam Coach Premium',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                "You've used today's free AI helps (Snap & Solve and Theory). "
                'Go Premium for unlimited access, or watch a short ad for one more today.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _Benefit(text: 'Unlimited Snap & Solve and Theory help'),
                      _Benefit(text: 'No ads'),
                      _Benefit(text: 'Support Exam Coach'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                const SizedBox(height: 12),
              ],
              FilledButton(
                onPressed: _subscribing ? null : _subscribe,
                child: _subscribing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Subscribe — ₦700/month'),
              ),
              if (!kIsWeb) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _watchingAd ? null : _watchAd,
                  child: _watchingAd
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Watch an ad for one more today'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
