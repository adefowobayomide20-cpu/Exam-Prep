import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _whatsappNumber = '2349158452860';

Future<void> openWhatsAppChat(BuildContext context, {String? message}) async {
  final uri = Uri.https(
    'wa.me',
    '/$_whatsappNumber',
    message == null ? null : {'text': message},
  );
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open WhatsApp')),
    );
  }
}

/// Opens WhatsApp's share sheet (no fixed recipient) with [message] —
/// used for viral "share your win" flows, letting the student pick a chat
/// or their Status.
Future<void> shareToWhatsApp(BuildContext context, {required String message}) async {
  final uri = Uri.https('wa.me', '/', {'text': message});
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open WhatsApp')),
    );
  }
}
