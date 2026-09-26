import Image from "next/image";
import type { ReactNode } from "react";

type PageHeroProps = {
  heading: ReactNode;
  /** Extra classes for the heading, e.g. a max-width. */
  headingClassName?: string;
  subtext?: ReactNode;
  /** Extra classes for the subtext, e.g. a max-width. */
  subtextClassName?: string;
  /**
   * "compact" (default): 48x48 logo, text-xl/sm:text-2xl heading — used on
   * the homepage only, intentionally smaller so it doesn't eat too much
   * vertical space above the fold.
   * "large": 64x64 logo, text-2xl/sm:text-3xl heading — the original sizing,
   * restored for sign-in/sign-up/reset-password per user request (only the
   * homepage hero should stay compact).
   */
  size?: "compact" | "large";
  /** Set false to skip the logo image entirely — for pages where the
   * site-wide header (Header.tsx on desktop, HomeTopBar.tsx on mobile) is
   * already showing the logo + "Exam Coach" name directly above this hero,
   * making a second logo here purely redundant (currently just the
   * homepage). Sign-in/sign-up/reset-password keep the logo since those
   * pages are the user's first / re-entry point and benefit from the extra
   * branding. Defaults to true (unchanged behavior everywhere else). */
  showLogo?: boolean;
};

// Shared hero used by marketing-style pages that lead with a centered logo +
// heading (home, sign-in, sign-up, reset-password). Keep this the single
// place that defines the sizing conventions rather than repeating ad-hoc
// classes per page — see `size` above for the two variants.
export default function PageHero({
  heading,
  headingClassName,
  subtext,
  subtextClassName,
  size = "compact",
  showLogo = true,
}: PageHeroProps) {
  const logoSize = size === "large" ? 64 : 48;
  const headingSizeClasses =
    size === "large" ? "text-2xl sm:text-3xl" : "text-xl sm:text-2xl";

  return (
    <div className="flex flex-col items-center text-center">
      {showLogo && (
        <Image
          src="/logo/logo_badge.png"
          alt="Exam Coach"
          width={logoSize}
          height={logoSize}
          priority
        />
      )}
      <h1
        className={`${showLogo ? "mt-3" : ""} font-bold tracking-tight text-[var(--color-primary)] ${headingSizeClasses} ${headingClassName ?? ""}`}
      >
        {heading}
      </h1>
      {subtext ? (
        <p
          className={`mt-2 text-sm text-[var(--color-primary)]/70 ${subtextClassName ?? ""}`}
        >
          {subtext}
        </p>
      ) : null}
    </div>
  );
}
