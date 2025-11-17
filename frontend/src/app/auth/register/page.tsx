'use client';

import { UserRegistrationForm } from '@/components/UserRegistrationForm';

export default function RegisterPage() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-slate-50 px-4 py-10">
      <div className="w-full max-w-xl">
        <UserRegistrationForm />
      </div>
    </main>
  );
}
