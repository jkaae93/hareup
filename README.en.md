# Hareup (하릅)

[한국어](README.md)

**Every day, cared for together.** Hareup is a pet observation app that records small changes in water bowls and litter boxes with photos, and helps you watch over your pet's every day more carefully with AI. For guardians who can't always be there, records make sure changes don't go unnoticed.

Try it on the web: [https://hareup-mobile.web.app](https://hareup-mobile.web.app) · See the [PRD](docs/PRD.md) for product requirements.

## What Hareup does

- **Daily records**: photograph water bowls and cat litter boxes every day.
- **Change spotting**: treats small changes in drinking and litter use as clues to health.
- **AI assistance**: photo analysis and a health chatbot support your observations.
- **Family care**: create and invite a family to record and watch over pets together.

## Good to know first

- Water bowls cover cats and dogs; litter boxes cover standard cat litter boxes.
- In-app observations and chatbot answers are for reference only and don't replace veterinary care.
- Hareup doesn't claim 24/7 automatic monitoring or exact water-intake measurement.

## Current implementation status

Implemented feature-first structure, Pub workspace shared packages, email/password auth, family creation/invites/admin approval, and per-group Firestore/Storage repositories. Pets, water bowls, litter boxes, and analysis records are permanently stored in the selected approved group. The Meta Model API photo-analysis callable is also implemented, but function deployment and live API verification remain; the analysis-value display gate stays disabled until accuracy is verified. Device features on the settings screen and actual health-guidance review are also remaining work.

See `lib/features/<feature>/ARCHITECTURE.md` for each feature's design. Unimplemented parts of the design docs describe the target structure.

## Development

```sh
fvm install
fvm flutter pub get
fvm flutter run
fvm dart run build_runner build
fvm flutter analyze
fvm flutter test
```

Uses the Flutter stable version pinned in `.fvmrc` via FVM. Run `fvm install` after installing FVM. Run Widget Preview with `fvm flutter widget-preview start`. Previews are never connected to real Firebase or platform services.

## Firebase and external services

Uses the FlutterFire configuration and Emulator setup of the Firebase project `hareup-mobile`. `functions/` contains API-check and photo-analysis callables for approved-group members using the `META_MODEL_API` secret. Run `cd functions && npm install` before running the local Emulator, and set `META_MODEL_API=...` in `functions/.secret.local` if needed. That file is excluded from Git, and the Meta key is never stored in the app. Enable Email/Password auth in the Firebase Console, and make sure the `META_MODEL_API` secret is registered in the Firebase project before deploying Functions. Family policy: admin approval after invite, only admins can delete, approved members can add/edit.

Google/Apple/Kakao Firebase login adapters and login buttons are ready. Firebase/Google/Apple/Kakao Console and Android/iOS native setup must be completed by the operator following the [login provider setup guide](docs/auth-provider-setup.md). The Kakao Native App Key and Apple Services ID are passed via `--dart-define` and never committed to code.

## Web

Live URL: [https://hareup-mobile.web.app](https://hareup-mobile.web.app)

See the [Web setup guide](docs/web.md) for Web run/build and Firebase Web app registration. Web supports email and Firebase Google popup login; Apple/Kakao native login is mobile-only. Firebase Hosting deploy settings are in `firebase.json`.
