'use client';

import type { ValidationErrors } from '@/lib/types';

interface FormErrorDisplayProps {
  errors: ValidationErrors;
  label?: string;
}

export const FormErrorDisplay = ({ errors, label = 'Validation Errors' }: FormErrorDisplayProps) => {
  const entries = Object.entries(errors);
  if (!entries.length) {
    return null;
  }

  return (
    <div
      role="alert"
      aria-live="assertive"
      className="rounded border border-red-400 bg-red-50 p-3 text-sm text-red-900"
    >
      <p className="font-semibold">{label}</p>
      <ul>
        {entries.map(([field, messages]) => (
          <li key={field} className="mt-1">
            <strong className="capitalize">{field}</strong>: {messages[0]}
          </li>
        ))}
      </ul>
    </div>
  );
};
