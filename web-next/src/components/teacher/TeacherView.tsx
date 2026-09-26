"use client";

import { useEffect, useState } from "react";
import { httpsCallable } from "firebase/functions";
import { functions } from "@/lib/firebase";
import { useAuth } from "@/lib/auth-context";
import { functionsErrorMessage } from "@/lib/functions-errors";
import {
  fetchCurriculumSubject,
  topicsForClass,
  type CurriculumTopic,
  type Department,
  type StudentClass,
} from "@/lib/curriculum";
import {
  getStudentProfile,
  getSubjectProgress,
  setCurrentTopic,
  setStudentProfile,
} from "@/lib/curriculum-progress";

interface ChatMessage {
  role: "user" | "assistant";
  text: string;
}

interface TeachLessonRequest {
  subject: string;
  topicTitle: string;
  objectives: string[];
  message?: string;
  history: { role: "user" | "assistant"; text: string }[];
}

interface TeachLessonResponse {
  text: string;
  truncated?: boolean;
}

type Stage =
  | "loading"
  | "needsProfile"
  | "pickingTopic"
  | "inLesson";

const CLASS_OPTIONS: { value: StudentClass; label: string }[] = [
  { value: "ss1", label: "SS1" },
  { value: "ss2", label: "SS2" },
  { value: "ss3", label: "SS3" },
];

const DEPARTMENT_OPTIONS: { value: Department; label: string }[] = [
  { value: "science", label: "Science" },
  { value: "commercial", label: "Commercial" },
  { value: "arts", label: "Arts" },
];

/**
 * AI Teacher: a structured, curriculum-aware lesson chat (as opposed to
 * AI Tutor's on-demand "solve this specific question" flow). First-time
 * setup asks for class + department (stored once, reused across
 * subjects); then the student picks a subject and either resumes their
 * current topic or picks a new one, and gets a Socratic, one-idea-at-a-time
 * lesson via the `teachLesson` Cloud Function (functions/ai-teacher.js).
 *
 */
export default function TeacherView() {
  const { user } = useAuth();

  const [stage, setStage] = useState<Stage>("loading");
  const [studentClass, setStudentClass] = useState<StudentClass>("ss1");
  const [department, setDepartment] = useState<Department>("science");
  const [savingProfile, setSavingProfile] = useState(false);

  const [topics, setTopics] = useState<CurriculumTopic[]>([]);
  const [currentTopicId, setCurrentTopicId] = useState<string | null>(null);
  const [selectedTopic, setSelectedTopic] = useState<CurriculumTopic | null>(null);

  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState("");
  const [sending, setSending] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadTopics = async (forClass: StudentClass) => {
    const subject = await fetchCurriculumSubject("mathematics");
    if (!subject) {
      setError("Mathematics content isn't available yet — check back soon.");
      setStage("pickingTopic");
      return;
    }
    const classTopics = topicsForClass(subject, forClass);
    setTopics(classTopics);
    if (user) {
      const progress = await getSubjectProgress(user.uid, "mathematics");
      setCurrentTopicId(progress.currentTopicId);
    }
    setStage("pickingTopic");
  };

  useEffect(() => {
    if (!user) return;
    let cancelled = false;
    (async () => {
      const profile = await getStudentProfile(user.uid);
      if (cancelled) return;
      if (!profile) {
        setStage("needsProfile");
        return;
      }
      setStudentClass(profile.studentClass);
      setDepartment(profile.department);
      await loadTopics(profile.studentClass);
    })();
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user]);

  const saveProfile = async () => {
    if (!user) return;
    setSavingProfile(true);
    try {
      await setStudentProfile(user.uid, { studentClass, department });
      await loadTopics(studentClass);
    } finally {
      setSavingProfile(false);
    }
  };

  const startTopic = async (topic: CurriculumTopic) => {
    setSelectedTopic(topic);
    setMessages([]);
    setError(null);
    setStage("inLesson");
    if (user) setCurrentTopic(user.uid, "mathematics", topic.id).catch(() => {});
    await sendToTeacher(topic, undefined, []);
  };

  const sendToTeacher = async (
    topic: CurriculumTopic,
    message: string | undefined,
    priorHistory: ChatMessage[],
  ) => {
    setSending(true);
    setError(null);
    try {
      const teachLesson = httpsCallable<TeachLessonRequest, TeachLessonResponse>(
        functions,
        "teachLesson",
      );
      const { data } = await teachLesson({
        subject: "mathematics",
        topicTitle: topic.title,
        objectives: topic.objectives,
        message,
        history: priorHistory,
      });
      setMessages((prev) => [
        ...prev,
        ...(message ? [{ role: "user" as const, text: message }] : []),
        { role: "assistant" as const, text: data.text },
      ]);
    } catch (err) {
      setError(functionsErrorMessage(err));
    } finally {
      setSending(false);
    }
  };

  const submitMessage = async () => {
    const trimmed = input.trim();
    if (!trimmed || !selectedTopic || sending) return;
    setInput("");
    await sendToTeacher(selectedTopic, trimmed, messages);
  };

  if (stage === "loading") {
    return <div className="mx-auto max-w-2xl px-4 py-10 text-center sm:px-6">Loading…</div>;
  }

  if (stage === "needsProfile") {
    return (
      <div className="mx-auto max-w-md px-4 py-10 sm:px-6">
        <h1 className="text-2xl font-bold tracking-tight text-[var(--color-primary)] sm:text-3xl">
          Set up AI Teacher
        </h1>
        <p className="mt-2 text-[var(--color-primary)]/70">
          Tell us your class and department once — we&apos;ll use it to pick the right topics.
        </p>
        <div className="mt-6 flex flex-col gap-4">
          <label className="flex flex-col gap-1.5 text-sm font-medium text-[var(--color-primary)]">
            Class
            <select
              value={studentClass}
              onChange={(event) => setStudentClass(event.target.value as StudentClass)}
              className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-base text-[var(--color-primary)] outline-none focus:border-gold"
            >
              {CLASS_OPTIONS.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </label>
          <label className="flex flex-col gap-1.5 text-sm font-medium text-[var(--color-primary)]">
            Department
            <select
              value={department}
              onChange={(event) => setDepartment(event.target.value as Department)}
              className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-base text-[var(--color-primary)] outline-none focus:border-gold"
            >
              {DEPARTMENT_OPTIONS.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </label>
          <button
            type="button"
            onClick={saveProfile}
            disabled={savingProfile}
            className="rounded-full bg-navy px-6 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light disabled:opacity-60"
          >
            {savingProfile ? "Saving…" : "Continue"}
          </button>
        </div>
      </div>
    );
  }

  if (stage === "pickingTopic") {
    return (
      <div className="mx-auto max-w-2xl px-4 py-10 sm:px-6">
        <h1 className="text-2xl font-bold tracking-tight text-[var(--color-primary)] sm:text-3xl">
          Mathematics — {studentClass.toUpperCase()}
        </h1>
        {error && <p className="mt-4 text-red-600">{error}</p>}
        <div className="mt-6 flex flex-col gap-3">
          {topics.map((topic) => (
            <button
              key={topic.id}
              type="button"
              onClick={() => startTopic(topic)}
              className="flex items-center justify-between rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-4 py-3 text-left transition-colors hover:border-gold"
            >
              <span>
                <span className="block text-xs font-medium uppercase tracking-wide text-[var(--color-primary)]/60">
                  Term {topic.term} · Week {topic.week}
                </span>
                <span className="font-semibold text-[var(--color-primary)]">{topic.title}</span>
              </span>
              {currentTopicId === topic.id && (
                <span className="rounded-full bg-gold/20 px-3 py-1 text-xs font-semibold text-gold">
                  Continue
                </span>
              )}
            </button>
          ))}
          {topics.length === 0 && !error && (
            <p className="text-[var(--color-primary)]/70">
              No topics available for {studentClass.toUpperCase()} yet — more are coming soon.
            </p>
          )}
        </div>
      </div>
    );
  }

  // stage === "inLesson"
  return (
    <div className="mx-auto max-w-2xl px-4 py-10 sm:px-6">
      <button
        type="button"
        onClick={() => setStage("pickingTopic")}
        className="text-sm font-medium text-[var(--color-primary)]/70 underline decoration-dotted hover:text-gold"
      >
        &larr; Choose a different topic
      </button>
      <h1 className="mt-2 text-2xl font-bold tracking-tight text-[var(--color-primary)] sm:text-3xl">
        {selectedTopic?.title}
      </h1>

      <div className="mt-6 flex flex-col gap-4">
        {messages.map((message, index) => (
          <div
            key={index}
            className={`flex ${message.role === "user" ? "justify-end" : "justify-start"}`}
          >
            <div
              className={`max-w-[85%] rounded-xl p-4 ${
                message.role === "user"
                  ? "bg-navy text-cream"
                  : "border border-[var(--color-border)] bg-[var(--color-surface-alt)] text-[var(--color-primary)]"
              }`}
            >
              <p className="whitespace-pre-wrap">{message.text}</p>
            </div>
          </div>
        ))}
        {sending && (
          <p className="text-center text-[var(--color-primary)]/70">Thinking…</p>
        )}
      </div>

      {error && <p className="mt-4 text-red-600">{error}</p>}

      <div className="mt-6 flex gap-2">
        <input
          type="text"
          value={input}
          onChange={(event) => setInput(event.target.value)}
          onKeyDown={(event) => {
            if (event.key === "Enter") submitMessage();
          }}
          disabled={sending}
          placeholder="Type your answer…"
          className="flex-1 rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-alt)] px-3 py-2 text-base text-[var(--color-primary)] outline-none focus:border-gold disabled:opacity-60"
        />
        <button
          type="button"
          onClick={submitMessage}
          disabled={sending || !input.trim()}
          className="rounded-full bg-navy px-5 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light disabled:opacity-60"
        >
          Send
        </button>
      </div>
    </div>
  );
}
