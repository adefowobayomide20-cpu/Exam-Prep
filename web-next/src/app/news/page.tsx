import Link from "next/link";
import type { Metadata } from "next";
import { fetchEducationNews, newsArticleHref } from "@/lib/news-content";

// Refetch (and re-render) at most once an hour — matches the
// `pollEducationNews` Cloud Function's own polling cadence, so the page
// never shows staler news than the rest of the app's notification bell.
export const revalidate = 3600;

export const metadata: Metadata = {
  title: "Education News — WAEC, NECO, JAMB & Admission Updates",
  description:
    "Stay up to date with the latest WAEC, NECO, JAMB, and Post-UTME news: registration timetables, results, ASUU updates, scholarships, and admission list releases for Nigerian students.",
  alternates: { canonical: "/news" },
  openGraph: {
    title: "Education News — WAEC, NECO, JAMB & Admission Updates",
    description:
      "Stay up to date with the latest WAEC, NECO, JAMB, and Post-UTME news, admission updates, and scholarship alerts for Nigerian students.",
    url: "/news",
  },
};

export default async function NewsPage() {
  const articles = await fetchEducationNews();

  return (
    <div className="mx-auto max-w-3xl px-4 py-10 sm:px-6">
      <h1 className="text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        Education News
      </h1>
      <p className="mt-4 max-w-2xl text-base leading-relaxed text-[var(--color-primary)]/80">
        The latest WAEC, NECO, JAMB, and Post-UTME updates — registration
        timetables, result releases, admission lists, ASUU/ASUP news, and
        scholarship alerts for Nigerian students, refreshed hourly.
      </p>

      <ul className="mt-8 space-y-4">
        {articles.map((article) => (
          <li key={article.id}>
            <Link
              href={newsArticleHref(article)}
              className="flex gap-4 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] p-4 transition-colors hover:border-gold"
            >
              {article.imageUrl ? (
                // eslint-disable-next-line @next/next/no-img-element -- arbitrary third-party news thumbnails, not worth configuring remotePatterns for a decorative list thumbnail.
                <img
                  src={article.imageUrl}
                  alt=""
                  width={64}
                  height={64}
                  className="h-16 w-16 shrink-0 rounded-lg object-cover"
                />
              ) : (
                <div className="flex h-16 w-16 shrink-0 items-center justify-center rounded-lg bg-[var(--color-surface-alt)] text-2xl">
                  📰
                </div>
              )}
              <div className="min-w-0">
                <p className="font-semibold text-[var(--color-primary)]">{article.title}</p>
                <p className="mt-1 text-sm text-[var(--color-primary)]/60">
                  {article.source}
                  {article.date ? ` · ${article.date}` : ""}
                </p>
                <p className="mt-2 line-clamp-2 text-sm text-[var(--color-primary)]/80">
                  {article.summary}
                </p>
              </div>
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}
