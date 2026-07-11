enum TutorSender { student, tutor }

class TutorMessage {
  const TutorMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
    this.imageBytesBase64,
  });

  final String id;
  final TutorSender sender;
  final String text;
  final DateTime createdAt;

  /// Base64-encoded thumbnail of the photo the student sent, if any (tutor
  /// replies never carry an image).
  final String? imageBytesBase64;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender.name,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'imageBytesBase64': imageBytesBase64,
      };

  factory TutorMessage.fromJson(Map<String, dynamic> json) => TutorMessage(
        id: json['id'] as String,
        sender: TutorSender.values.firstWhere(
          (s) => s.name == json['sender'],
          orElse: () => TutorSender.tutor,
        ),
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        imageBytesBase64: json['imageBytesBase64'] as String?,
      );
}
