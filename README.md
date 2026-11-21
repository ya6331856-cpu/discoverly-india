# DISCOVERLY India

India-first, two-sided business discovery network: customers discover businesses, and businesses discover relevant customers and opportunities.

## Stack
- Next.js 16, React 19, TypeScript
- Supabase Postgres, Auth, Row Level Security
- Supabase SSR cookie-based session refresh

## Supabase
Project ref: `nkxnexjwbdopycvxwomn`
Dashboard: https://supabase.com/dashboard/project/nkxnexjwbdopycvxwomn

## Setup
1. Install Node.js 20.9+.
2. Copy `.env.example` to `.env.local`.
3. Add the Supabase publishable key (never use a service-role key in frontend code).
4. Run `npm install` and `npm run dev`.

The initial homepage search calls the existing `public.search_businesses` RPC. Search results will be empty until businesses publish profiles and offerings.

This is an initial foundation, not a production launch. Authentication UI, business onboarding, buyer requirements, quotations, secure media storage, moderation, tests and deployment still need implementation and verification.
