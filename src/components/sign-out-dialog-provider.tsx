"use client";

import * as React from "react";

interface SignOutDialogContextType {
  open: boolean;
  setOpen: (open: boolean) => void;
}

const SignOutDialogContext = React.createContext<
  SignOutDialogContextType | undefined
>(undefined);

export function SignOutDialogProvider({
  children,
}: {
  children: React.ReactNode;
}) {
  const [open, setOpen] = React.useState(false);

  return (
    <SignOutDialogContext.Provider value={{ open, setOpen }}>
      {children}
    </SignOutDialogContext.Provider>
  );
}

export function useSignOutDialog() {
  const context = React.useContext(SignOutDialogContext);
  if (!context) {
    throw new Error(
      "useSignOutDialog must be used within a SignOutDialogProvider"
    );
  }
  return context;
}
