# DISCOVERLY — Google Play release checklist

## Release identity
- App name: DISCOVERLY
- Android package ID: com.discoverly.app (fixed; do not change after app creation)
- Version: 1.0.0 / version code 1
- Target API: 36
- Play upload format: signed Android App Bundle (.aab)

## Build and signing
- [ ] Generate a private upload keystore and keep an encrypted backup offline.
- [ ] Add the four DISCOVERLY_UPLOAD_* repository secrets listed in mobile/README.md.
- [ ] Run Android Actions and verify a signed AAB is produced.
- [ ] Install the APK on a physical Android device and test sign-up, email confirmation, Terms acceptance, sign-in, search, business details/contact links, report listing, block/unblock owner, business draft, requirement posting, lead inbox, quote submit/review, notifications, admin report moderation, profile editing, sign-out and account deletion.
- [ ] Verify the Play Console App Integrity page accepts the upload certificate.

## Play Console setup
- [ ] Create app → App name DISCOVERLY → default language English → App or game: App → Free (unless a paid model is intentionally selected).
- [ ] Upload the signed AAB to Internal testing first.
- [ ] Verify users must accept Terms of Use before posting, can report content, can block/unblock business owners, and moderators can review reports.
- [ ] Complete Store listing: short description, full description, 512×512 icon, feature graphic 1024×500, phone screenshots, contact email and website.
- [ ] Configure NEXT_PUBLIC_SUPPORT_EMAIL in the website hosting environment with the approved public contact email; redeploy the website.
- [ ] Verify the live /privacy, /terms and /delete-account pages on the deployed public domain.
- [ ] Add the live Privacy Policy URL and external Account Deletion URL.
- [ ] Complete App access instructions for reviewers (provide a test account if login is required; never share a personal/admin account).
- [ ] Complete Ads, App content, target audience, content rating, Data safety, Data deletion, and government/financial declarations truthfully.
- [ ] Review pre-launch report and resolve crashes/ANRs before production.

## Account testing eligibility
Google requires personal developer accounts created after 13 November 2023 to run a closed test with at least 12 testers opted in continuously for 14 days before applying for production access. Internal testing can be used first, but it does not replace that closed-test requirement. Check the account type and creation date shown in Play Console.

## Known launch limitations
- The business directory has no published real listings yet. Launch messaging must be honest about the early network; never seed fabricated companies, reviews, ratings or verification badges.
- Push notifications, complete profile editing, document-upload UX, full business profile detail pages and a full real-account QA pass are not yet confirmed complete.
- Google Play review and production access are controlled by Google; upload does not guarantee approval or same-day public availability.
