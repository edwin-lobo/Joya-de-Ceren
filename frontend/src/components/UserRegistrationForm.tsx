'use client';

import { zodResolver } from '@hookform/resolvers/zod';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { apiClient } from '@/lib/apiClient';
import type { User } from '@/lib/types';
import { FormErrorDisplay } from './FormErrorDisplay';
import { useFormValidation } from '@/hooks/useFormValidation';

const registrationSchema = z.object({
  email: z.string().email('Enter a valid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  roles: z.array(z.enum(['vendor', 'customer'])).min(1, 'Select at least one role'),
});

type RegistrationFormValues = z.infer<typeof registrationSchema>;

const roleOptions: Array<{ id: string; label: string }> = [
  { id: 'vendor', label: 'Vendor' },
  { id: 'customer', label: 'Customer' },
];

export const UserRegistrationForm = () => {
  const [loading, setLoading] = useState(false);
  const [statusMessage, setStatusMessage] = useState<
    { type: 'success' | 'error'; text: string } | null
  >(null);
  const {
    register,
    handleSubmit: rhfHandleSubmit,
    formState: { errors: clientErrors },
  } = useForm<RegistrationFormValues>({
    resolver: zodResolver(registrationSchema),
    defaultValues: { roles: [] },
  });

  const { errors, handleSubmit, getFieldError, clearErrors } = useFormValidation();

  const submit = async (values: RegistrationFormValues) => {
    setStatusMessage(null);
    clearErrors();
    setLoading(true);
    try {
      await handleSubmit(
        () => apiClient.post<User>('/api/register', values),
        () =>
          setStatusMessage({
            type: 'success',
            text: 'Registration successful — check your email for confirmation.',
          })
      );
    } catch (error) {
      if (error instanceof Error) {
        setStatusMessage({ type: 'error', text: error.message });
      }
    } finally {
      setLoading(false);
    }
  };

  const hasErrors = statusMessage?.type === 'error';

  const fieldError = (field: keyof RegistrationFormValues) =>
    clientErrors[field]?.message ?? getFieldError(field);

  return (
    <form
      className="space-y-6 rounded border border-gray-200 bg-white p-6 shadow-sm"
      onSubmit={rhfHandleSubmit(submit)}
    >
      <h2 className="text-xl font-semibold">Create your account</h2>
      {errors && Object.keys(errors).length > 0 && (
        <FormErrorDisplay errors={errors} label="Backend validation" />
      )}
      {statusMessage && statusMessage.type === 'success' && (
        <div className="rounded border border-green-400 bg-green-50 p-3 text-sm text-green-900">
          {statusMessage.text}
        </div>
      )}
      {hasErrors && (
        <div className="rounded border border-red-400 bg-red-50 p-3 text-sm text-red-900">
          {statusMessage?.text}
        </div>
      )}

      <div>
        <label htmlFor="email" className="block text-sm font-medium text-gray-700">
          Email
        </label>
        <input
          id="email"
          type="email"
          autoComplete="email"
          {...register('email')}
          className="mt-1 block w-full rounded border border-gray-300 px-3 py-2 focus:border-blue-500 focus:outline-none"
        />
        {fieldError('email') && (
          <p className="mt-1 text-sm text-red-600">{fieldError('email')}</p>
        )}
      </div>

      <div>
        <label htmlFor="password" className="block text-sm font-medium text-gray-700">
          Password
        </label>
        <input
          id="password"
          type="password"
          autoComplete="new-password"
          {...register('password')}
          className="mt-1 block w-full rounded border border-gray-300 px-3 py-2 focus:border-blue-500 focus:outline-none"
        />
        {fieldError('password') && (
          <p className="mt-1 text-sm text-red-600">{fieldError('password')}</p>
        )}
      </div>

      <fieldset>
        <legend className="text-sm font-medium text-gray-700">Roles</legend>
        <div className="mt-2 grid gap-3 sm:grid-cols-2">
          {roleOptions.map((option) => (
            <label key={option.id} className="flex items-center space-x-2 rounded border border-gray-200 px-3 py-2">
              <input
                type="checkbox"
                {...register('roles')}
                value={option.id}
                className="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span className="text-sm text-gray-700">{option.label}</span>
            </label>
          ))}
        </div>
        {fieldError('roles') && (
          <p className="mt-1 text-sm text-red-600">{fieldError('roles')}</p>
        )}
      </fieldset>

      <button
        type="submit"
        disabled={loading}
        className="w-full rounded bg-blue-600 px-4 py-2 text-white disabled:opacity-60"
      >
        {loading ? 'Registering…' : 'Register'}
      </button>
    </form>
  );
};
