export type StudentClass = "ss1" | "ss2" | "ss3";
export type Department = "science" | "commercial" | "arts";

export interface CurriculumTopic {
  id: string;
  class: StudentClass;
  term: 1 | 2 | 3;
  week: number;
  title: string;
  objectives: string[];
}

export interface CurriculumSubject {
  subject: string;
  label: string;
  // "core" subjects apply to every department (Math, English); anything
  // else is only relevant to students in that specific department.
  department: Department | "core";
  topics: CurriculumTopic[];
}

// Only Mathematics has real content so far (see public/content/curriculum) —
// this list drives which subjects show up at all. Add a slug here once its
// JSON file exists.
const AVAILABLE_SUBJECTS = ["mathematics"];

export async function fetchCurriculumSubject(subject: string): Promise<CurriculumSubject | null> {
  if (!AVAILABLE_SUBJECTS.includes(subject)) return null;
  const response = await fetch(`/content/curriculum/${subject}.json`);
  if (!response.ok) return null;
  return (await response.json()) as CurriculumSubject;
}

export function subjectsForDepartment(department: Department): { subject: string; label: string }[] {
  // Static for now since only Mathematics (core) exists; once more subject
  // JSON files are added, this should read each file's `department` field
  // instead of a hardcoded pass-through.
  void department;
  return [{ subject: "mathematics", label: "Mathematics" }];
}

export function topicsForClass(curriculumSubject: CurriculumSubject, studentClass: StudentClass): CurriculumTopic[] {
  return curriculumSubject.topics
    .filter((topic) => topic.class === studentClass)
    .sort((a, b) => a.term - b.term || a.week - b.week);
}
