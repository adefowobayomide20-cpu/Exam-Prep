import Link from "next/link";

// Same support number already used on /services (see that page for the
// wa.me URL-building pattern this mirrors) — reused here rather than
// introducing a second number to keep in sync.
const WHATSAPP_NUMBER = "2349158452860";
const MESSAGE = "Hi Exam Coach, I'd like to share some feedback:";

/**
 * Site-wide floating WhatsApp button so students can share feedback/opinions
 * from anywhere, not just the Services page. Fixed bottom-right, sits above
 * the mobile bottom tab bar (bottom-20 clears its ~64px height plus a small
 * gap) and lower on desktop (bottom-6, no bottom tab bar there to clear).
 */
export default function WhatsAppFloatingButton() {
  const url = new URL(`https://wa.me/${WHATSAPP_NUMBER}`);
  url.searchParams.set("text", MESSAGE);

  return (
    <Link
      href={url.toString()}
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Chat with us on WhatsApp"
      className="fixed right-4 bottom-20 z-40 flex h-14 w-14 items-center justify-center rounded-full bg-[#25D366] text-white shadow-lg transition-transform hover:scale-105 md:bottom-6"
    >
      <svg viewBox="0 0 24 24" width="28" height="28" fill="currentColor" aria-hidden="true">
        <path d="M12.04 2c-5.5 0-9.96 4.46-9.96 9.96 0 1.76.46 3.45 1.32 4.95L2 22l5.25-1.38a9.9 9.9 0 0 0 4.79 1.22h.01c5.5 0 9.96-4.46 9.96-9.96S17.54 2 12.04 2zm5.83 14.24c-.25.7-1.24 1.28-2.02 1.44-.55.12-1.26.21-3.67-.78-3.08-1.28-5.06-4.4-5.22-4.6-.15-.21-1.25-1.66-1.25-3.17s.79-2.25 1.07-2.56c.28-.31.6-.38.8-.38s.4 0 .58.01c.19.01.44-.07.68.53.25.6.85 2.08.92 2.23.08.15.13.33.02.53-.1.21-.16.33-.31.51-.15.18-.32.4-.46.54-.15.15-.31.31-.13.61.18.31.8 1.32 1.73 2.14 1.19 1.06 2.19 1.39 2.5 1.55.31.15.49.13.67-.08.18-.21.77-.9 1-1.21.21-.31.42-.25.71-.15.29.1 1.85.87 2.17 1.03.31.15.52.23.6.36.08.13.08.75-.17 1.45z" />
      </svg>
    </Link>
  );
}
