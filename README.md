# 🥗 NutriScan - AI Powered Nutrition Scanner App

**NutriScan** is a modern, AI-enhanced nutrition scanning app built with **Flutter**. It allows users to scan food barcodes, retrieve accurate nutritional data, highlight harmful ingredients, and receive personalized AI health insights. Designed with an elegant iOS-style interface, NutriScan aims to promote smarter, health-conscious choices with a premium user experience.

![NutriScan UI Preview](https://github.com/ShubhZ06/NutriScan/assets/your-screenshot.png)

---

## 📱 Features

- 🔍 **Barcode Scanning** — Instantly scan products using your camera.
- 🍽️ **Nutritional Details** — View calories, macros, additives, and more from Open Food Facts API.
- ⚠️ **Harmful Ingredient Alerts** — Highlights banned or unhealthy substances.
- 🧠 **AI Assistant** — Get personalized dietary advice and food safety analysis.
- 🕶️ **iOS-Style UI** — Built with glassmorphism, smooth animations, and toggleable light/dark themes.
- 📚 **Scan History** — Stores your previous scans locally using shared preferences.
- 🔐 **Secure & Offline Support** — Works seamlessly with cached data even without internet.
- 🌍 **Dynamic Banned Substances List** — Pulled from remote source for real-time accuracy.

---

## 💻 Tech Stack

| Layer           | Technology         |
|----------------|--------------------|
| Frontend       | Flutter (Dart)     |
| Design         | Glassmorphism, Cupertino, Animated UI |
| Backend API    | Open Food Facts API + Flask (for AI) |
| AI Features    | Ingredient analysis & recommendation |
| Local Storage  | Shared Preferences |
| State Mgmt     | Provider           |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio / VS Code
- Emulator or physical device
- Flask backend (optional, for AI features)

### Run the App
```bash
git clone https://github.com/ShubhZ06/NutriScan.git
cd NutriScan
flutter pub get
flutter run
