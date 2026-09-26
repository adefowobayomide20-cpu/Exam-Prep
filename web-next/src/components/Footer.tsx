const NAV_LINKS = [
  { href: "/", label: "Home" },
  { href: "/exam", label: "Exam" },
  { href: "/news", label: "News" },
  { href: "/services", label: "Services" },
  { href: "/about", label: "About" },
  { href: "/faq", label: "FAQ" },
];

const LEGAL_LINKS = [
  { href: "/account-deletion-request", label: "Account Deletion Request" },
  { href: "/privacy", label: "Privacy Policy" },
  { href: "/terms", label: "Terms of Service" },
  { href: "/refund-policy", label: "Refund Policy" },
];

export default function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer className="hidden border-t border-[var(--color-border)] bg-[var(--color-surface-alt)] md:block">
      <div className="mx-auto flex max-w-5xl flex-col gap-4 px-4 py-8 text-sm sm:flex-row sm:items-center sm:justify-between sm:px-6">
        <div>
          <p className="font-semibold text-[var(--color-primary)]">Exam Coach</p>
          <p className="mt-1 max-w-sm text-[var(--color-primary)]/70">
            Free WAEC, NECO, JAMB &amp; Post-UTME past questions, CBT
            practice, live duels, and an AI tutor.
          </p>
        </div>
        <nav aria-label="Footer" className="flex flex-wrap gap-4">
          {NAV_LINKS.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="text-[var(--color-primary)] transition-colors hover:text-gold"
            >
              {link.label}
            </a>
          ))}
        </nav>
      </div>
      <div className="border-t border-[var(--color-border)] px-4 py-4 sm:px-6">
        <div className="mx-auto flex max-w-5xl flex-col items-center gap-2 text-xs text-[var(--color-primary)]/60 sm:flex-row sm:justify-between">
          <p>&copy; {year} Exam Coach. All rights reserved.</p>
          <nav aria-label="Legal" className="flex gap-4">
            {LEGAL_LINKS.map((link) => (
              <a
                key={link.href}
                href={link.href}
                className="transition-colors hover:text-gold"
              >
                {link.label}
              </a>
            ))}
          </nav>
        </div>
      </div>
    </footer>
  );
}
