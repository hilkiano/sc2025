import SignOutButton from "@/components/sign-out-button";
import { SignOutDialog } from "@/components/sign-out-dialog";
import { SignOutDialogProvider } from "@/components/sign-out-dialog-provider";
import ThemeSwitcher from "@/components/theme-switcher";
import { auth } from "@/lib/auth";
import { headers } from "next/headers";

export default async function Template({
  children,
}: {
  children: React.ReactNode;
}) {
  const session = await auth.api.getSession({
    headers: await headers(),
  });

  return (
    <SignOutDialogProvider>
      <div className="flex flex-col h-screen relative">
        {/* top bar */}
        <div className="absolute top-0 z-50 flex items-center justify-between w-full h-16 px-4 bg-background">
          <div></div>
          <div className="flex items-center gap-2">
            {session?.user ? <SignOutButton /> : <></>}
            <ThemeSwitcher />
          </div>
        </div>

        {/* main content */}
        {children}
      </div>
      <SignOutDialog />
    </SignOutDialogProvider>
  );
}
