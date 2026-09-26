import type { MetadataRoute } from "next";

// PWA manifest, equivalent to the Flutter build's web/manifest.json — same
// name/theme_color/background_color/icons so the "install as app" experience
// matches what users saw on the old site.
export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Exam Coach",
    short_name: "Exam Coach",
    description: "Exam Coach — practice for JAMB, Post-UTME and WAEC.",
    start_url: "/",
    scope: "/",
    display: "standalone",
    orientation: "portrait-primary",
    background_color: "#12203D",
    theme_color: "#12203D",
    icons: [
      {
        src: "/icons/Icon-192.png",
        sizes: "192x192",
        type: "image/png",
      },
      {
        src: "/icons/Icon-512.png",
        sizes: "512x512",
        type: "image/png",
      },
      {
        src: "/icons/Icon-maskable-192.png",
        sizes: "192x192",
        type: "image/png",
        purpose: "maskable",
      },
      {
        src: "/icons/Icon-maskable-512.png",
        sizes: "512x512",
        type: "image/png",
        purpose: "maskable",
      },
    ],
  };
}
