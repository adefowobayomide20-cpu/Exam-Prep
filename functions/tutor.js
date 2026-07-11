const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {defineSecret} = require('firebase-functions/params');
const {GoogleGenAI} = require('@google/genai');

const geminiApiKey = defineSecret('GEMINI_API_KEY');

// gemini-2.5-flash: cheap ($0.30/$2.50 per 1M input/output tokens vs. Claude
// Sonnet 5's $2-3/$10-15) while still capable of detailed, step-by-step
// exam explanations. Revisit if explanation quality proves too shallow for
// harder subjects — gemini-3.5-flash is a stronger but ~5x pricier fallback.
const MODEL = 'gemini-2.5-flash';

const SYSTEM_PROMPT = `You are a patient, encouraging tutor helping a Nigerian secondary-school student preparing for WAEC, NECO, GCE, or JAMB. The student has sent a photo of a question (printed or handwritten), sometimes with their own attempted working.

When you respond:
1. Identify the subject and exactly what the question is asking.
2. Give the correct final answer clearly.
3. Explain the solution step by step, at a level appropriate for a WAEC/NECO/JAMB candidate — show the working, not just the result.
4. If the student included their own attempted working, point out specifically what they got right and where they went wrong, rather than only giving your own solution.
5. Keep explanations focused and exam-relevant — this is exam prep, not a general essay.

If the image is unclear, blurry, or does not contain a legible question, say so and ask the student to retake the photo rather than guessing.`;

const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
// Base64 is ~1.33x the raw byte count; this caps the raw image around ~6MB.
const MAX_BASE64_LENGTH = 8_000_000;
const MAX_HISTORY_TURNS = 10;
const MAX_OUTPUT_TOKENS = 4096;

// Callable from the Flutter app via cloud_functions. Takes a photo of a
// question (base64) plus recent chat history, and returns a step-by-step
// explanation from Gemini.
exports.solveQuestion = onCall(
  {
    secrets: [geminiApiKey],
    region: 'us-central1',
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required.');
    }

    const {imageBase64, mimeType, question, history} = request.data || {};

    if (!imageBase64 || typeof imageBase64 !== 'string') {
      throw new HttpsError('invalid-argument', 'imageBase64 is required.');
    }
    if (!mimeType || !ALLOWED_MIME_TYPES.includes(mimeType)) {
      throw new HttpsError('invalid-argument', 'Unsupported image type.');
    }
    if (imageBase64.length > MAX_BASE64_LENGTH) {
      throw new HttpsError('invalid-argument', 'Image is too large.');
    }

    const client = new GoogleGenAI({apiKey: geminiApiKey.value()});

    // Gemini uses 'model' (not 'assistant') for the AI's turns, and each
    // turn's content lives under a `parts` array rather than a plain string.
    const priorContents = Array.isArray(history)
      ? history
          .filter((m) => m && typeof m.role === 'string' && typeof m.text === 'string')
          .slice(-MAX_HISTORY_TURNS)
          .map((m) => ({
            role: m.role === 'assistant' ? 'model' : 'user',
            parts: [{text: m.text}],
          }))
      : [];

    const currentTurn = {
      role: 'user',
      parts: [
        {inlineData: {mimeType, data: imageBase64}},
        {
          text:
            question && question.trim()
              ? question.trim()
              : 'Please solve and explain this question.',
        },
      ],
    };

    let response;
    try {
      response = await client.models.generateContent({
        model: MODEL,
        contents: [...priorContents, currentTurn],
        config: {
          systemInstruction: SYSTEM_PROMPT,
          maxOutputTokens: MAX_OUTPUT_TOKENS,
        },
      });
    } catch (error) {
      console.error('Gemini request failed', error);
      throw new HttpsError('internal', 'Could not reach the tutor right now. Try again shortly.');
    }

    if (response.promptFeedback && response.promptFeedback.blockReason) {
      return {
        text:
          "I can't help with this particular request. Try rephrasing the question or " +
          'sending a clearer photo of just the question itself.',
      };
    }

    const finishReason = response.candidates && response.candidates[0]
      ? response.candidates[0].finishReason
      : undefined;

    if (finishReason === 'SAFETY' || finishReason === 'RECITATION') {
      return {
        text:
          "I can't help with this particular request. Try rephrasing the question or " +
          'sending a clearer photo of just the question itself.',
      };
    }

    const text = response.text || '';

    return {
      text: text || "I couldn't read that clearly — could you retake the photo with better lighting?",
      truncated: finishReason === 'MAX_TOKENS',
    };
  },
);
