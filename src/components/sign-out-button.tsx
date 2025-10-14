"use client";

import { LogOut } from "lucide-react";
import { Button } from "./ui/button";
import { useSignOutDialog } from "./sign-out-dialog-provider";

export default function SignOutButton() {
  const { setOpen } = useSignOutDialog();

  return (
    <Button onClick={() => setOpen(true)} size="sm" className="rounded-full">
      <LogOut />
      Keluar
    </Button>
  );
}
