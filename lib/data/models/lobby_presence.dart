/// A student currently "in" a school's live duel lobby, stored at
/// `lobbies/{school}/members/{uid}`. [lastActiveAt] is refreshed by a
/// periodic heartbeat while the lobby screen is open; readers treat a stale
/// [lastActiveAt] as offline rather than deleting the doc outright.
class LobbyPresence {
  const LobbyPresence({
    required this.uid,
    required this.name,
    required this.school,
    required this.lastActiveAt,
  });

  final String uid;
  final String name;
  final String school;
  final DateTime lastActiveAt;

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'school': school,
        'lastActiveAt': lastActiveAt.toIso8601String(),
      };

  factory LobbyPresence.fromJson(Map<String, dynamic> json) => LobbyPresence(
        uid: json['uid'] as String,
        name: json['name'] as String,
        school: json['school'] as String,
        lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      );
}
