import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/auth_service.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  bool _busy = false;

  /// Prompts for the current password, re-authenticates, and returns
  /// whether it succeeded — every sensitive action below gates on this.
  Future<bool> _confirmPassword({required String title, required String message}) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? error;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller,
                  obscureText: true,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Current password'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Enter your current password' : null,
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: TextStyle(color: Theme.of(dialogContext).colorScheme.error)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                try {
                  await AuthService.instance.reauthenticate(controller.text);
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop(true);
                } on FirebaseAuthException catch (e) {
                  setDialogState(() => error = AuthService.messageFor(e));
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _changePassword() async {
    final reauthed = await _confirmPassword(
      title: 'Change password',
      message: 'Enter your current password to continue.',
    );
    if (!reauthed || !mounted) return;

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final newPassword = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New password'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'New password'),
            validator: (value) => (value == null || value.length < 6) ? 'At least 6 characters' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext).pop(controller.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newPassword == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await AuthService.instance.updatePassword(newPassword);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthService.messageFor(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changeEmail() async {
    final reauthed = await _confirmPassword(
      title: 'Change email',
      message: 'Enter your current password to continue.',
    );
    if (!reauthed || !mounted) return;

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final newEmail = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New email address'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'New email'),
            validator: (value) =>
                (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext).pop(controller.text.trim());
              }
            },
            child: const Text('Send Verification'),
          ),
        ],
      ),
    );
    if (newEmail == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await AuthService.instance.changeEmail(newEmail);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check $newEmail for a verification link to finish the change.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthService.messageFor(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAccount() async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account and all your data — quiz history, study '
          'reminders, and duel results. This cannot be undone.',
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

    final reauthed = await _confirmPassword(
      title: 'Confirm deletion',
      message: 'Enter your current password to permanently delete your account.',
    );
    if (!reauthed || !mounted) return;

    setState(() => _busy = true);
    try {
      await AuthService.instance.deleteAccount();
      // Auth state flips to signed-out automatically; AuthGate takes it
      // from here, so there's nothing left to navigate.
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
    final email = AuthService.instance.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Account & Security')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Opacity(
          opacity: _busy ? 0.6 : 1,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(email),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _changeEmail,
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.password_outlined),
                      title: const Text('Change password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _changePassword,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                  title: const Text('Delete account', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Permanently erase your account and data'),
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
