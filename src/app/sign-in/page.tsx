import { SignInCard } from "@/components/pages/sign-in/sign-in-card";
import { auth } from "@/lib/auth";
import { headers } from "next/headers";
import { redirect } from "next/navigation";
import React from "react";

export default async function SignIn() {
  // Redirect to home
  const session = await auth.api.getSession({
    headers: await headers(),
  });

  if (session?.session) {
    redirect("/");
  }

  return (
    <div className="h-screen flex items-center justify-center">
      <SignInCard />
    </div>
  );
}
