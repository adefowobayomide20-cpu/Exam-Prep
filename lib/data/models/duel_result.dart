class DuelResult {
  const DuelResult({
    required this.duelId,
    required this.subject,
    required this.won,
    required this.selfScore,
    required this.opponentScore,
    required this.at,
  });

  final String duelId;
  final String subject;
  final bool won;
  final int selfScore;
  final int opponentScore;
  final DateTime at;

  Map<String, dynamic> toJson() => {
        'duelId': duelId,
        'subject': subject,
        'won': won,
        'selfScore': selfScore,
        'opponentScore': opponentScore,
        'at': at.toIso8601String(),
      };

  factory DuelResult.fromJson(Map<String, dynamic> json) => DuelResult(
        duelId: json['duelId'] as String,
        subject: json['subject'] as String,
        won: json['won'] as bool,
        selfScore: json['selfScore'] as int,
        opponentScore: json['opponentScore'] as int,
        at: DateTime.parse(json['at'] as String),
      );
}
