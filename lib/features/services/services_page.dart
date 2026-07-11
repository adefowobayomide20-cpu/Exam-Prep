import 'package:flutter/material.dart';

import 'service_section.dart';
import 'whatsapp_contact.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in serviceSections) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Text(section.title, style: theme.textTheme.titleMedium),
            ),
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < section.items.length; i++) ...[
                    if (i > 0) const Divider(height: 0),
                    ListTile(
                      leading: Icon(Icons.chat, color: theme.colorScheme.primary),
                      title: Text(section.items[i]),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => openWhatsAppChat(
                        context,
                        message: "Hello, I'm interested in: ${section.items[i]}",
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'services_whatsapp_fab',
        onPressed: () => openWhatsAppChat(context),
        tooltip: 'Chat on WhatsApp',
        child: const Icon(Icons.chat_bubble_outline),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
