# Repository Guidelines

## Project Structure & Module Organization
- `backend/` hosts the FastAPI + Mangum lambda handler in `app/main.py` and `requirements.txt`; keep logic here focused on API models and DynamoDB integrations as the MVP grows.
- `frontend/` is a Next.js (v15) + TypeScript + Tailwind setup; `src/app` holds the landing page, `public/` stores shared assets, and `next.config.mjs` tweaks unoptimized images.
- `infra/` contains Terraform v1+ definitions (ACM, CloudFront, S3, WAF, etc.); the tracked `terraform.tfstate*` captures the current environment—avoid editing it manually and treat it as read-only.

## Build, Test, and Development Commands
- `python -m pip install -r backend/requirements.txt` installs the backend dependencies spelled out in `backend/requirements.txt`.
- `uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000` spins up the FastAPI app for local testing (run from repository root).
- `cd frontend && npm install` then `npm run dev` starts Next.js in dev mode; `npm run build` prepares a production bundle, `npm run start` serves it, and `npm run lint` enforces the built-in ESLint config.
- `cd infra && terraform init` followed by `terraform plan`/`terraform apply` manages AWS infrastructure; always review the plan output and check for drift before applying.

## Coding Style & Naming Conventions
- Favor two-space indentation, PascalCase for React components, camelCase for hooks/props, and descriptive kebab-case for Tailwind utility classes.
- Keep the backend in snake_case where Python idioms require it and append type annotations for public functions when practical.
- Rely on the existing ESLint config (`frontend/package.json` scripts) to flag missing imports or inconsistent syntax; run `npm run lint -- --fix` to auto-correct trivial issues.

## Testing Guidelines
- No automated test suites are included yet; rely on manual smoke tests against the Next.js UI and FastAPI endpoints.
- Follow future conventions by co-locating tests (e.g., `frontend/src/__tests__`), pluralizing files to mirror the component name, and naming them `*.test.tsx`.
- Re-run `npm run lint` before pushing to catch regressions that a missing test suite might overlook.

## Commit & Pull Request Guidelines
- Adopt readable, imperative commit titles like `feat(frontend): wire up hero banner` or `chore(infra): refresh provider versions`; scope the type to the subsystem touched.
- Describe each PR with a one-paragraph summary, a testing checklist (commands executed), and linked issues or tickets; include screenshots if the UI changes significantly.
- For Terraform work describe the `terraform plan` impact and mention any manual steps needed to sync state; avoid PRs that modify `infra/terraform.tfstate*`.

## Security & Configuration Tips
- Keep secrets out of the repo: use `.env.local` for Next.js and AWS named profiles or env vars for Terraform provider credentials.
- Do not commit changes to `infra/terraform.tfstate` or `terraform.tfstate.backup`; rehydrate state with `terraform state pull` when you need to inspect it.
- Document new configuration requirements in this guide so future contributors know which environment variables or AWS resources to provision.
