# DISCOVERLY India

India-first, two-sided business discovery network: customers discover businesses, and businesses discover relevant customers and opportunities.

## Stack
- Next.js 16, React 19, TypeScript
- Supabase Postgres, Auth, Row Level Security
- Supabase SSR cookie-based session refresh

## Supabase project
Project ref: `nkxnexjwbdopycvxwomn`
Dashboard: https://supabase.com/dashboard/project/nkxnexjwbdopycvxwomn

## Local setup
1. Install Node.js 20.9 or newer.
2. Copy `.env.example` to `.env.local`.
3. Set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` using the Supabase project values.
4. In Supabase Authentication URL Configuration, add `http://localhost:3000/auth/callback` to the allowed redirect URLs for local email confirmation.
5. Run `npm install`, then `npm run dev`.

Never place a Supabase service-role or secret key in the browser, a `NEXT_PUBLIC_*` variable, or GitHub source.

## Implemented
- Responsive India-wide business discovery homepage with industry and location filters.
- Keyword/trigram search using `public.search_businesses`.
- Email/password signup and login with Supabase Auth and email-confirmation callback.
- Profile and customer-role creation trigger on new auth users.
- Account page with a signed-in user's business portfolio.
- Business registration using `public.create_business_profile`; new companies begin as private drafts.
- Buyer requirement form for purchase, service, partnership, distribution and other requests.
- Automatic matching against published businesses by industry and public city/state location.
- Buyer workspace to review matches and incoming quotations.
- Business opportunity inbox for matching leads and quotation submission.
- Quotation acceptance/rejection by the buyer; only one quote can be accepted per lead.
- RLS rules that keep requirements visible to the buyer and matched company members only.
- Company owners can submit a draft for review but cannot self-publish; publication is reserved for platform reviewers.
- Public location view uses caller RLS and exposes only city-level location fields.
- Private schema contains narrowly scoped security-definer helpers; no security-advisor lints currently reported.
- GitHub Actions validates TypeScript, ESLint and production build on pushes and pull requests.

## Main routes
- `/` — business discovery
- `/auth` — signup and login
- `/account` — account and business portfolio
- `/business/register` — create a business draft
- `/requirements/new` — post a buyer requirement
- `/requirements` — buyer matches and quotations
- `/opportunities` — matched opportunities for business members

## Current limits / launch checklist
This is an implementation foundation, not a public production launch. Configure the deployed domain in Supabase Auth URL Configuration and set the two public Supabase environment variables in the hosting provider. No real mailbox signup, company onboarding, buyer-to-business match, or quote acceptance has been end-to-end tested with production test accounts yet. Secure logo/document storage, company edit screens, business verification submission/review UI, admin moderation UI, notifications, anti-spam/rate limits, public company detail pages, and live deployment still need work.
