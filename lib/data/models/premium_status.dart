/// Premium subscription state, written only by Cloud Functions (the
/// Paystack webhook and the daily expiry sweep) — never by the client. See
/// firestore.rules for the field-diff guard that blocks client writes to
/// this field on the user doc.
class PremiumStatus {
  const PremiumStatus({required this.active, required this.expiresAt, required this.plan});

  factory PremiumStatus.defaults() => const PremiumStatus(active: false, expiresAt: null, plan: null);

  final bool active;
  final DateTime? expiresAt;
  final String? plan;

  Map<String, dynamic> toJson() => {
        'active': active,
        'expiresAt': expiresAt?.toIso8601String(),
        'plan': plan,
      };

  factory PremiumStatus.fromJson(Map<String, dynamic> json) => PremiumStatus(
        active: json['active'] as bool? ?? false,
        expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'] as String) : null,
        plan: json['plan'] as String?,
      );
}
