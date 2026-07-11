import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/app_data_store.dart';
import '../../data/auth_service.dart';
import '../../data/push_notification_service.dart';
import 'widgets/performance_summary_section.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_settings_section.dart';
import 'widgets/study_reminder_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _store = AppDataStore.instance;
  final _picker = ImagePicker();
  bool _uploadingAvatar = false;

  void _pickAvatar() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickAndUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickAndUpload(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Must be called synchronously from the triggering tap (no `await`
  /// beforehand) — on Flutter Web, `image_picker` opens a hidden
  /// `<input type=file>` via `.click()`, which browsers only honor within
  /// the same user-gesture call stack as the click that triggered it.
  Future<void> _pickAndUpload(ImageSource source) async {
    final file = await _picker.pickImage(source: source, maxWidth: 512, imageQuality: 80);
    if (file == null || !mounted) return;

    setState(() => _uploadingAvatar = true);
    try {
      final bytes = await file.readAsBytes();
      final name = file.name.toLowerCase();
      final contentType = name.endsWith('.png')
          ? 'image/png'
          : name.endsWith('.webp')
              ? 'image/webp'
              : 'image/jpeg';
      await _store.uploadAvatar(bytes, contentType: contentType);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not upload photo. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _store.profile.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Full name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      _store.updateProfile(_store.profile.copyWith(name: newName));
    }
  }

  Future<void> _logout() => AuthService.instance.signOut();

  Future<void> _onTogglePush(bool value) async {
    if (value) {
      final granted = await PushNotificationService.instance.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Notifications are blocked for Exam Coach — enable them in your device settings.',
              ),
            ),
          );
        }
        return;
      }
    }
    await _store.updateProfile(_store.profile.copyWith(pushNotifications: value));
  }

  String get _studentId {
    final uid = AuthService.instance.currentUser?.uid ?? '';
    final chunk = uid.length >= 8 ? uid.substring(0, 8) : uid.padRight(8, '0');
    return 'EP-${chunk.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final profile = _store.profile;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProfileHeader(
                name: profile.name,
                examTrack: profile.examTrack,
                email: AuthService.instance.currentUser?.email ?? '',
                studentId: _studentId,
                avatarUrl: profile.avatarUrl,
                uploadingAvatar: _uploadingAvatar,
                onEdit: _editName,
                onAvatarTap: _pickAvatar,
              ),
              const SizedBox(height: 20),
              const PerformanceSummarySection(),
              const SizedBox(height: 20),
              const StudyReminderSection(),
              const SizedBox(height: 20),
              ProfileSettingsSection(
                examTrack: profile.examTrack,
                onExamTrackChanged: (value) =>
                    _store.updateProfile(_store.profile.copyWith(examTrack: value)),
                school: profile.school,
                onSchoolChanged: (value) =>
                    _store.updateProfile(_store.profile.copyWith(school: value)),
                pushNotifications: profile.pushNotifications,
                emailUpdates: profile.emailUpdates,
                duelAlerts: profile.duelAlerts,
                themeMode: profile.themeMode,
                onTogglePush: _onTogglePush,
                onToggleEmail: (value) =>
                    _store.updateProfile(_store.profile.copyWith(emailUpdates: value)),
                onToggleDuel: (value) =>
                    _store.updateProfile(_store.profile.copyWith(duelAlerts: value)),
                onThemeModeChanged: (value) =>
                    _store.updateProfile(_store.profile.copyWith(themeMode: value)),
                onLogout: _logout,
              ),
            ],
          );
        },
      ),
    );
  }
}
