import type { Metadata } from "next";
import RequireAuth from "@/lib/require-auth";
import DuelSession from "@/components/duel/DuelSession";

type Props = {
  params: Promise<{ code: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { code } = await params;
  return {
    title: `Duel ${code.toUpperCase()}`,
    robots: { index: false, follow: true },
  };
}

export default async function DuelCodePage({ params }: Props) {
  const { code } = await params;

  return (
    <RequireAuth>
      <DuelSession code={code.toUpperCase()} />
    </RequireAuth>
  );
}
