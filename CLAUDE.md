# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Timeless** is a Flutter mobile application for digital/tech job search across Europe. It's primarily an Android app with Firebase backend integration, built using GetX for state management and supporting both online and offline demo modes.

## Development Commands

### Core Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run the app (main version)
flutter run

# Run offline demo version
flutter run lib/main_demo.dart

# Analyze code
flutter analyze

# Run tests
flutter test

# Build for Android
flutter build apk
flutter build appbundle

# Clean build artifacts
flutter clean
```

### Firebase Setup
The app requires Firebase configuration with the following services:
- Firebase Auth (Google, GitHub, Email/Password, Anonymous)
- Cloud Firestore (job data, user profiles)
- Firebase Storage (CV/document uploads)
- Firebase Messaging (push notifications)

## Architecture & Code Organization

### Directory Structure
- `lib/main.dart` - Main app entry point with Firebase initialization
- `lib/main_demo.dart` - Offline demo mode entry point
- `lib/screen/` - All UI screens organized by feature
- `lib/service/` - Core services (HTTP, preferences)
- `lib/common/` - Shared widgets and utilities
- `lib/api/` - API-related code and models
- `lib/utils/` - Utility classes and constants
- `lib/dev/` - Development utilities and demo data

### Key Architectural Patterns
- **State Management**: GetX (`get: ^4.7.2`) for routing and state
- **Navigation**: GetX routing with named routes in `AppRes`
- **Data Persistence**: SharedPreferences via `PrefService`
- **HTTP Requests**: Custom `HttpServices` wrapper
- **Firebase Integration**: Full Firebase suite with proper initialization

### Screen Architecture
Screens follow a consistent pattern:
- Each screen has its own directory under `lib/screen/`
- Most complex screens have separate controller files (`*_controller.dart`)
- Screen classes typically extend `StatefulWidget` or `StatelessWidget`
- Controllers use GetX patterns for reactive state management

### Authentication Flow
- Multiple auth providers: Google Sign-In, GitHub, Email/Password
- Guest mode via Firebase Anonymous auth
- Auth state managed globally through Firebase Auth
- User preferences stored via `PrefService`

### Offline Demo Mode
- Alternative entry point (`main_demo.dart`)
- Local job data from `assets/jobs.json`
- No network dependency for demo presentations
- Simulated user flows for showcase purposes

## Development Guidelines

### Firebase Configuration
- Never commit `google-services.json` or Firebase config files
- Firebase options are generated and maintained in `lib/firebase_options.dart`
- Project uses Firebase BoM for version management in Android build files

### Code Style
- Follows `flutter_lints` rules defined in `analysis_options.yaml`
- Some lints disabled: `deprecated_member_use`, `unused_import`
- French comments are acceptable (legacy code)
- Consistent use of GetX patterns for navigation and state

### Asset Management
- Images: `assets/images/`
- Icons: `assets/icons/`
- Demo data: `assets/jobs.json`
- Sample CV: `assets/cv/demo_cv.pdf`

### Testing
- Basic widget test setup in `test/widget_test.dart`
- Use `flutter test` to run tests
- Additional test files should follow Flutter testing conventions

### Platform-Specific Notes
- Primary target: Android (minSdk 23, targetSdk from Flutter)
- iOS and Web configurations exist but Android is the main platform
- Uses Kotlin for Android-specific code
- Firebase BoM manages Firebase dependency versions

### Common Development Tasks
- **Adding new screens**: Create under `lib/screen/[feature]/` with controller if needed
- **New API endpoints**: Add to `lib/api/` with corresponding models
- **Shared widgets**: Place in `lib/common/widgets/`
- **Route definitions**: Update `AppRes` utility class
- **Offline demo data**: Modify `assets/jobs.json`

### Dependencies to Note
- **UI**: Google Fonts, Cupertino Icons, Salomon Bottom Bar
- **State**: GetX framework
- **Backend**: Full Firebase suite
- **File handling**: File Picker, PDF Viewer, Image Picker
- **Networking**: HTTP package with custom service wrapper
- **Storage**: Shared Preferences for local data persistence