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
- Responsive business discovery homepage with real seeded industry filters.
- Keyword and location search using the existing `public.search_businesses` RPC.
- Email/password signup and login with Supabase Auth.
- Email confirmation callback route.
- Profile and customer-role creation trigger on new auth users.
- Account page with a signed-in user's business portfolio.
- Business registration using the `public.create_business_profile` RPC.
- Company, profile/contact, city/state location and category relations are created in one database transaction.
- Newly registered businesses start as private `draft` profiles and do not enter public search until reviewed and published.
- GitHub Actions runs TypeScript, ESLint and production build checks on pushes and pull requests.

## Current limits
This is an implementation foundation, not a public production launch. Email redirect URLs must be configured for the deployed domain. No real signup/confirmation has been completed with a test mailbox yet. Secure logo/document storage, business verification workflow, requirement posting, quotations, moderation UI, and public company detail pages still need implementation and testing.
