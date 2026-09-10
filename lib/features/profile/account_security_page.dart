import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/auth_service.dart';

/// The app has no login, so there's nothing to secure here beyond letting a
/// student wipe their local account and Firestore data if they want to.
class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  bool _busy = false;

  Future<void> _deleteAccount() async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
          'This permanently erases your quiz history, study reminders, streak, and duel '
          'results, and starts you fresh. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
    if (proceed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await AuthService.instance.deleteAccount();
      // Auth state flips to signed-out automatically; AuthGate notices and
      // signs a fresh anonymous account back in, so there's nothing left to
      // navigate — the app just resets to a blank profile.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthService.messageFor(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account & Data')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Opacity(
          opacity: _busy ? 0.6 : 1,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                  title: const Text('Delete all data', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Erase your quiz history, streak, and duel results'),
                  onTap: _deleteAccount,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
