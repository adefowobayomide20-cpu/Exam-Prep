const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {defineSecret} = require('firebase-functions/params');
const {GoogleGenAI} = require('@google/genai');

const geminiApiKey = defineSecret('GEMINI_API_KEY');

// Same model as the rest of the AI features (Snap & Solve, Theory) — see
// project_snap_and_solve_provider memory for the cost rationale.
const MODEL = 'gemini-2.5-flash';

const MAX_HISTORY_TURNS = 20;
const MAX_OUTPUT_TOKENS = 1024;

function buildSystemPrompt(subject, topicTitle, objectives) {
  const objectivesList = (objectives || []).map((o) => `- ${o}`).join('\n');
  return (
    `You are a patient, encouraging secondary-school teacher in Nigeria, teaching a single ` +
    `curriculum topic to a WAEC/NECO/JAMB student, one small idea at a time — never a long ` +
    `lecture dump.\n\n` +
    `Subject: ${subject}\n` +
    `Topic: ${topicTitle}\n` +
    `Learning objectives for this topic:\n${objectivesList}\n\n` +
    `How to teach this topic:\n` +
    `1. Teach ONE small idea per message — a few short sentences at most, not a wall of text.\n` +
    `2. After explaining a small idea, immediately ask the student a short question checking ` +
    `whether they understood it, before moving to the next idea. Do not explain two ideas in a ` +
    `row without checking in between.\n` +
    `3. When the student answers, react to what they actually said: if right, briefly confirm ` +
    `and move to the next idea; if wrong or confused, re-explain the SAME idea differently — a ` +
    `simpler analogy or a smaller example — rather than repeating yourself verbatim.\n` +
    `4. Use relatable Nigerian, everyday examples (market prices, familiar scenarios) instead of ` +
    `generic textbook ones wherever it fits naturally.\n` +
    `5. If this is the very first message of the lesson (no prior conversation yet), start with a ` +
    `short, friendly welcome naming the topic, then begin with the first idea and a check-in ` +
    `question — do not wait for the student to ask anything first.\n` +
    `6. Once all the learning objectives have been covered and checked, tell the student they've ` +
    `completed this topic and briefly summarize what they learned.\n\n` +
    `Keep every message short — this is a back-and-forth conversation, not an essay.`
  );
}

// Callable from the web/app client. Drives one turn of a Socratic,
// curriculum-topic-scoped lesson via Gemini. The client owns the curriculum
// content (public/content/curriculum/*.json) and passes the topic's title +
// objectives on every call rather than this function looking them up
// server-side — keeps this function generic across subjects without a
// server-side copy of the curriculum data to keep in sync.
exports.teachLesson = onCall(
  {secrets: [geminiApiKey], region: 'us-central1'},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required.');
    }

    const {subject, topicTitle, objectives, message, history} = request.data || {};
    if (!subject || typeof subject !== 'string') {
      throw new HttpsError('invalid-argument', 'subject is required.');
    }
    if (!topicTitle || typeof topicTitle !== 'string') {
      throw new HttpsError('invalid-argument', 'topicTitle is required.');
    }
    if (!Array.isArray(objectives) || objectives.length === 0) {
      throw new HttpsError('invalid-argument', 'objectives is required.');
    }

    const priorContents = Array.isArray(history)
      ? history
          .filter((m) => m && typeof m.role === 'string' && typeof m.text === 'string')
          .slice(-MAX_HISTORY_TURNS)
          .map((m) => ({
            role: m.role === 'assistant' ? 'model' : 'user',
            parts: [{text: m.text}],
          }))
      : [];

    // First message of a lesson: no student message yet, just a nudge to
    // begin, per instruction 5 in the system prompt.
    const currentTurn = {
      role: 'user',
      parts: [{text: typeof message === 'string' && message.trim() ? message.trim() : 'Begin the lesson.'}],
    };

    const client = new GoogleGenAI({apiKey: geminiApiKey.value()});
    let response;
    try {
      response = await client.models.generateContent({
        model: MODEL,
        contents: [...priorContents, currentTurn],
        config: {
          systemInstruction: buildSystemPrompt(subject, topicTitle, objectives),
          maxOutputTokens: MAX_OUTPUT_TOKENS,
        },
      });
    } catch (error) {
      console.error('Gemini request failed (teachLesson)', error);
      throw new HttpsError('internal', 'Could not reach the AI Teacher right now. Try again shortly.');
    }

    if (response.promptFeedback && response.promptFeedback.blockReason) {
      return {text: "Let's try that again — could you rephrase your last message?"};
    }
    const finishReason = response.candidates && response.candidates[0]
      ? response.candidates[0].finishReason
      : undefined;
    if (finishReason === 'SAFETY' || finishReason === 'RECITATION') {
      return {text: "Let's try that again — could you rephrase your last message?"};
    }

    const text = response.text || '';
    return {
      text: text || "Sorry, I didn't catch that — could you try again?",
      truncated: finishReason === 'MAX_TOKENS',
    };
  },
);
