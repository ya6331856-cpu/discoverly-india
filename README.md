# DISCOVERLY India

India-first, two-sided business discovery network: customers discover businesses, and businesses discover relevant customers and opportunities.

## Stack
- Next.js 16, React 19, TypeScript
- Supabase Postgres, Auth, Storage and Row Level Security
- Supabase SSR cookie-based session refresh

## Supabase project
Project ref: \`nkxnexjwbdopycvxwomn\`
Dashboard: https://supabase.com/dashboard/project/nkxnexjwbdopycvxwomn

## Local setup
1. Install Node.js 20.9 or newer.
2. Copy \`.env.example\` to \`.env.local\`.
3. Set \`NEXT_PUBLIC_SUPABASE_URL\` and \`NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY\` using the Supabase project values.
4. In Supabase Authentication URL Configuration, add \`http://localhost:3000/auth/callback\` to the allowed redirect URLs for local email confirmation.
5. Run \`npm install\`, then \`npm run dev\`.

Never place a Supabase service-role or secret key in the browser, a \`NEXT_PUBLIC_*\` variable, or GitHub source.

## Implemented
- Responsive India-wide business discovery homepage with industry and location filters.
- Keyword/trigram search using \`public.search_businesses\`.
- Email/password signup and login with Supabase Auth and email-confirmation callback.
- Account page with a signed-in user's business portfolio.
- Business registration using \`public.create_business_profile\`; new companies begin as private drafts.
- Business profile management, contact/location editing and company logo upload.
- Published profile edits are automatically returned to platform review.
- Private business verification document uploads with reviewer-only access.
- Manual verification workflow for registration evidence, GSTIN supporting documents, address, website and references.
- Buyer requirement form for purchase, service, partnership, distribution and other requests.
- Automatic matching against published businesses by industry and public city/state location.
- Buyer workspace to review matches and incoming quotations.
- Business opportunity inbox for matching leads and quotation submission.
- Quotation acceptance/rejection by the buyer; only one quote can be accepted per lead.
- In-app notifications for new opportunities, quotations, company review and verification status.
- Private user reports for businesses, offerings and customer reviews.
- Moderator workspace for listing approvals, verification decisions, review moderation and user reports.
- RLS policies for public/private content, account ownership, reports and notification recipients.
- Private schema contains narrowly scoped security-definer helpers; latest Security Advisor check reported no security lints.
- GitHub Actions validates TypeScript, ESLint and production build on pushes and pull requests.

## Main routes
- \`/\` — business discovery
- \`/auth\` — signup and login
- \`/account\` — account and business portfolio
- \`/business/register\` — create a business draft
- \`/business/[companyId]/manage\` — manage business profile
- \`/business/[companyId]/verification\` — submit verification evidence
- \`/requirements/new\` — post a buyer requirement
- \`/requirements\` — buyer matches and quotations
- \`/opportunities\` — matched opportunities for business members
- \`/notifications\` — in-app notifications
- \`/report\` — report a public business, product/service or review
- \`/admin\` — restricted reviewer/moderator console

## Current limits / launch checklist
This is a development foundation, not a public production launch. The site has not been deployed. Configure the deployed domain in Supabase Auth URL Configuration and set the two public Supabase environment variables in the hosting provider. A user with an authorized \`admin\` or \`moderator\` role must be securely provisioned before the review console can be used. Do not grant roles from the public frontend.

No real test mailbox, company onboarding, buyer-to-business match, document upload, notification delivery or quote acceptance has been end-to-end tested with production test accounts. Notifications are in-app only; email/SMS/push delivery is not configured. GSTIN and government registration checks are human evidence review only; there is no automatic government registry/API connection. Add rate limits, abuse monitoring, backups, public company detail pages, and a complete production smoke test before launch.
