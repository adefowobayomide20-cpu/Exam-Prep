/// 'system' | 'light' | 'dark' — kept as a string (not an enum) since it's
/// persisted directly to Firestore.
typedef ThemePreference = String;

class ProfileSettings {
  const ProfileSettings({
    required this.name,
    required this.examTrack,
    required this.pushNotifications,
    required this.emailUpdates,
    required this.duelAlerts,
    required this.themeMode,
    this.avatarUrl,
    this.school,
  });

  factory ProfileSettings.defaults() => const ProfileSettings(
        name: 'Student Name',
        examTrack: 'WAEC & WAEC GCE',
        pushNotifications: true,
        emailUpdates: false,
        duelAlerts: true,
        themeMode: 'system',
      );

  final String name;
  final String examTrack;
  final bool pushNotifications;
  final bool emailUpdates;
  final bool duelAlerts;
  final ThemePreference themeMode;
  final String? avatarUrl;

  /// [PostJambSchool.shortName] of the student's target institution —
  /// scopes which school lobby they land in for live duels. Null until the
  /// student picks one.
  final String? school;

  ProfileSettings copyWith({
    String? name,
    String? examTrack,
    bool? pushNotifications,
    bool? emailUpdates,
    bool? duelAlerts,
    ThemePreference? themeMode,
    String? avatarUrl,
    String? school,
  }) {
    return ProfileSettings(
      name: name ?? this.name,
      examTrack: examTrack ?? this.examTrack,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailUpdates: emailUpdates ?? this.emailUpdates,
      duelAlerts: duelAlerts ?? this.duelAlerts,
      themeMode: themeMode ?? this.themeMode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      school: school ?? this.school,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'examTrack': examTrack,
        'pushNotifications': pushNotifications,
        'emailUpdates': emailUpdates,
        'duelAlerts': duelAlerts,
        'themeMode': themeMode,
        'avatarUrl': avatarUrl,
        'school': school,
      };

  factory ProfileSettings.fromJson(Map<String, dynamic> json) {
    final defaults = ProfileSettings.defaults();
    return ProfileSettings(
      name: json['name'] as String? ?? defaults.name,
      examTrack: json['examTrack'] as String? ?? defaults.examTrack,
      pushNotifications: json['pushNotifications'] as bool? ?? defaults.pushNotifications,
      emailUpdates: json['emailUpdates'] as bool? ?? defaults.emailUpdates,
      duelAlerts: json['duelAlerts'] as bool? ?? defaults.duelAlerts,
      themeMode: json['themeMode'] as String? ?? defaults.themeMode,
      avatarUrl: json['avatarUrl'] as String?,
      school: json['school'] as String?,
    );
  }
}
