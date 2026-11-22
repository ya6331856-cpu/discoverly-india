# DISCOVERLY — Google Play Data safety preparation

This is an implementation-based draft, not a substitute for reviewing Google's exact Data safety definitions before submitting.

## Data used by the current app

- **Email address:** used for account creation, authentication and account recovery.
- **Name:** optional display name provided by the user.
- **User-generated content:** business profile information, services, customer requirements, quotations and content reports submitted through the app.
- **User-entered city/state:** used to describe business locations and requirements for local matching. The app does not request precise GPS location.
- **App activity:** business search queries and selected business results may be recorded to operate and improve discovery.

## Purpose
- App functionality and account management.
- Business discovery, requirement matching and quotation workflows.
- Platform safety, moderation, fraud prevention and support.

## Sharing and service providers
DISCOVERLY uses Supabase as its hosted authentication and database provider. Review Google's definition of “collected” versus “shared” and the current service-provider agreement before answering the form. Do not claim that no data is processed by a third party.

## Security
- Supabase API calls use HTTPS/TLS for data in transit.
- Database Row Level Security restricts access to account and business records.
- The app has an in-app account deletion control and a server-side deletion function.
- Do not claim end-to-end encryption; this is not a messaging app and that feature is not implemented.

## Not requested by this release
- Precise GPS location permission.
- Contacts, call logs, SMS, camera or microphone.
- Advertising ID or advertising SDK.
- Payment card or bank account information.
- Health data.

## Before submitting the Data safety form
- [ ] Confirm the production website and privacy policy describe the same data practices as the Android app.
- [ ] Confirm whether user-entered city/state falls into a location category under the current Play Console definitions.
- [ ] Confirm the service-provider treatment for Supabase under Google's current definitions.
- [ ] Confirm account deletion and external deletion URL work end to end.
- [ ] Re-check this document if analytics, crash reporting, ads, file uploads, push notifications or payment features are added.
