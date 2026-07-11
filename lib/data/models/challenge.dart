import '../../features/exam/exam_types.dart';

enum ChallengeStatus { pending, accepted, declined, expired }

/// A 1v1 duel invite sent from the school lobby, stored top-level at
/// `challenges/{id}` so both the sender and recipient can read/write it.
class Challenge {
  const Challenge({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.toName,
    required this.school,
    required this.subject,
    required this.examCategory,
    required this.status,
    required this.createdAt,
    this.duelId,
  });

  final String id;
  final String fromUid;
  final String fromName;
  final String toUid;
  final String toName;
  final String school;
  final String subject;

  /// Which exam's question bank [subject] should be pulled from (WAEC, NECO,
  /// or JAMB share subject names like "Chemistry" but not syllabuses) — set
  /// by the sender when picking a subject, read by the recipient when
  /// accepting so both sides generate questions from the same bank.
  final ExamCategory examCategory;
  final ChallengeStatus status;
  final DateTime createdAt;
  final String? duelId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromUid': fromUid,
        'fromName': fromName,
        'toUid': toUid,
        'toName': toName,
        'school': school,
        'subject': subject,
        'examCategory': examCategory.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'duelId': duelId,
      };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'] as String,
        fromUid: json['fromUid'] as String,
        fromName: json['fromName'] as String,
        toUid: json['toUid'] as String,
        toName: json['toName'] as String,
        school: json['school'] as String,
        subject: json['subject'] as String,
        examCategory: ExamCategory.values.firstWhere(
          (c) => c.name == json['examCategory'],
          orElse: () => ExamCategory.waec,
        ),
        status: ChallengeStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => ChallengeStatus.expired,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        duelId: json['duelId'] as String?,
      );
}
