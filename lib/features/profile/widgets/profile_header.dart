import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.examTrack,
    required this.email,
    required this.studentId,
    this.avatarUrl,
    this.uploadingAvatar = false,
    this.onEdit,
    this.onAvatarTap,
  });

  final String name;
  final String examTrack;
  final String email;
  final String studentId;
  final String? avatarUrl;
  final bool uploadingAvatar;
  final VoidCallback? onEdit;
  final VoidCallback? onAvatarTap;

  void _copyStudentId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: studentId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student ID copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onAvatarTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl!),
                    child: avatarUrl != null
                        ? null
                        : Icon(
                            Icons.person,
                            size: 32,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                  ),
                  if (uploadingAvatar)
                    const Positioned.fill(
                      child: CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                      ),
                    ),
                  if (onAvatarTap != null && !uploadingAvatar)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.colorScheme.primary,
                        child: Icon(Icons.camera_alt, size: 14, color: theme.colorScheme.onPrimary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    examTrack,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _copyStudentId(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.badge_outlined, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Student ID: $studentId',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.copy, size: 14, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
