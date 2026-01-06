import React from "react";
import Link from "next/link";
import Onboarding from "../components/Onboarding";
import ChatWidget from "../components/ChatWidget";

export default function Home() {
  return (
    <div className="min-h-screen p-6">
      <Onboarding />
      <ChatWidget />
      <header className="mb-6">
        <h1 className="text-3xl font-bold">Welcome to the Platform</h1>
      </header>
      <main>
        <p>Explore courses:</p>
        <Link href="/courses">Go to Courses</Link>
      </main>
    </div>
  );
}
