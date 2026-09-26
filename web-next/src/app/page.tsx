import Link from "next/link";
import { CATEGORIES } from "@/lib/exam-content";
import { fetchEducationNews, newsArticleHref } from "@/lib/news-content";
import ContinueQuizCard from "@/components/home/ContinueQuizCard";
import PerformanceTrackRecord from "@/components/home/PerformanceTrackRecord";
import GamificationSummary from "@/components/home/GamificationSummary";
import PageHero from "@/components/PageHero";

// Refetch news at most once an hour, matching /news — this is the only
// part of the homepage that needs a network fetch at render time, so it's
// the only reason this page needs ISR instead of being fully static; the
// auth/quiz-attempts personalization below happens client-side.
export const revalidate = 3600;

const NEWS_PREVIEW_COUNT = 4;

export default async function Home() {
  const news = (await fetchEducationNews()).slice(0, NEWS_PREVIEW_COUNT);
  const categories = Object.values(CATEGORIES);

  return (
    <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6">
      {/* No logo here — Header.tsx (desktop) / HomeTopBar.tsx (mobile) already
          show the logo + "Exam Coach" name in the site-wide header row right
          above this, so a second logo was purely redundant. The heading and
          subtext stay: the <h1> is meaningful for SEO (a clear on-page
          heading search engines and screen readers rely on), and none of
          this text was ever duplicated elsewhere on the page. */}
      <PageHero
        showLogo={false}
        heading="WAEC, NECO, JAMB & Post-UTME prep, done right."
        headingClassName="max-w-2xl"
        subtext="Past questions, timed CBT practice, live duels with friends, and an AI tutor for the tough ones."
        subtextClassName="max-w-xl"
      />

      {/* Streak/XP/level at-a-glance — client-rendered, signed-in only */}
      <GamificationSummary />

      <div className="mt-10 grid grid-cols-1 gap-6 lg:grid-cols-2">
        {/* 1. Take a new study quiz / continue from where you left off */}
        <ContinueQuizCard />

        {/* 2. Snap & Solve */}
        <section className="rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6">
          <p className="text-xs font-semibold uppercase tracking-wide text-gold">
            AI Tutor
          </p>
          <h2 className="mt-1 text-xl font-bold text-[var(--color-primary)]">
            Snap & Solve
          </h2>
          <p className="mt-2 text-sm text-[var(--color-primary)]/70">
            Snap a photo of any question and get an instant, step-by-step AI
            explanation.
          </p>
          <Link
            href="/tutor"
            className="mt-4 inline-flex items-center rounded-full bg-navy px-5 py-2 text-sm font-semibold text-cream transition-colors hover:bg-navy-light"
          >
            Try Snap & Solve
          </Link>
        </section>

        {/* 3. Performance track record */}
        <PerformanceTrackRecord />

        {/* 4. Challenge a friend */}
        <section className="rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6">
          <p className="text-xs font-semibold uppercase tracking-wide text-gold">
            Duels
          </p>
          <h2 className="mt-1 text-xl font-bold text-[var(--color-primary)]">
            Challenge a friend
          </h2>
          <p className="mt-2 text-sm text-[var(--color-primary)]/70">
            Go head-to-head in a live 1v1 quiz duel and see who scores higher
            in real time.
          </p>
          <Link
            href="/duel"
            className="mt-4 inline-flex items-center rounded-full bg-navy px-5 py-2 text-sm font-semibold text-cream transition-colors hover:bg-navy-light"
          >
            Start a duel
          </Link>
        </section>
      </div>

      {/* 5. Exam type */}
      <section className="mt-6 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <div>
            <p className="text-xs font-semibold uppercase tracking-wide text-gold">
              Exam type
            </p>
            <h2 className="mt-1 text-xl font-bold text-[var(--color-primary)]">
              Choose your exam
            </h2>
          </div>
          <Link href="/exam" className="text-sm font-semibold text-gold hover:underline">
            See all exams →
          </Link>
        </div>
        {/* Mobile/tablet: horizontal scroll-snap carousel so all 4 exam
            cards don't stack into a tall list — cards are a fixed width
            with a peek of the next card at the edge as a scroll affordance.
            Desktop (md+): switches to a normal 4-up grid with scrolling
            disabled, since there's enough width to show all cards at once
            without swiping. CSS-only (scroll-snap), no carousel library. */}
        <ul className="mt-4 flex snap-x snap-mandatory gap-3 overflow-x-auto pb-2 -mx-4 px-4 sm:mx-0 sm:px-0 md:grid md:grid-cols-4 md:gap-3 md:overflow-visible md:pb-0">
          {categories.map((category) => (
            <li key={category.slug} className="w-[72%] shrink-0 snap-start sm:w-[45%] md:w-auto">
              <Link
                // JAMB jumps straight to its combined-exam flow (English
                // compulsory + 3 electives, the real exam format) instead of
                // the flat subject list — see /exam/page.tsx for the same
                // special-case and rationale.
                href={category.slug === "jamb" ? "/jamb/combined" : `/${category.slug}`}
                className="flex h-full flex-col justify-between rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] px-4 py-3 transition-colors hover:border-gold"
              >
                <span className="font-medium text-[var(--color-primary)]">
                  {category.shortLabel}
                </span>
                <span className="mt-1 text-xs text-[var(--color-primary)]/60">
                  {category.name}
                </span>
              </Link>
            </li>
          ))}
        </ul>
      </section>

      {/* 6. News update */}
      <section className="mt-6 rounded-2xl border border-[var(--color-border)] bg-[var(--color-surface-alt)] p-6">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <div>
            <p className="text-xs font-semibold uppercase tracking-wide text-gold">
              News
            </p>
            <h2 className="mt-1 text-xl font-bold text-[var(--color-primary)]">
              Latest education news
            </h2>
          </div>
          <Link href="/news" className="text-sm font-semibold text-gold hover:underline">
            See all news →
          </Link>
        </div>
        <ul className="mt-4 space-y-3">
          {news.map((article) => (
            <li key={article.id}>
              <Link
                href={newsArticleHref(article)}
                className="flex gap-3 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] p-3 transition-colors hover:border-gold"
              >
                {article.imageUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element -- arbitrary third-party news thumbnails, not worth configuring remotePatterns for a decorative list thumbnail.
                  <img
                    src={article.imageUrl}
                    alt=""
                    width={56}
                    height={56}
                    className="h-14 w-14 shrink-0 rounded-lg object-cover"
                  />
                ) : (
                  <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-lg bg-[var(--color-surface-alt)] text-xl">
                    📰
                  </div>
                )}
                <div className="min-w-0">
                  <p className="line-clamp-2 text-sm font-semibold text-[var(--color-primary)]">
                    {article.title}
                  </p>
                  <p className="mt-1 text-xs text-[var(--color-primary)]/60">
                    {article.source}
                    {article.date ? ` · ${article.date}` : ""}
                  </p>
                </div>
              </Link>
            </li>
          ))}
        </ul>
      </section>
    </div>
  );
}
