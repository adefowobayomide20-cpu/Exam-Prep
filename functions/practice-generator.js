const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {defineSecret} = require('firebase-functions/params');
const {GoogleGenAI} = require('@google/genai');
const admin = require('firebase-admin');
const crypto = require('crypto');
const {isPremiumActive} = require('./entitlements');

const geminiApiKey = defineSecret('GEMINI_API_KEY');
const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
const MAX_BASE64_LENGTH = 8_000_000;

// Same model as tutor.js/theory.js — cheap, and already proven to handle
// both structured JSON output and multimodal (image) input well for this
// project. See project_snap_and_solve_provider memory.
const MODEL = 'gemini-2.5-flash';

const MCQ_COUNT = 30;
const THEORY_COUNT = 5;

function requireAuth(request) {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }
}

function client() {
  return new GoogleGenAI({apiKey: geminiApiKey.value()});
}

// Same blocked/cut-short guard as theory.js — there's no usable text to
// parse if the whole prompt was blocked or the candidate was cut for
// safety/recitation reasons.
function checkBlocked(response, blockedMessage) {
  if (response.promptFeedback && response.promptFeedback.blockReason) {
    throw new HttpsError('internal', blockedMessage);
  }
  const finishReason = response.candidates && response.candidates[0]
    ? response.candidates[0].finishReason
    : undefined;
  if (finishReason === 'SAFETY' || finishReason === 'RECITATION') {
    throw new HttpsError('internal', blockedMessage);
  }
}

function parseStructuredJson(response) {
  if (!response.text) return null;
  try {
    return JSON.parse(response.text);
  } catch (error) {
    console.error('Failed to parse structured output', error, response.text);
    return null;
  }
}

// Validates the parsed Gemini output has exactly the shape the client
// expects — 30 well-formed MCQs and 5 well-formed theory questions — so a
// truncated/malformed response never reaches the client (or the cache) as a
// broken practice set.
function isValidPracticeSet(parsed) {
  if (!parsed || typeof parsed !== 'object') return false;
  const {mcqs, theoryQuestions} = parsed;
  if (!Array.isArray(mcqs) || mcqs.length !== MCQ_COUNT) return false;
  if (!Array.isArray(theoryQuestions) || theoryQuestions.length !== THEORY_COUNT) return false;

  const mcqsValid = mcqs.every((q) =>
    q &&
    typeof q.text === 'string' &&
    Array.isArray(q.options) &&
    q.options.length === 4 &&
    q.options.every((o) => typeof o === 'string') &&
    Number.isInteger(q.correctIndex) &&
    q.correctIndex >= 0 &&
    q.correctIndex <= 3 &&
    typeof q.explanation === 'string');
  if (!mcqsValid) return false;

  return theoryQuestions.every((q) =>
    q && typeof q.question === 'string' && typeof q.topic === 'string');
}

// Maps a cached (or freshly generated) Firestore doc to the exact response
// shape the client expects — mcqs matching the QuizQuestionData shape used
// throughout the rest of the site (see web-next/src/lib/exam-content.ts) so
// the client can feed these straight into the existing QuizSession
// component unmodified.
function toResponse(subject, data) {
  return {
    mcqs: data.mcqs.map((q) => ({
      subject,
      text: q.text,
      options: q.options,
      correctIndex: q.correctIndex,
      explanation: q.explanation || null,
    })),
    theoryQuestions: data.theoryQuestions.map((q) => ({question: q.question, topic: q.topic})),
  };
}

// Cache key is derived from the actual submitted material, not a random id,
// so two students who type the same subject+topic (or, far less likely,
// upload byte-identical photos) hit the same cached practice set instead of
// re-paying Gemini for materially identical input. Image-based requests will
// rarely hit this cache — different photos of the same page are never
// byte-identical — but hashing the image is still correct to include so the
// two input modes share one consistent caching mechanism.
function cacheKeyFor({subject, topicText, imageBase64}) {
  const hash = crypto.createHash('sha256');
  if (topicText) {
    hash.update(`${subject.trim().toLowerCase()}|${topicText.trim().toLowerCase()}`);
  } else {
    hash.update(imageBase64);
  }
  return hash.digest('hex');
}

const MCQ_SCHEMA = {
  type: 'object',
  properties: {
    text: {type: 'string'},
    options: {
      type: 'array',
      items: {type: 'string'},
      minItems: 4,
      maxItems: 4,
    },
    correctIndex: {type: 'integer'},
    explanation: {type: 'string'},
  },
  required: ['text', 'options', 'correctIndex', 'explanation'],
};

const THEORY_SCHEMA = {
  type: 'object',
  properties: {
    question: {type: 'string'},
    topic: {type: 'string'},
  },
  required: ['question', 'topic'],
};

const RESPONSE_SCHEMA = {
  type: 'object',
  properties: {
    mcqs: {
      type: 'array',
      items: MCQ_SCHEMA,
      minItems: MCQ_COUNT,
      maxItems: MCQ_COUNT,
    },
    theoryQuestions: {
      type: 'array',
      items: THEORY_SCHEMA,
      minItems: THEORY_COUNT,
      maxItems: THEORY_COUNT,
    },
  },
  required: ['mcqs', 'theoryQuestions'],
};

function buildPromptParts({subject, topicText, imageBase64, mimeType}) {
  const instructions =
    `You are writing a full practice test for a Nigerian secondary school student, at WAEC/JAMB ` +
    `difficulty, for the subject "${subject}". Base every question ONLY on the topics/syllabus ` +
    `material ${topicText ? 'described below' : 'shown in the attached photo'} — do not invent ` +
    `topics outside what's given.\n\n` +
    `Produce exactly ${MCQ_COUNT} multiple-choice questions, each with exactly 4 options, a single ` +
    `unambiguous correct answer, and a short explanation of why that answer is correct. Vary which ` +
    `option position (0-3) holds the correct answer across the set — do not always put it first.\n\n` +
    `Also produce exactly ${THEORY_COUNT} theory/essay-style questions (the kind answered by writing ` +
    `or calculating a full worked response, not multiple choice), covering different sub-topics from ` +
    `the MCQs where the material allows it.`;

  const parts = [{text: instructions}];
  if (topicText) {
    parts.push({text: `Topic list / course outline:\n${topicText.trim()}`});
  } else {
    parts.push({inlineData: {mimeType, data: imageBase64}});
  }
  return parts;
}

// Generates a full practice test (30 auto-graded MCQs + 5 AI-graded theory
// questions) from a student's own photographed course outline or typed
// topic list. Premium-only — hard-gated server-side (see isPremiumActive
// check below), not just hidden in the UI, since this is a much heavier
// Gemini call than the existing per-question Tutor/Theory features.
exports.generatePracticeSetFromOutline = onCall(
  {secrets: [geminiApiKey], region: 'us-central1'},
  async (request) => {
    requireAuth(request);

    const userRef = admin.firestore().collection('users').doc(request.auth.uid);
    const userDoc = await userRef.get();
    if (!isPremiumActive((userDoc.data() || {}).premium)) {
      throw new HttpsError(
        'permission-denied',
        'This feature is Premium-only. Upgrade to generate a full practice test from your own notes.',
      );
    }

    const {subject, topicText, imageBase64, mimeType} = request.data || {};
    if (!subject || typeof subject !== 'string' || !subject.trim()) {
      throw new HttpsError('invalid-argument', 'subject is required.');
    }

    const hasText = typeof topicText === 'string' && topicText.trim().length > 0;
    const hasImage = typeof imageBase64 === 'string' && imageBase64.length > 0;
    if (!hasText && !hasImage) {
      throw new HttpsError('invalid-argument', 'Provide either topicText or imageBase64.');
    }
    if (hasImage) {
      if (!mimeType || !ALLOWED_MIME_TYPES.includes(mimeType)) {
        throw new HttpsError('invalid-argument', 'Unsupported image type.');
      }
      if (imageBase64.length > MAX_BASE64_LENGTH) {
        throw new HttpsError('invalid-argument', 'Image is too large.');
      }
    }

    const cacheKey = cacheKeyFor({subject, topicText: hasText ? topicText : undefined, imageBase64: hasImage ? imageBase64 : undefined});
    const cacheRef = admin.firestore().collection('generatedPracticeSets').doc(cacheKey);

    const cached = await cacheRef.get();
    if (cached.exists) {
      const data = cached.data();
      if (isValidPracticeSet(data)) {
        return toResponse(subject, data);
      }
      // Fall through and regenerate if a previously cached doc is somehow
      // malformed — shouldn't happen (we only ever write valid sets), but
      // don't hand a broken set to the client just because it's cached.
    }

    let response;
    try {
      response = await client().models.generateContent({
        model: MODEL,
        contents: [
          {
            role: 'user',
            parts: buildPromptParts({
              subject,
              topicText: hasText ? topicText : undefined,
              imageBase64: hasImage ? imageBase64 : undefined,
              mimeType,
            }),
          },
        ],
        config: {
          maxOutputTokens: 8192,
          responseMimeType: 'application/json',
          responseSchema: RESPONSE_SCHEMA,
        },
      });
    } catch (error) {
      console.error('Gemini request failed (generatePracticeSetFromOutline)', error);
      throw new HttpsError('internal', 'Could not generate a complete practice set right now. Try again.');
    }

    checkBlocked(response, 'Could not generate a practice set from that material. Try a clearer photo or description.');

    const parsed = parseStructuredJson(response);
    if (!isValidPracticeSet(parsed)) {
      throw new HttpsError('internal', 'Could not generate a complete practice set right now. Try again.');
    }

    const record = {
      subject: subject.trim(),
      mcqs: parsed.mcqs,
      theoryQuestions: parsed.theoryQuestions,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    await cacheRef.set(record);

    return toResponse(subject, record);
  },
);
