import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Agent Tabs — Policy-controlled payments for AI agents",
  description:
    "Stablecoin micropayments, success receipts, and batch settlement for autonomous agents on GIWA.",
  icons: { icon: "/favicon.svg", shortcut: "/favicon.svg" },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
