"use client";

import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { authClient } from "@/lib/auth-client";
import Image from "next/image";

export function SignInCard() {
  const handleGoogleSignIn = async () => {
    await authClient.signIn.social({
      provider: "google",
    });
  };

  return (
    <Card className="w-full max-w-sm mx-4 sm:mx-0">
      <CardHeader>
        <CardTitle className="text-xl">Masuk Aplikasi</CardTitle>
        <CardDescription>
          Mohon gunakan penyedia layanan sosial berikut
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Button
          onClick={handleGoogleSignIn}
          variant="default"
          className="w-full"
        >
          <Image
            src={"/google-logo.svg"}
            alt="Google logo"
            className="w-4 h-4"
          />
          Akun Google
        </Button>
      </CardContent>
    </Card>
  );
}
