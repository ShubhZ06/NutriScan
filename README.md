<div align="center">

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/Gemini_AI-4285F4?style=for-the-badge&logo=google&logoColor=white" />
<img src="https://img.shields.io/badge/Open_Food_Facts-40C100?style=for-the-badge&logo=openfoodfacts&logoColor=white" />

# 🥗 NutriScan

**Scan any food product. Know what's actually in it.**

NutriScan combines barcode scanning, OCR, and AI to give you an instant ingredient safety verdict — green, yellow, or red.

[Getting Started](#-local-setup) · [Contributing](#-contributing) · [Security](SECURITY.md) · [License](LICENSE)

</div>

---

## What It Does

Point your camera at a barcode and NutriScan pulls the full product data from Open Food Facts, then runs the ingredient list through Gemini for an AI-powered safety verdict. No barcode? The OCR fallback reads the label directly. Every scan is saved to your personal history in Firestore.

| Feature | Details |
|---|---|
| 🔐 Auth | Firebase email/password |
| 📷 Scanning | Mobile Scanner (barcode) + ML Kit (OCR fallback) |
| 🌐 Product Data | Open Food Facts API |
| 🤖 AI Analysis | Gemini — traffic-light verdict (🟢 / 🟡 / 🔴) |
| 🗂️ History | Per-user scan history in Cloud Firestore |
| 💾 Local State | Onboarding + profile via SharedPreferences |

---

## Tech Stack

```
Flutter + Dart
├── Firebase Core, Auth, Firestore
├── Open Food Facts API
├── Gemini API (google_generative_ai)
├── Google ML Kit Text Recognition
└── SharedPreferences
```

---

## Project Structure

```
lib/
├── main.dart              # App entry and routing
├── screens/               # UI screens
├── services/              # Auth, Firestore, Gemini, OCR, Open Food Facts
├── models/                # Domain models
└── widgets/               # Reusable UI components
```

---

## 🚀 Local Setup

> **Before you start:** This repo ships with no API keys and no Firebase config. You bring your own.

### Prerequisites

- Flutter SDK
- Android Studio or Xcode
- A Firebase project you control
- A Gemini API key

---

### 1. Clone and install

```bash
git clone https://github.com/ShubhZ06/NutriScan.git
cd NutriScan
flutter pub get
```

---

### 2. Configure Firebase

1. Create a Firebase project and enable **Authentication** (Email/Password) and **Firestore**.
2. Add an Android app — use your package name.
3. Download `google-services.json` → place it at `android/app/google-services.json`.
4. For iOS/macOS, add an Apple app and place `GoogleService-Info.plist` at `ios/Runner/GoogleService-Info.plist`.

> Both config files are git-ignored. Never commit them.  
> See `android/app/google-services.example.json` for the expected file structure.

---

### 3. Configure your Gemini key

Copy the example env file and fill in your values:

```bash
cp .env.example .env.local
```

```env
# .env.local
GEMINI_API_KEY=your_gemini_api_key
GEMINI_MODEL=gemini-2.5-flash
```

Run the app:

```bash
flutter run --dart-define-from-file=.env.local
```

Or pass defines inline:

```bash
flutter run \
  --dart-define=GEMINI_API_KEY=your_gemini_api_key \
  --dart-define=GEMINI_MODEL=gemini-2.5-flash
```

---

### 4. Build a release APK

```bash
flutter build apk --release --dart-define-from-file=.env.local
```

---

## 🔒 Secret Safety

- **Never commit** API keys, Firebase config files, or signing keystores.
- Keep all secrets in local, git-ignored files (`.env.local`, `google-services.json`, `GoogleService-Info.plist`).
- If a key was ever committed — even briefly — rotate it immediately.
- Use a separate Firebase project for dev/test work.

See [SECURITY.md](SECURITY.md) for the full disclosure and handling policy.

---

## 🤝 Contributing

Contributions are welcome. Quick flow:

1. Fork the repo and create a feature branch.
2. Implement your changes with tests where possible.
3. Make sure `flutter analyze` passes and all tests are green.
4. Open a PR with a clear summary of what changed and why.

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.

---

## License

Licensed under the terms in [LICENSE](LICENSE).
