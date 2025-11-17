'use client';

import { useCallback, useState } from 'react';
import { ValidationError } from '../lib/apiClient';
import type { ValidationErrors } from '../lib/types';

export const useFormValidation = () => {
  const [errors, setErrors] = useState<ValidationErrors>({});

  const handleSubmit = useCallback(
    async <T>(submitFn: () => Promise<T>, onSuccess: (data: T) => void) => {
      try {
        const payload = await submitFn();
        setErrors({});
        onSuccess(payload);
      } catch (error) {
        if (error instanceof ValidationError) {
          setErrors(error.fields);
          return;
        }
        throw error;
      }
    },
    []
  );

  const getFieldError = useCallback(
    (field: string) => errors[field]?.[0],
    [errors]
  );

  const clearErrors = useCallback(() => setErrors({}), []);

  return { errors, handleSubmit, getFieldError, clearErrors };
};
