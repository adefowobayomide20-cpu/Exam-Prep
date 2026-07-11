const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {defineSecret} = require('firebase-functions/params');
const {GoogleGenAI} = require('@google/genai');

const geminiApiKey = defineSecret('GEMINI_API_KEY');

const MODEL = 'gemini-2.5-flash';

const SYSTEM_PROMPT = `You are a witty, street-smart Nigerian big brother/sister explaining why a WAEC/NECO/JAMB exam answer is correct to a student who just got it wrong.

When you respond:
1. Use everyday Nigerian analogies, relatable jokes, or light Pidgin English — the kind of explanation a smart senior would give, not a textbook.
2. State the correct answer plainly first.
3. For math/science questions, break the working into short numbered steps (1., 2., 3. — not paragraphs).
4. For non-math subjects, keep it to 3-4 short sentences max.
5. Stay exam-relevant and encouraging — the goal is the student actually remembers this next time, not comic relief for its own sake.`;

const MAX_OUTPUT_TOKENS = 700;

// Callable from the Flutter app via cloud_functions. Takes a missed quiz
// question plus the student's wrong answer and returns a casual, ELI5-style
// explanation of the correct one.
exports.explainLikeImFive = onCall(
  {
    secrets: [geminiApiKey],
    region: 'us-central1',
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required.');
    }

    const {subject, questionText, options, correctIndex, userAnswerIndex} = request.data || {};

    if (!subject || typeof subject !== 'string') {
      throw new HttpsError('invalid-argument', 'subject is required.');
    }
    if (!questionText || typeof questionText !== 'string') {
      throw new HttpsError('invalid-argument', 'questionText is required.');
    }
    if (!Array.isArray(options) || options.length < 2) {
      throw new HttpsError('invalid-argument', 'options must be a list of at least 2 choices.');
    }
    if (typeof correctIndex !== 'number' || correctIndex < 0 || correctIndex >= options.length) {
      throw new HttpsError('invalid-argument', 'correctIndex is out of range.');
    }

    const userAnswerText =
      typeof userAnswerIndex === 'number' && userAnswerIndex >= 0 && userAnswerIndex < options.length
        ? options[userAnswerIndex]
        : 'no answer';

    const prompt = `Subject: ${subject}
Question: ${questionText}
Options: ${options.map((o, i) => `${i + 1}. ${o}`).join(' | ')}
Correct answer: ${options[correctIndex]}
Student picked: ${userAnswerText}

Explain why the correct answer is right, in your street-smart style.`;

    const client = new GoogleGenAI({apiKey: geminiApiKey.value()});

    let response;
    try {
      response = await client.models.generateContent({
        model: MODEL,
        contents: [{role: 'user', parts: [{text: prompt}]}],
        config: {
          systemInstruction: SYSTEM_PROMPT,
          maxOutputTokens: MAX_OUTPUT_TOKENS,
        },
      });
    } catch (error) {
      console.error('Gemini request failed', error);
      throw new HttpsError('internal', 'Could not reach the tutor right now. Try again shortly.');
    }

    const finishReason = response.candidates && response.candidates[0]
      ? response.candidates[0].finishReason
      : undefined;

    if (finishReason === 'SAFETY' || finishReason === 'RECITATION') {
      return {text: "I can't break this one down right now — try re-reading the explanation above."};
    }

    const text = response.text || '';
    return {
      text: text || "I couldn't come up with a simple explanation for that one — try again in a bit.",
    };
  },
);
