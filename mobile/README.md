# DISCOVERLY Android app

Flutter Android client for the existing DISCOVERLY Supabase project.

## Build locally
1. Install Flutter stable and Android Studio / Android SDK.
2. From this folder run:
   `flutter create --platforms=android --org=in.discoverly .`
3. Run `flutter pub get`.
4. Run `flutter run` on an Android device, or `flutter build apk --release`.

The app uses the same Supabase project as the website. Email confirmation remains link-based, matching the website's current Auth configuration. The publishable key is designed for public clients; database access remains controlled by RLS. Never add a service-role key to this app.

## Current scope
Android-first MVP: email/password signup and login, business search, buyer requirement posting/listing, opportunity inbox, notifications and account/logout. Business onboarding, verification document uploads, quotation submission, push notifications and app-store signing are follow-up work. Real-account end-to-end testing is still required.
