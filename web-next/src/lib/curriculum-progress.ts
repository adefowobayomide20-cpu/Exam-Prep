import { doc, getDoc, setDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import type { Department, StudentClass } from "@/lib/curriculum";

export interface StudentProfile {
  studentClass: StudentClass;
  department: Department;
}

export interface SubjectProgress {
  currentTopicId: string | null;
  // 0-100 per topic id — set by the student marking a topic done for now;
  // a real mastery score (derived from quiz/theory performance on that
  // topic) is a follow-up once the AI Teacher's practice loop exists.
  topicMastery: Record<string, number>;
}

const EMPTY_PROGRESS: SubjectProgress = { currentTopicId: null, topicMastery: {} };

// One doc per student (not per subject) holding class/department — this is
// asked once and reused across every subject, since it doesn't vary by
// subject the way lesson progress does.
export async function getStudentProfile(uid: string): Promise<StudentProfile | null> {
  const snapshot = await getDoc(doc(db, "users", uid, "curriculumProfile", "profile"));
  const data = snapshot.data();
  if (!data || !data.studentClass || !data.department) return null;
  return { studentClass: data.studentClass, department: data.department };
}

export async function setStudentProfile(uid: string, profile: StudentProfile): Promise<void> {
  await setDoc(doc(db, "users", uid, "curriculumProfile", "profile"), profile);
}

export async function getSubjectProgress(uid: string, subject: string): Promise<SubjectProgress> {
  const snapshot = await getDoc(doc(db, "users", uid, "curriculumProgress", subject));
  const data = snapshot.data();
  if (!data) return EMPTY_PROGRESS;
  return {
    currentTopicId: data.currentTopicId ?? null,
    topicMastery: data.topicMastery ?? {},
  };
}

export async function setCurrentTopic(uid: string, subject: string, topicId: string): Promise<void> {
  await setDoc(
    doc(db, "users", uid, "curriculumProgress", subject),
    { currentTopicId: topicId },
    { merge: true },
  );
}

export async function markTopicMastery(
  uid: string,
  subject: string,
  topicId: string,
  masteryPercent: number,
): Promise<void> {
  await setDoc(
    doc(db, "users", uid, "curriculumProgress", subject),
    { topicMastery: { [topicId]: masteryPercent } },
    { merge: true },
  );
}
