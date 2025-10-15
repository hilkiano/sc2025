"use client";

import * as React from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { useRouter } from "next/navigation";
import { authClient } from "@/lib/auth-client";
import { useSignOutDialog } from "./sign-out-dialog-provider";
import { Spinner } from "@/components/ui/spinner";
import { LogOut } from "lucide-react";

export function SignOutDialog() {
  const { open, setOpen } = useSignOutDialog();
  const router = useRouter();
  const [loading, setLoading] = React.useState(false);

  const handleLogout = async () => {
    setLoading(true);
    try {
      await authClient.signOut();

      router.refresh();
    } catch (e) {
      console.error(e);
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogContent className="w-full sm:max-w-sm">
        <DialogHeader>
          <DialogTitle>Keluar aplikasi</DialogTitle>
          <DialogDescription>
            Saudara akan mengakhiri sesi.
            <br />
            Saudara yakin?
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <div className="flex flex-col sm:flex-row items-center gap-2 justify-end w-full">
            <Button
              className="w-full sm:w-auto"
              size="sm"
              variant="ghost"
              onClick={() => setOpen(false)}
              disabled={loading}
            >
              Batalkan
            </Button>
            <Button
              className="w-full sm:w-auto"
              size="sm"
              onClick={handleLogout}
              disabled={loading}
            >
              {loading ? <Spinner /> : <LogOut />}
              Keluar
            </Button>
          </div>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
