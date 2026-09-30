# ScholarSetu - Flutter Android Prototype

This is the Flutter (Android-first) implementation of **ScholarSetu** (Smart India Hackathon 2026).
The app connects ST students with Ministry of Tribal Affairs (MoTA) scholarships using an offline-first architecture, multilingual support, and a unified rules engine.

## Status

All 18 UI screens and state management providers have been fully written!
- `main.dart`, `app.dart`, `router.dart`, `utils/app_theme.dart`
- 5 Data Models (`scheme_model.dart`, `application_model.dart`, `user_profile_model.dart`, etc.)
- 2 Providers (`app_provider.dart`, `language_provider.dart`)
- 18 Screens (Login, Home, Schemes, Track, Profile, Application Form, Documents, Grievance, Chatbot, Nodal Officer Dashboard, etc.)

## Prerequisites

1. Install Flutter (https://flutter.dev/docs/get-started/install)
2. Run `flutter doctor` to ensure Android Studio / Android SDK is set up correctly.

## Running the App

1. Open this directory (`scholar_setu_flutter`) in terminal.
2. Run `flutter create .` (if the android/ios folders are missing).
3. Run `flutter pub get` to install dependencies (Provider, GoRouter, SharedPreferences).
4. Run `flutter run` to launch on a connected Android device or emulator.

## Features Built

- **Multilingual UI:** Support for English, Hindi, Odia, Telugu, Tamil, Gujarati, Marathi, Bengali, Kannada, Malayalam, Santali, and Gondi.
- **Offline First:** Save applications as drafts while offline. Auto-sync queue mechanism ready.
- **Rules Engine:** Evaluates student profile (ST category, family income, education level) against 5 MoTA schemes.
- **Aadhaar eKYC (Simulated):** Form validation and OTP inputs.
- **DigiLocker Integration (Simulated):** Mock document fetching UI.
- **Grievance System:** Escalation workflow to Nodal Officers.
- **ScholarBot:** Keyword-based offline FAQ chatbot.

## Architecture

- **State Management:** `provider` (ChangeNotifier) with SharedPreferences for persistence.
- **Navigation:** `go_router` with ShellRoute for bottom navigation tabs and redirect-based auth guards.
- **Theming:** Custom `AppTheme` using the MoTA primary orange (`#FF6B35`).

Made by Team CipherGuard.
