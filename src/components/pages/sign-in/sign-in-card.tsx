"use client";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { authClient } from "@/lib/auth-client";

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
      </CardHeader>
      <CardContent>
        <Button
          onClick={handleGoogleSignIn}
          variant="default"
          className="w-full"
        >
          Menggunakan Google
        </Button>
      </CardContent>
    </Card>
  );
}
