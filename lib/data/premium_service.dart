import 'package:cloud_functions/cloud_functions.dart';

/// Calls the Paystack-backed Cloud Functions for subscribing to Premium and
/// claiming a rewarded-ad bonus AI action. Premium itself is only ever
/// granted by the `paystackWebhook` Cloud Function (see functions/payments.js)
/// — this service just kicks off checkout / reports the ad reward.
class PremiumService {
  PremiumService._();

  static final PremiumService instance = PremiumService._();

  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  /// Starts a Paystack Standard Checkout transaction and returns the hosted
  /// `authorization_url` to open (e.g. via url_launcher).
  Future<String> initializePayment() async {
    final result = await _functions.httpsCallable('initializePayment').call<Map<String, dynamic>>();
    return result.data['authorizationUrl'] as String;
  }

  /// Reports a completed rewarded ad, granting one bonus AI action for today.
  Future<void> claimRewardedAdBonus() async {
    await _functions.httpsCallable('claimRewardedAdBonus').call<Map<String, dynamic>>();
  }
}
