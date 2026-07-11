import 'package:flutter/material.dart';

import '../../data/app_data_store.dart';
import '../../data/auth_service.dart';
import '../../data/duel_service.dart';
import '../../widgets/slide_up_route.dart';
import 'duel_session_page.dart';

class DuelJoinPage extends StatefulWidget {
  const DuelJoinPage({super.key, this.initialCode});

  /// Pre-fills the code and immediately attempts to join, used when the
  /// page was opened from a shared duel link (e.g. examcoach.com.ng/duel/CODE)
  /// rather than manual entry.
  final String? initialCode;

  @override
  State<DuelJoinPage> createState() => _DuelJoinPageState();
}

class _DuelJoinPageState extends State<DuelJoinPage> {
  late final _codeController = TextEditingController(text: widget.initialCode ?? '');
  bool _joining = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _join());
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final user = AuthService.instance.currentUser;
    if (user == null) return;

    setState(() {
      _joining = true;
      _error = null;
    });

    try {
      await DuelService.instance.join(
        code: code,
        uid: user.uid,
        name: AppDataStore.instance.profile.name,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          SlideUpRoute(builder: (_) => DuelSessionPage(duelId: code)),
        );
      }
    } on DuelException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not join that duel. Check the code and try again.');
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Join a Duel')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter the 6-character code your friend shared with you.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: theme.textTheme.headlineSmall?.copyWith(letterSpacing: 4),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(counterText: ''),
              onSubmitted: (_) => _join(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _joining ? null : _join,
              child: _joining
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Join Duel'),
            ),
          ],
        ),
      ),
    );
  }
}
