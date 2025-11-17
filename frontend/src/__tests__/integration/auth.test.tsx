import { act } from 'react';
import { cleanup, render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { apiClient, ValidationError } from '@/lib/apiClient';
import { UserRegistrationForm } from '@/components/UserRegistrationForm';

jest.mock('@/lib/apiClient', () => {
  const actual = jest.requireActual('@/lib/apiClient');
  return {
    __esModule: true,
    ...actual,
    apiClient: {
      ...actual.apiClient,
      post: jest.fn(),
      get: jest.fn(),
      put: jest.fn(),
      delete: jest.fn(),
    },
  };
});

describe('UserRegistrationForm integration', () => {
  afterEach(() => {
    cleanup();
    jest.clearAllMocks();
  });

  it('submits the registration form successfully', async () => {
    (apiClient.post as jest.Mock).mockResolvedValueOnce({
      id: 'user-1',
      email: 'vendor@example.com',
      roles: ['vendor'],
      subscriptionTier: 'freemium',
    });

    render(<UserRegistrationForm />);
    const user = userEvent.setup();

    await user.type(screen.getByLabelText(/email/i), 'vendor@example.com');
    await user.type(screen.getByLabelText(/password/i), 'Password123!');
    await user.click(screen.getByLabelText(/vendor/i));

    const registerButton = screen.getAllByRole('button', { name: /register/i })[0];
    await act(async () => {
      await user.click(registerButton);
    });

    await waitFor(() => {
      expect(apiClient.post).toHaveBeenCalledWith('/api/register', {
        email: 'vendor@example.com',
        password: 'Password123!',
        roles: ['vendor'],
      });
    });

    await waitFor(() => {
      expect(screen.getByText(/registration successful/i)).toBeInTheDocument();
    });
  });

  it('renders backend validation errors returned from the API', async () => {
    const validationError = new ValidationError({ roles: ['Select at least one role'] });
    (apiClient.post as jest.Mock).mockRejectedValueOnce(validationError);

    render(<UserRegistrationForm />);

    render(<UserRegistrationForm />);
    const user = userEvent.setup();

    await user.type(screen.getByLabelText(/email/i), 'vendor@example.com');
    await user.type(screen.getByLabelText(/password/i), 'Password123!');

    const registerButton = screen.getAllByRole('button', { name: /register/i })[0];
    await act(async () => {
      await user.click(registerButton);
    });

    await waitFor(() => {
      expect(screen.getByText(/select at least one role/i)).toBeInTheDocument();
    });
  });
});
