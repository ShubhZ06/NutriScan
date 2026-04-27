# NutriScan

NutriScan is a Flutter app for food product scanning and ingredient safety analysis.

It combines:
- Barcode lookup via Open Food Facts
- OCR fallback via Google ML Kit
- AI ingredient interpretation via Gemini
- User authentication and scan history via Firebase

## Open Contribution Status

This repository is prepared for public contribution.

What this means:
- No production API keys are stored in this repo.
- No private Firebase config is committed.
- Contributors must use their own Firebase project and Gemini key.

## Features

- Firebase email/password authentication
- Barcode scanning with Mobile Scanner
- Product details from Open Food Facts
- AI ingredient analysis with traffic-light verdict (green/yellow/red)
- OCR fallback for labels when barcode data is missing
- Per-user scan history in Cloud Firestore
- Local onboarding and profile state in SharedPreferences

## Tech Stack

- Flutter + Dart
- Firebase Core, Auth, Firestore
- Open Food Facts API
- Gemini API (`google_generative_ai`)
- Google ML Kit Text Recognition
- SharedPreferences

## Project Structure

- `lib/main.dart` - app entry and routing
- `lib/screens/` - UI screens
- `lib/services/` - service layer (Auth, Firestore, Gemini, OCR, Open Food Facts)
- `lib/models/` - domain models
- `lib/widgets/` - reusable UI components

## Local Setup

### 1. Prerequisites

- Flutter SDK installed
- Android Studio or Xcode (for emulator/simulator)
- A Firebase project you control
- A Gemini API key you control

### 2. Clone and install dependencies

```bash
git clone https://github.com/ShubhZ06/NutriScan.git
cd NutriScan
flutter pub get
```

### 3. Configure Firebase with your own project

1. Create your own Firebase project.
2. Enable Authentication (Email/Password) and Firestore.
3. Add an Android app in Firebase with your package name.
4. Download `google-services.json` and place it at `android/app/google-services.json`.
5. If you build iOS/macOS, also add an Apple app in Firebase and place `GoogleService-Info.plist` at `ios/Runner/GoogleService-Info.plist`.

Notes:
- `android/app/google-services.json` is intentionally ignored by git.
- `ios/Runner/GoogleService-Info.plist` is intentionally ignored by git.
- Do not commit your Firebase config files.
- You can use `android/app/google-services.example.json` as a placeholder reference for file structure.

### 4. Configure Gemini key (safe local approach)

Create a local file like `.env.local` (this file is git-ignored). The easiest way is to copy `.env.example` and edit values:

```bash
copy .env.example .env.local
```

Then set your key and model:

```env
GEMINI_API_KEY=your_gemini_api_key
GEMINI_MODEL=gemini-2.5-flash
```

Run the app:

```bash
flutter run --dart-define-from-file=.env.local
```

You can also pass defines directly:

```bash
flutter run --dart-define=GEMINI_API_KEY=your_gemini_api_key --dart-define=GEMINI_MODEL=gemini-2.5-flash
```

## Build

Release APK example:

```bash
flutter build apk --release --dart-define-from-file=.env.local
```

## Secret and Resource Safety

- Never commit real keys, tokens, service configs, or signing files.
- Keep secrets only in local ignored files (`.env.local`, platform service config files).
- Rotate any key immediately if it was ever committed.
- Use separate dev/test Firebase projects for community work.

See [SECURITY.md](SECURITY.md) for disclosure and handling policy.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

Quick flow:
1. Fork and create a feature branch.
2. Implement changes with tests where possible.
3. Ensure `flutter analyze` and tests pass.
4. Open a PR with a clear summary.

## License

This project is licensed under the [LICENSE](LICENSE) file.
