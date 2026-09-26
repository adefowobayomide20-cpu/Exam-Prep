import { addDoc, collection, serverTimestamp } from "firebase/firestore";
import { db } from "@/lib/firebase";
import type { QuizQuestionData } from "@/lib/exam-content";

/**
 * Write-only "flag a question" reports — students can report a question they
 * believe is wrong (bad answer key, typo, unclear wording) straight from the
 * result review screen. Given the volume of AI-drafted content in this
 * bank, spot-checking alone can't catch everything; this is the safety net.
 * Reports are reviewed manually (Firebase console), not surfaced back to
 * any client — see firestore.rules' `questionReports` rule: signed-in users
 * can create, nobody can read/update/delete from the client.
 */
export async function reportQuestion(
  question: QuizQuestionData,
  uid: string,
  comment: string,
): Promise<void> {
  await addDoc(collection(db, "questionReports"), {
    subject: question.subject,
    text: question.text,
    options: question.options,
    correctIndex: question.correctIndex,
    comment: comment.trim() || null,
    reportedBy: uid,
    createdAt: serverTimestamp(),
    status: "open",
  });
}
