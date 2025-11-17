import type { ValidationErrors } from './types';

const BASE_URL = process.env.NEXT_PUBLIC_API_URL ?? '';

const hasJsonContent = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null && !(value instanceof FormData);

const parseJson = async (response: Response): Promise<unknown> => {
  const text = await response.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch (err) {
    console.warn('Failed to parse JSON response', err);
    return text;
  }
};

const buildUrl = (url: string): string => {
  if (url.startsWith('http') || url.startsWith('//')) {
    return url;
  }
  return `${BASE_URL}${url}`;
};

type RequestOptions = RequestInit & { data?: unknown };

export class ValidationError extends Error {
  constructor(public fields: ValidationErrors) {
    super('Validation failed');
    this.name = 'ValidationError';
  }
}

const request = async <T>(url: string, options: RequestOptions = {}): Promise<T> => {
  const resolvedUrl = buildUrl(url);
  const headers = new Headers(options.headers ?? undefined);
  headers.set('Accept', 'application/json');
  let body: BodyInit | undefined;

  if (options.data !== undefined) {
    if (options.data instanceof FormData) {
      body = options.data;
    } else if (hasJsonContent(options.data)) {
      headers.set('Content-Type', 'application/json');
      body = JSON.stringify(options.data);
    } else {
      body = String(options.data);
    }
  }

  const response = await fetch(resolvedUrl, {
    ...options,
    headers,
    body,
  });

  if (response.ok) {
    if (response.status === 204) {
      return {} as T;
    }

    const parsed = await parseJson(response);
    return parsed as T;
  }

  if (response.status === 422) {
    const parsed = await parseJson(response);
    const fields = (parsed && typeof parsed === 'object' && 'fields' in parsed
      ? (parsed as { fields: ValidationErrors }).fields
      : {});
    throw new ValidationError(fields ?? {});
  }

  const errorBody = await parseJson(response);
  const message = typeof errorBody === 'string' ? errorBody : response.statusText;
  throw new Error(message || 'Request failed');
};

export const apiClient = {
  post: async <T>(url: string, data: unknown): Promise<T> =>
    request<T>(url, { method: 'POST', data }),
  get: async <T>(url: string): Promise<T> => request<T>(url, { method: 'GET' }),
  put: async <T>(url: string, data: unknown): Promise<T> =>
    request<T>(url, { method: 'PUT', data }),
  delete: async (url: string): Promise<void> =>
    request<void>(url, { method: 'DELETE' }),
};
