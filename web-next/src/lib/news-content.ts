/**
 * Education news for Nigerian students — mirrors
 * lib/features/news/news_service.dart and news_article.dart. Unlike the
 * Flutter app (which calls newsdata.io directly from the client), this
 * fetch runs server-side (see src/app/news/page.tsx, an ISR-revalidated
 * Server Component) so the article list renders as real crawlable HTML
 * instead of a client-fetched empty shell.
 *
 * There is no Firestore collection of articles to read from — the
 * `pollEducationNews` Cloud Function (functions/index.js) only writes a
 * dedupe cache (`meta/seenNewsArticles`, just IDs) and per-user
 * notification docs (`users/{uid}/notifications`), never a public article
 * store. So both the list page and per-user notifications hit the same
 * newsdata.io API the Flutter app and the Cloud Function use.
 */

export interface NewsArticle {
  id: string;
  title: string;
  source: string;
  /** Pre-formatted display date, e.g. "Jun 18, 2026". */
  date: string;
  summary: string;
  imageUrl: string | null;
  link: string | null;
  /** ISO timestamp, used for sorting merged results; null for sample articles. */
  publishedAt: string | null;
}

interface NewsDataArticle {
  article_id?: string;
  title?: string;
  source_id?: string;
  pubDate?: string;
  description?: string;
  image_url?: string;
  link?: string;
}

// Matches EXAM_KEYWORDS/CAMPUS_KEYWORDS/FUNDING_KEYWORDS in functions/index.js
// and news_service.dart's equivalents — kept in sync manually across all
// three (Flutter, Cloud Function, this file).
const EXAM_KEYWORDS = 'WAEC OR NECO OR JAMB OR GCE OR "Post-JAMB" OR "Post-UTME" OR admission';
const CAMPUS_KEYWORDS = 'ASUU OR ASUP OR "school fees" OR "admission form" OR "cut-off mark"';
const FUNDING_KEYWORDS = 'scholarship OR bursary OR "admission list" OR CAPS';

const ENDPOINT = "https://newsdata.io/api/1/latest";

/** Small non-cryptographic hash, safe in both server and browser bundles (unlike node:crypto), used to derive a stable id for a given article key. */
export function hashKey(key: string): string {
  let hash = 5381;
  for (let i = 0; i < key.length; i += 1) {
    hash = (hash * 33) ^ key.charCodeAt(i);
  }
  return (hash >>> 0).toString(16);
}

function formatDate(pubDate: string | undefined): string {
  if (!pubDate) return "";
  const parsed = new Date(pubDate);
  if (Number.isNaN(parsed.getTime())) return pubDate;
  const months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  ];
  return `${months[parsed.getMonth()]} ${parsed.getDate()}, ${parsed.getFullYear()}`;
}

function sourceNameFor(sourceId: string | undefined): string {
  if (!sourceId) return "Unknown source";
  return sourceId[0].toUpperCase() + sourceId.slice(1).replaceAll("-", " ");
}

function fromNewsDataJson(json: NewsDataArticle): NewsArticle {
  const key = json.article_id || json.link || json.title || "untitled";
  return {
    id: hashKey(key),
    title: json.title?.trim() || "Untitled",
    source: sourceNameFor(json.source_id),
    date: formatDate(json.pubDate),
    summary: json.description?.trim() || "No summary available for this article.",
    imageUrl: json.image_url || null,
    link: json.link || null,
    publishedAt: json.pubDate ?? null,
  };
}

/** Bundled sample articles, shown when no API key is configured or the live fetch fails, so /news never looks broken or empty. Mirrors sampleNewsArticles in news_article.dart. */
export const SAMPLE_ARTICLES: NewsArticle[] = [
  {
    title: "JAMB releases 2026 UTME registration timetable",
    source: "JAMB",
    date: "Jun 18, 2026",
    summary:
      "The Joint Admissions and Matriculation Board has released the registration timetable " +
      "for the 2026 Unified Tertiary Matriculation Examination, with registration opening " +
      "next month and the examination expected to hold in April.",
  },
  {
    title: "WAEC announces new exam centres for May/June diet",
    source: "WAEC",
    date: "Jun 15, 2026",
    summary:
      "The West African Examinations Council has added new examination centres across " +
      "several states ahead of the upcoming May/June West African Senior School Certificate " +
      "Examination to ease overcrowding reported in previous diets.",
  },
  {
    title: "FG approves new minimum entry requirements for tertiary admission",
    source: "Federal Ministry of Education",
    date: "Jun 10, 2026",
    summary:
      "The Federal Government has approved updated minimum entry requirements for admission " +
      "into universities, polytechnics, and colleges of education, effective from the next " +
      "admission cycle.",
  },
  {
    title: "NECO to introduce computer-based testing for GCE candidates",
    source: "NECO",
    date: "Jun 6, 2026",
    summary:
      "The National Examinations Council has disclosed plans to pilot computer-based testing " +
      "for selected subjects in the next General Certificate Examination, as part of efforts " +
      "to modernise its assessment process.",
  },
  {
    title: "Post-JAMB screening dates announced for top federal universities",
    source: "Campus Update",
    date: "Jun 2, 2026",
    summary:
      "Several federal universities have released their post-JAMB screening dates and " +
      "requirements for the 2026/2027 admission session, with most exercises scheduled to " +
      "begin in August.",
  },
  {
    title: "ASUU threatens fresh strike over unpaid 2025 agreement",
    source: "ASUU",
    date: "May 29, 2026",
    summary:
      "The Academic Staff Union of Universities has issued a warning over the Federal " +
      "Government's delay in implementing the 2025 agreement, threatening industrial action " +
      "if outstanding issues are not resolved within weeks.",
  },
  {
    title: "Several state polytechnics begin sale of admission forms",
    source: "Campus Update",
    date: "May 24, 2026",
    summary:
      "A number of state-owned polytechnics have commenced the sale of admission forms for " +
      "the 2026/2027 academic session, with application portals now open and deadlines set " +
      "for the coming weeks.",
  },
].map((a) => ({
  id: hashKey(a.title),
  imageUrl: null,
  link: null,
  publishedAt: null,
  ...a,
}));

function dedupeAndSort(articles: NewsArticle[]): NewsArticle[] {
  const seen = new Set<string>();
  const deduped = articles.filter((a) => {
    const key = a.link ?? a.title;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
  deduped.sort((a, b) => {
    if (!a.publishedAt || !b.publishedAt) return 0;
    return b.publishedAt.localeCompare(a.publishedAt);
  });
  return deduped;
}

async function fetchKeyword(apiKey: string, qInTitle: string): Promise<NewsArticle[]> {
  const url = new URL(ENDPOINT);
  url.searchParams.set("apikey", apiKey);
  url.searchParams.set("country", "ng");
  url.searchParams.set("language", "en");
  url.searchParams.set("qInTitle", qInTitle);

  const response = await fetch(url, { next: { revalidate: 3600 } });
  const body = (await response.json()) as { status?: string; results?: NewsDataArticle[] };
  if (body.status !== "success") return [];
  return (body.results ?? []).map(fromNewsDataJson);
}

/**
 * Fetches the latest education news, falling back to bundled sample
 * articles if no API key is configured or every request fails — the News
 * page should never render empty or broken.
 */
export async function fetchEducationNews(): Promise<NewsArticle[]> {
  const apiKey = process.env.NEWSDATA_API_KEY;
  if (!apiKey) return SAMPLE_ARTICLES;

  try {
    const [exam, campus, funding] = await Promise.all([
      fetchKeyword(apiKey, EXAM_KEYWORDS),
      fetchKeyword(apiKey, CAMPUS_KEYWORDS),
      fetchKeyword(apiKey, FUNDING_KEYWORDS),
    ]);
    const merged = dedupeAndSort([...exam, ...campus, ...funding]);
    return merged.length > 0 ? merged : SAMPLE_ARTICLES;
  } catch {
    return SAMPLE_ARTICLES;
  }
}

/**
 * Builds the URL for an article's detail page. Since there's no backend
 * "fetch article by id" endpoint (see module doc above), the article's own
 * fields travel with the link in the `d` query param — the same trick used
 * for notification deep links (see notification-types.ts) — so
 * `/news/[id]` can render full content (and real metadata) without a
 * second network round trip, whether the visitor came from the list page,
 * a notification, or a shared link.
 */
export function newsArticleHref(article: NewsArticle): string {
  return `/news/${article.id}?d=${encodeURIComponent(JSON.stringify(article))}`;
}

/** Inverse of the encoding in newsArticleHref; returns null if missing or malformed. */
export function decodeNewsArticleParam(value: string | undefined): NewsArticle | null {
  if (!value) return null;
  try {
    const parsed = JSON.parse(value) as Partial<NewsArticle>;
    if (!parsed.title || !parsed.id) return null;
    return {
      id: parsed.id,
      title: parsed.title,
      source: parsed.source ?? "Unknown source",
      date: parsed.date ?? "",
      summary: parsed.summary ?? "No summary available for this article.",
      imageUrl: parsed.imageUrl ?? null,
      link: parsed.link ?? null,
      publishedAt: parsed.publishedAt ?? null,
    };
  } catch {
    return null;
  }
}
