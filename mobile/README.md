# DISCOVERLY Android app

Flutter Android client for the existing DISCOVERLY Supabase project.

## Build

The GitHub Actions workflow generates the Android project, bundles Inter locally, applies the launcher icon, runs Flutter analysis, and builds a release APK for device QA. It builds a Google Play upload-signed AAB only after the upload-key GitHub secrets are configured.

## Google Play upload signing

1. Generate a private upload keystore locally. Keep the JKS file and passwords safe; never commit them or send them in chat.
2. Base64-encode the keystore file.
3. In GitHub, open the repository Settings → Secrets and variables → Actions and add these repository secrets:
   - DISCOVERLY_UPLOAD_KEYSTORE_BASE64 — base64 text of the JKS file
   - DISCOVERLY_UPLOAD_KEYSTORE_PASSWORD — keystore password
   - DISCOVERLY_UPLOAD_KEY_ALIAS — alias used when generating the key
   - DISCOVERLY_UPLOAD_KEY_PASSWORD — key password
4. Push a change under mobile/ or run the Android workflow manually.
5. Download discoverly-android-builds; the signed Play AAB is app-release.aab.

Important: The package ID is com.discoverly.app. Do not change it after creating the app in Play Console. The workflow targets Android API 36. The AAB signing key is an upload key; Google Play App Signing protects the final app-signing key.

## Supabase

The app uses the existing DISCOVERLY Supabase project. The publishable key is intended for client apps; database access is controlled by Row Level Security. Never add a Supabase secret/service-role key to the mobile app.

## Current app scope and release caveats

Email/password authentication, business discovery, requirements, leads, quotations, notifications, business onboarding, and the admin queue are implemented to MVP level. Real-account end-to-end testing is still required. The marketplace currently has no imported/published business inventory, so discovery starts empty until real businesses onboard or approved data is imported and owner-confirmed. Do not use fake listings or reviews.

Before public release, complete the Play Console privacy policy, account deletion, Data safety, content rating, store listing, and testing declarations. Verify all account-deletion paths and the live privacy/deletion URLs before submission.
