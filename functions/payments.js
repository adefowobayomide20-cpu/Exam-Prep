const {onCall, onRequest, HttpsError} = require('firebase-functions/v2/https');
const {onSchedule} = require('firebase-functions/v2/scheduler');
const {defineSecret} = require('firebase-functions/params');
const admin = require('firebase-admin');
const https = require('https');
const crypto = require('crypto');

const paystackSecretKey = defineSecret('PAYSTACK_SECRET_KEY');

// ₦700/month in kobo (Paystack's smallest currency unit) — a placeholder,
// easy to change; not otherwise baked into anything else.
const MONTHLY_PRICE_KOBO = 70000;
const PREMIUM_DURATION_DAYS = 30;

function paystackRequest(method, path, secretKey, body) {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : null;
    const req = https.request(
      {
        hostname: 'api.paystack.co',
        path,
        method,
        headers: {
          Authorization: `Bearer ${secretKey}`,
          'Content-Type': 'application/json',
          ...(payload ? {'Content-Length': Buffer.byteLength(payload)} : {}),
        },
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          try {
            resolve({status: res.statusCode, body: JSON.parse(data)});
          } catch (error) {
            reject(error);
          }
        });
      },
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

// Callable from the app: starts a Paystack Standard Checkout transaction and
// returns the hosted `authorization_url` for the client to open with
// url_launcher. Deliberately not using a per-platform Paystack SDK — an
// external browser tab works identically on web, Android, and iOS, and
// avoids depending on the unmaintained community Flutter Paystack package.
exports.initializePayment = onCall(
  {secrets: [paystackSecretKey], region: 'us-central1'},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required.');
    }
    const email = request.auth.token.email;
    if (!email) {
      throw new HttpsError('failed-precondition', 'Your account needs a verified email to subscribe.');
    }

    const response = await paystackRequest('POST', '/transaction/initialize', paystackSecretKey.value(), {
      email,
      amount: MONTHLY_PRICE_KOBO,
      metadata: {uid: request.auth.uid},
    });

    if (response.status !== 200 || !response.body || !response.body.status) {
      console.error('Paystack initialize failed', response);
      throw new HttpsError('internal', 'Could not start checkout right now. Try again shortly.');
    }
    return {authorizationUrl: response.body.data.authorization_url};
  },
);

// Paystack webhook — the *only* place Premium is actually granted. The
// client's redirect back from hosted checkout is just a "thanks, we'll
// confirm shortly" screen; this event is the trusted source of truth.
// Verifies the `x-paystack-signature` header (HMAC-SHA512 of the raw
// request body using the secret key, per Paystack's documented scheme)
// before trusting the payload at all.
exports.paystackWebhook = onRequest(
  {secrets: [paystackSecretKey], region: 'us-central1'},
  async (req, res) => {
    const signature = req.headers['x-paystack-signature'];
    const expected = crypto
      .createHmac('sha512', paystackSecretKey.value())
      .update(req.rawBody)
      .digest('hex');
    if (!signature || signature !== expected) {
      console.warn('Rejected Paystack webhook with invalid signature');
      res.status(401).send('Invalid signature');
      return;
    }

    const event = req.body || {};
    if (event.event === 'charge.success') {
      const uid = event.data && event.data.metadata && event.data.metadata.uid;
      if (uid) {
        const expiresAt = new Date(Date.now() + PREMIUM_DURATION_DAYS * 24 * 60 * 60 * 1000);
        await admin
          .firestore()
          .collection('users')
          .doc(uid)
          .set(
            {
              premium: {
                active: true,
                expiresAt: expiresAt.toISOString(),
                plan: 'monthly',
                updatedAt: new Date().toISOString(),
              },
            },
            {merge: true},
          );
      } else {
        console.error('charge.success webhook missing metadata.uid', event);
      }
    }

    res.status(200).send('ok');
  },
);

// Runs once daily: flips any user whose Premium has passed its expiry back
// to inactive. Mirrors sendDailyStreakNudge's scheduling style
// (streak_push.js).
exports.expirePremium = onSchedule(
  {schedule: 'every day 00:15', region: 'us-central1'},
  async () => {
    const now = Date.now();
    const snapshot = await admin.firestore().collection('users').where('premium.active', '==', true).get();

    const batch = admin.firestore().batch();
    let changed = 0;
    for (const doc of snapshot.docs) {
      const premium = doc.data().premium;
      if (premium && premium.expiresAt && new Date(premium.expiresAt).getTime() <= now) {
        batch.set(doc.ref, {premium: {...premium, active: false}}, {merge: true});
        changed += 1;
      }
    }
    if (changed > 0) await batch.commit();
  },
);
