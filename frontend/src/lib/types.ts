export type SubscriptionTier = 'freemium' | 'paid' | 'beta_trial';

export interface User {
  id: string;
  email: string;
  roles: string[];
  subscriptionTier: SubscriptionTier;
}

export interface Product {
  id: string;
  title: string;
  description: string;
  price: number;
  images: Array<{ url: string; publicId: string }>;
  vendorId: string;
}

export interface ValidationErrors {
  [field: string]: string[];
}
