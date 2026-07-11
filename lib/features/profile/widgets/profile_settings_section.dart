import 'package:flutter/material.dart';

import '../../../widgets/slide_up_route.dart';
import '../../exam/exam_types.dart';
import '../../exam/post_jamb_schools.dart';
import '../account_security_page.dart';

class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({
    super.key,
    required this.examTrack,
    required this.onExamTrackChanged,
    required this.school,
    required this.onSchoolChanged,
    required this.pushNotifications,
    required this.emailUpdates,
    required this.duelAlerts,
    required this.themeMode,
    required this.onTogglePush,
    required this.onToggleEmail,
    required this.onToggleDuel,
    required this.onThemeModeChanged,
    required this.onLogout,
  });

  final String examTrack;
  final ValueChanged<String> onExamTrackChanged;
  final String? school;
  final ValueChanged<String> onSchoolChanged;
  final bool pushNotifications;
  final bool emailUpdates;
  final bool duelAlerts;
  final String themeMode;
  final ValueChanged<bool> onTogglePush;
  final ValueChanged<bool> onToggleEmail;
  final ValueChanged<bool> onToggleDuel;
  final ValueChanged<String> onThemeModeChanged;
  final VoidCallback onLogout;

  Future<void> _pickExamTrack(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<String>(
          groupValue: examTrack,
          onChanged: (value) => Navigator.of(sheetContext).pop(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Choose your exam track', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...examTypes.map(
                (type) => RadioListTile<String>(value: type.name, title: Text(type.name)),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) {
      onExamTrackChanged(selected);
    }
  }

  Future<void> _pickSchool(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (sheetContext, scrollController) => RadioGroup<String>(
          groupValue: school,
          onChanged: (value) => Navigator.of(sheetContext).pop(value),
          child: ListView(
            controller: scrollController,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Your target institution',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...postJambSchools.map(
                (s) => RadioListTile<String>(value: s.shortName, title: Text(s.name)),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) {
      onSchoolChanged(selected);
    }
  }

  Future<void> _pickThemeMode(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<String>(
          groupValue: themeMode,
          onChanged: (value) => Navigator.of(sheetContext).pop(value),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              RadioListTile<String>(value: 'system', title: Text('Match device setting')),
              RadioListTile<String>(value: 'light', title: Text('Light')),
              RadioListTile<String>(value: 'dark', title: Text('Dark')),
            ],
          ),
        ),
      ),
    );
    if (selected != null) {
      onThemeModeChanged(selected);
    }
  }

  void _openNotificationPreferences(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        var push = pushNotifications;
        var email = emailUpdates;
        var duel = duelAlerts;
        return SafeArea(
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Notification preferences', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SwitchListTile(
                  title: const Text('Push notifications'),
                  value: push,
                  onChanged: (value) {
                    setSheetState(() => push = value);
                    onTogglePush(value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Email updates'),
                  value: email,
                  onChanged: (value) {
                    setSheetState(() => email = value);
                    onToggleEmail(value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Duel challenge alerts'),
                  value: duel,
                  onChanged: (value) {
                    setSheetState(() => duel = value);
                    onToggleDuel(value);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onLogout();
    }
  }

  String _themeModeLabel(String value) {
    switch (value) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'Match device setting';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Exam track & subjects'),
            subtitle: Text(examTrack),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickExamTrack(context),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.location_city_outlined),
            title: const Text('Target institution'),
            subtitle: Text(school ?? 'Not set — pick one to join its duel lobby'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickSchool(context),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notification preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openNotificationPreferences(context),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Appearance'),
            subtitle: Text(_themeModeLabel(themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickThemeMode(context),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Account & security'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              SlideUpRoute(builder: (_) => const AccountSecurityPage()),
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }
}
