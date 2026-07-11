import '../../features/exam/quiz/quiz_question.dart';

enum DuelStatus { waiting, active, finished }

/// One side of a [Duel] — kept identical in shape for host and guest so the
/// UI can render either without branching on which one it is.
class DuelPlayerState {
  const DuelPlayerState({
    required this.uid,
    required this.name,
    this.answered = 0,
    this.correct = 0,
    this.points = 0,
    this.finishedAt,
    this.penaltySeconds = 0,
  });

  final String uid;
  final String name;
  final int answered;
  final int correct;

  /// Speed-weighted score: correct answers earn more the faster they're
  /// submitted. Used (instead of raw [correct]) to decide the duel winner.
  final int points;
  final DateTime? finishedAt;

  /// Seconds knocked off this player's remaining time by the opponent's
  /// "Freeze" lifeline.
  final int penaltySeconds;

  bool get isFinished => finishedAt != null;
}

class Duel {
  const Duel({
    required this.id,
    required this.subject,
    required this.questions,
    required this.durationSeconds,
    required this.status,
    required this.createdAt,
    required this.host,
    this.guest,
    this.startedAt,
  });

  final String id;
  final String subject;
  final List<QuizQuestion> questions;
  final int durationSeconds;
  final DuelStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DuelPlayerState host;
  final DuelPlayerState? guest;

  bool isParticipant(String uid) => host.uid == uid || guest?.uid == uid;
  bool isHost(String uid) => host.uid == uid;

  DuelPlayerState? opponentOf(String uid) => isHost(uid) ? guest : host;
  DuelPlayerState? selfOf(String uid) => isHost(uid) ? host : (guest?.uid == uid ? guest : null);

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'questions': questions.map((q) => q.toJson()).toList(),
        'durationSeconds': durationSeconds,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'hostUid': host.uid,
        'hostName': host.name,
        'hostAnswered': host.answered,
        'hostCorrect': host.correct,
        'hostPoints': host.points,
        'hostFinishedAt': host.finishedAt?.toIso8601String(),
        'hostPenaltySeconds': host.penaltySeconds,
        'guestUid': guest?.uid,
        'guestName': guest?.name,
        'guestAnswered': guest?.answered ?? 0,
        'guestCorrect': guest?.correct ?? 0,
        'guestPoints': guest?.points ?? 0,
        'guestFinishedAt': guest?.finishedAt?.toIso8601String(),
        'guestPenaltySeconds': guest?.penaltySeconds ?? 0,
      };

  factory Duel.fromJson(Map<String, dynamic> json) {
    final guestUid = json['guestUid'] as String?;
    return Duel(
      id: json['id'] as String,
      subject: json['subject'] as String,
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(Map<String, dynamic>.from(q as Map)))
          .toList(),
      durationSeconds: json['durationSeconds'] as int,
      status: DuelStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => DuelStatus.waiting,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      host: DuelPlayerState(
        uid: json['hostUid'] as String,
        name: json['hostName'] as String,
        answered: json['hostAnswered'] as int? ?? 0,
        correct: json['hostCorrect'] as int? ?? 0,
        points: json['hostPoints'] as int? ?? 0,
        finishedAt:
            json['hostFinishedAt'] != null ? DateTime.parse(json['hostFinishedAt'] as String) : null,
        penaltySeconds: json['hostPenaltySeconds'] as int? ?? 0,
      ),
      guest: guestUid == null
          ? null
          : DuelPlayerState(
              uid: guestUid,
              name: json['guestName'] as String? ?? 'Opponent',
              answered: json['guestAnswered'] as int? ?? 0,
              correct: json['guestCorrect'] as int? ?? 0,
              points: json['guestPoints'] as int? ?? 0,
              finishedAt: json['guestFinishedAt'] != null
                  ? DateTime.parse(json['guestFinishedAt'] as String)
                  : null,
              penaltySeconds: json['guestPenaltySeconds'] as int? ?? 0,
            ),
    );
  }
}
