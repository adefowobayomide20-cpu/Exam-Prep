import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountDeletionRequestPage extends StatelessWidget {
  const AccountDeletionRequestPage({super.key});

  static const _webUrl = 'https://examcoach-next.web.app/account-deletion-request';
  static const _whatsappUrl =
      'https://wa.me/2349158452860?text=Hello%20Exam%20Coach%2C%20I%20want%20to%20request%20deletion%20of%20my%20account%20and%20any%20related%20data.%20Please%20help%20me%20complete%20the%20account%20deletion%20process.';

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Deletion Request')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Account Deletion Request',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'You can permanently delete your Exam Coach account from the app, or request help if you cannot complete the process yourself.',
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delete your account in the app', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  const Text('1. Open your Profile.\n2. Open Account & Data.\n3. Tap Delete all data.\n4. Confirm the deletion.'),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _open(_whatsappUrl),
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Request help on WhatsApp'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _open(_webUrl),
                    icon: const Icon(Icons.public),
                    label: const Text('Open the web version'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Important note', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Account deletion is permanent. Your sign-in credentials and account progress will be removed from the active app account. Contact us on WhatsApp if you need help with a manual deletion request.',
          ),
        ],
      ),
    );
  }
}