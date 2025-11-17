export const isValidEmail = (email: string): boolean =>
  /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

export const isStrongPassword = (password: string): boolean => password.length >= 8;

export const isPositiveNumber = (num: number): boolean => num > 0;

export const hasMinLength = (text: string, min: number): boolean => text.length >= min;

export const hasMaxLength = (text: string, max: number): boolean => text.length <= max;
