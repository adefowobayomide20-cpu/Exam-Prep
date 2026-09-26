import type { MetadataRoute } from "next";
import { getAllCategorySubjectPairs, getCategorySlugs } from "@/lib/exam-content";
import { getAllSchoolSubjectPairs, getSchoolSlugs } from "@/lib/post-utme-content";

const SITE_URL = "https://www.examcoach.com.ng";

export default function sitemap(): MetadataRoute.Sitemap {
  const lastModified = new Date();

  const categoryEntries: MetadataRoute.Sitemap = getCategorySlugs().map((category) => ({
    url: `${SITE_URL}/${category}`,
    lastModified,
    changeFrequency: "weekly",
    priority: 0.8,
  }));

  const subjectEntries: MetadataRoute.Sitemap = getAllCategorySubjectPairs().map(
    ({ category, subject }) => ({
      url: `${SITE_URL}/${category}/${subject}`,
      lastModified,
      changeFrequency: "weekly",
      priority: 0.6,
    }),
  );

  // Post-UTME's school-first flow (/post-utme/[school]/[subject]) lives
  // outside getCategorySlugs()/getAllCategorySubjectPairs() — see
  // FLAT_CATEGORY_SLUGS in exam-content.ts — so it needs its own entries.
  const postUtmeRootEntry: MetadataRoute.Sitemap = [
    { url: `${SITE_URL}/post-utme`, lastModified, changeFrequency: "weekly", priority: 0.8 },
  ];

  const postUtmeSchoolEntries: MetadataRoute.Sitemap = getSchoolSlugs().map((school) => ({
    url: `${SITE_URL}/post-utme/${school}`,
    lastModified,
    changeFrequency: "weekly",
    priority: 0.7,
  }));

  const postUtmeSubjectEntries: MetadataRoute.Sitemap = getAllSchoolSubjectPairs().map(
    ({ school, subject }) => ({
      url: `${SITE_URL}/post-utme/${school}/${subject}`,
      lastModified,
      changeFrequency: "weekly",
      priority: 0.6,
    }),
  );

  return [
    {
      url: SITE_URL,
      lastModified,
      changeFrequency: "weekly",
      priority: 1,
    },
    ...categoryEntries,
    ...subjectEntries,
    ...postUtmeRootEntry,
    ...postUtmeSchoolEntries,
    ...postUtmeSubjectEntries,
    {
      url: `${SITE_URL}/theory`,
      lastModified,
      changeFrequency: "monthly",
      priority: 0.6,
    },
    {
      url: `${SITE_URL}/news`,
      lastModified,
      changeFrequency: "hourly",
      priority: 0.7,
    },
    {
      url: `${SITE_URL}/services`,
      lastModified,
      changeFrequency: "monthly",
      priority: 0.5,
    },
    {
      url: `${SITE_URL}/about`,
      lastModified,
      changeFrequency: "monthly",
      priority: 0.5,
    },
    {
      url: `${SITE_URL}/faq`,
      lastModified,
      changeFrequency: "monthly",
      priority: 0.6,
    },
    {
      url: `${SITE_URL}/account-deletion-request`,
      lastModified,
      changeFrequency: "yearly",
      priority: 0.3,
    },
    {
      url: `${SITE_URL}/privacy`,
      lastModified,
      changeFrequency: "yearly",
      priority: 0.3,
    },
    {
      url: `${SITE_URL}/terms`,
      lastModified,
      changeFrequency: "yearly",
      priority: 0.3,
    },
    {
      url: `${SITE_URL}/refund-policy`,
      lastModified,
      changeFrequency: "yearly",
      priority: 0.3,
    },
  ];
}
