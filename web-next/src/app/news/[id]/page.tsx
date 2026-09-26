import Link from "next/link";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import { decodeNewsArticleParam } from "@/lib/news-content";

type Props = {
  searchParams: Promise<{ d?: string }>;
};

export async function generateMetadata({ searchParams }: Props): Promise<Metadata> {
  const { d } = await searchParams;
  const article = decodeNewsArticleParam(d);
  if (!article) return {};

  return {
    title: `${article.title} — Education News`,
    description: article.summary,
    // No canonical: this page only renders with the `d` search param (see
    // news-content.ts's module doc) — the bare `/news/${id}` path 404s, so
    // pointing `alternates.canonical` at it would tell crawlers the
    // canonical URL for this content 404s. Also noindex: the URL isn't
    // stable/enumerable (the full article travels in the query string),
    // so it isn't worth indexing separately from the /news list page.
    robots: { index: false, follow: true },
    openGraph: {
      title: article.title,
      description: article.summary,
      url: `/news/${article.id}`,
      images: article.imageUrl ? [article.imageUrl] : undefined,
    },
  };
}

/**
 * Article detail page. There's no backend "fetch article by id" endpoint
 * (see news-content.ts's module doc), so the full article travels with the
 * link via the `d` search param — this page just decodes and renders it,
 * whether it arrived from /news, a notification (see
 * NotificationsView.tsx), or a shared link. A missing/malformed `d` (e.g.
 * someone hand-typing a bare /news/<id> URL) 404s, matching the reality
 * that there's nowhere else to look the article up from.
 */
export default async function NewsArticlePage({ searchParams }: Props) {
  const { d } = await searchParams;
  const article = decodeNewsArticleParam(d);
  if (!article) notFound();

  return (
    <div className="mx-auto max-w-2xl px-4 py-10 sm:px-6">
      <Link href="/news" className="text-sm text-gold hover:underline">
        ← Back to News
      </Link>

      {article.imageUrl ? (
        // eslint-disable-next-line @next/next/no-img-element -- arbitrary third-party news image, not worth configuring remotePatterns for.
        <img
          src={article.imageUrl}
          alt=""
          className="mt-4 h-48 w-full rounded-2xl object-cover sm:h-64"
        />
      ) : null}

      <h1 className="mt-6 text-2xl font-bold tracking-tight text-[var(--color-primary)] sm:text-3xl">
        {article.title}
      </h1>
      <p className="mt-2 text-sm text-[var(--color-primary)]/60">
        {article.source}
        {article.date ? ` · ${article.date}` : ""}
      </p>
      <p className="mt-6 text-base leading-relaxed text-[var(--color-primary)]/90">
        {article.summary}
      </p>

      {article.link ? (
        <a
          href={article.link}
          target="_blank"
          rel="noopener noreferrer"
          className="mt-8 inline-block rounded-full bg-navy px-6 py-2.5 font-semibold text-cream transition-colors hover:bg-navy-light"
        >
          Read Full Article ↗
        </a>
      ) : null}
    </div>
  );
}
