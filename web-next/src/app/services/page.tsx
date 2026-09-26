import type { Metadata } from "next";

// Mirrors lib/features/services/service_section.dart / whatsapp_contact.dart
// — a static, mostly-marketing page with WhatsApp deep links, no backend
// calls needed, so this is a plain Server Component (SSG at build time).
const WHATSAPP_NUMBER = "2349158452860";

function waLink(message?: string): string {
  const url = new URL(`https://wa.me/${WHATSAPP_NUMBER}`);
  if (message) url.searchParams.set("text", message);
  return url.toString();
}

interface ServiceSection {
  title: string;
  items: string[];
}

const SERVICE_SECTIONS: ServiceSection[] = [
  { title: "Sales", items: ["Examination Result Scratch Card"] },
  {
    title: "Result Services",
    items: ["WAEC Result Checker", "NECO Result Checker", "JAMB Result Checker"],
  },
  {
    title: "JAMB Services",
    items: [
      "Admission Letter Printing Guidance",
      "Original Result Printing Guidance",
      "CAPS Guidance",
    ],
  },
  {
    title: "Admission Support",
    items: ["Post-UTME & Tertiary Institution Application Assistance"],
  },
  {
    title: "Final Year Services",
    items: [
      "Project Topic Assistance",
      "Proposal Support",
      "Research Assistance",
      "Data Analysis",
      "Editing Services",
    ],
  },
];

export const metadata: Metadata = {
  title: "Services — Result Checkers, JAMB Support & Final Year Assistance",
  description:
    "Exam Coach support services for Nigerian students: WAEC/NECO/JAMB result checker scratch cards, admission letter and CAPS guidance, Post-UTME application assistance, and final year project support — reach us directly on WhatsApp.",
  alternates: { canonical: "/services" },
  openGraph: {
    title: "Services — Result Checkers, JAMB Support & Final Year Assistance",
    description:
      "WAEC/NECO/JAMB result checkers, admission and CAPS guidance, Post-UTME application assistance, and final year project support — chat with us on WhatsApp.",
    url: "/services",
  },
};

export default function ServicesPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-10 sm:px-6">
      <h1 className="text-3xl font-bold tracking-tight text-[var(--color-primary)] sm:text-4xl">
        Services
      </h1>
      <p className="mt-4 max-w-2xl text-base leading-relaxed text-[var(--color-primary)]/80">
        Beyond practice questions, our team offers direct support for
        results, admissions, and final year projects. Tap any service below
        to start a WhatsApp chat with us.
      </p>

      <div className="mt-8 space-y-8">
        {SERVICE_SECTIONS.map((section) => (
          <div key={section.title}>
            <h2 className="text-lg font-semibold text-[var(--color-primary)]">
              {section.title}
            </h2>
            <div className="mt-3 divide-y divide-[var(--color-border)] overflow-hidden rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)]">
              {section.items.map((item) => (
                <a
                  key={item}
                  href={waLink(`Hello, I'm interested in: ${item}`)}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center justify-between gap-4 px-4 py-3 transition-colors hover:bg-[var(--color-surface-alt)]"
                >
                  <span className="text-[var(--color-primary)]">{item}</span>
                  <span aria-hidden className="text-[var(--color-primary)]/40">
                    ›
                  </span>
                </a>
              ))}
            </div>
          </div>
        ))}
      </div>

      <a
        href={waLink()}
        target="_blank"
        rel="noopener noreferrer"
        className="mt-10 inline-flex items-center gap-2 rounded-full bg-navy px-6 py-3 font-semibold text-cream transition-colors hover:bg-navy-light"
      >
        Chat with us on WhatsApp
      </a>
    </div>
  );
}
