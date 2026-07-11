const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {defineSecret} = require('firebase-functions/params');
const {GoogleGenAI} = require('@google/genai');

const geminiApiKey = defineSecret('GEMINI_API_KEY');
const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
const MAX_BASE64_LENGTH = 8_000_000;

// Same model as solveQuestion (Snap & Solve) — cheap relative to Claude
// Sonnet 5 while still handling structured JSON output and multimodal
// (image) input well. See project_snap_and_solve_provider memory for the
// cost comparison that motivated this.
const MODEL = 'gemini-2.5-flash';

function requireAuth(request) {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }
}

function client() {
  return new GoogleGenAI({apiKey: geminiApiKey.value()});
}

// Throws if the whole prompt was blocked or the candidate was cut short for
// safety/recitation reasons, since there's no usable text to parse then.
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

// Generates one WAEC-style theory (essay/calculation) question for a given
// subject. Theory content isn't hand-curated per subject like the objective
// banks — Gemini generates a syllabus-appropriate prompt on demand, which is
// the only way to cover all ~35 WAEC subjects without a huge separate
// content-writing effort for each one.
exports.generateTheoryQuestion = onCall(
  {secrets: [geminiApiKey], region: 'us-central1'},
  async (request) => {
    requireAuth(request);
    const subject = (request.data || {}).subject;
    if (!subject || typeof subject !== 'string') {
      throw new HttpsError('invalid-argument', 'subject is required.');
    }

    let response;
    try {
      response = await client().models.generateContent({
        model: MODEL,
        contents: [
          {
            role: 'user',
            parts: [
              {
                text:
                  `Write one realistic WAEC (West African Senior School Certificate) theory-paper ` +
                  `question for the subject "${subject}", suitable for a single question a student ` +
                  `would answer by writing or calculating a full worked response (not multiple choice). ` +
                  `Pick one specific topic from the WAEC syllabus for this subject. If the subject is ` +
                  `mathematical or scientific, prefer a question that requires a calculation with shown ` +
                  `working. Keep the question self-contained and answerable without external diagrams.`,
              },
            ],
          },
        ],
        config: {
          maxOutputTokens: 1024,
          responseMimeType: 'application/json',
          responseSchema: {
            type: 'object',
            properties: {
              question: {type: 'string'},
              topic: {type: 'string'},
            },
            required: ['question', 'topic'],
          },
        },
      });
    } catch (error) {
      console.error('Gemini request failed (generateTheoryQuestion)', error);
      throw new HttpsError('internal', 'Could not generate a question right now. Try again shortly.');
    }

    checkBlocked(response, 'Could not generate a question for that subject. Try another subject.');

    const parsed = parseStructuredJson(response);
    if (!parsed || !parsed.question) {
      throw new HttpsError('internal', 'Could not generate a question right now. Try again.');
    }
    return {question: parsed.question, topic: parsed.topic || subject};
  },
);

// Grades a student's theory answer — either typed text or a photo of their
// handwritten working — against the given question, and returns detailed,
// child-friendly, step-by-step feedback when the answer is wrong.
exports.gradeTheoryAnswer = onCall(
  {secrets: [geminiApiKey], region: 'us-central1'},
  async (request) => {
    requireAuth(request);
    const {subject, question, answerText, answerImageBase64, mimeType} = request.data || {};

    if (!subject || typeof subject !== 'string') {
      throw new HttpsError('invalid-argument', 'subject is required.');
    }
    if (!question || typeof question !== 'string') {
      throw new HttpsError('invalid-argument', 'question is required.');
    }
    const hasText = typeof answerText === 'string' && answerText.trim().length > 0;
    const hasImage = typeof answerImageBase64 === 'string' && answerImageBase64.length > 0;
    if (!hasText && !hasImage) {
      throw new HttpsError('invalid-argument', 'Provide either answerText or answerImageBase64.');
    }
    if (hasImage) {
      if (!mimeType || !ALLOWED_MIME_TYPES.includes(mimeType)) {
        throw new HttpsError('invalid-argument', 'Unsupported image type.');
      }
      if (answerImageBase64.length > MAX_BASE64_LENGTH) {
        throw new HttpsError('invalid-argument', 'Image is too large.');
      }
    }

    const answerParts = hasImage
      ? [
          {inlineData: {mimeType, data: answerImageBase64}},
          {text: hasText ? answerText.trim() : "This is a photo of the student's working."},
        ]
      : [{text: answerText.trim()}];

    const systemPrompt =
      `You are grading a Nigerian secondary school student's WAEC theory-paper answer for the ` +
      `subject "${subject}". First work out the correct answer yourself. Then compare it with the ` +
      `student's submitted answer.\n\n` +
      `Decide "correct" as true only if the student's final answer and reasoning are substantively right ` +
      `(minor wording differences are fine; a wrong final answer or badly flawed method is not correct).\n\n` +
      `Write "feedback" as follows:\n` +
      `- If correct: briefly confirm why it's right, in 2-3 sentences.\n` +
      `- If incorrect: explain the full correct solution in detail, step by step, as if teaching a ` +
      `child who has never seen this topic before — short simple sentences, one idea per step, no ` +
      `jargon left unexplained. Then briefly point out specifically where the student's own attempt ` +
      `went wrong, if you can tell from what they submitted.`;

    let response;
    try {
      response = await client().models.generateContent({
        model: MODEL,
        contents: [
          {
            role: 'user',
            parts: [
              {text: `Question: ${question}\n\nStudent's answer:`},
              ...answerParts,
            ],
          },
        ],
        config: {
          systemInstruction: systemPrompt,
          maxOutputTokens: 4096,
          responseMimeType: 'application/json',
          responseSchema: {
            type: 'object',
            properties: {
              correct: {type: 'boolean'},
              feedback: {type: 'string'},
            },
            required: ['correct', 'feedback'],
          },
        },
      });
    } catch (error) {
      console.error('Gemini request failed (gradeTheoryAnswer)', error);
      throw new HttpsError('internal', 'Could not grade your answer right now. Try again shortly.');
    }

    if (response.promptFeedback && response.promptFeedback.blockReason) {
      return {
        correct: false,
        feedback: "I couldn't process that submission. Try rephrasing your answer or retaking the photo.",
      };
    }
    const finishReason = response.candidates && response.candidates[0]
      ? response.candidates[0].finishReason
      : undefined;
    if (finishReason === 'SAFETY' || finishReason === 'RECITATION') {
      return {
        correct: false,
        feedback: "I couldn't process that submission. Try rephrasing your answer or retaking the photo.",
      };
    }

    const parsed = parseStructuredJson(response);
    if (!parsed) {
      return {
        correct: false,
        feedback: "I couldn't read that clearly — could you try again with a clearer answer or photo?",
      };
    }
    return {correct: Boolean(parsed.correct), feedback: parsed.feedback || ''};
  },
);
