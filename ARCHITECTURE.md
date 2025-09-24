# Timeless - Application Architecture

## 🏗️ Project Structure

```
timeless/
├── android/                    # Android-specific configuration
├── ios/                       # iOS-specific configuration (if applicable)
├── assets/                    # Static assets (images, fonts, etc.)
│   ├── images/               # Application images and icons
│   └── jobs.json             # Demo job data for offline mode
├── lib/                      # Main Flutter application code
│   ├── api/                  # External API services
│   ├── common/               # Shared components and utilities
│   ├── dev/                  # Development tools and demo data
│   ├── screen/               # UI screens organized by feature
│   ├── service/              # Business logic and services
│   ├── test/                 # Testing utilities
│   ├── utils/                # Constants, styles, and helpers
│   └── main.dart             # Application entry point
├── scripts/                  # Utility scripts
├── screenshots/              # Application screenshots
└── web/                      # Web configuration (if applicable)
```

## 📁 Key Directories Breakdown

### `/lib/api/`
Contains external API integrations and data models.
- `api_country.dart` - Country data API service
- `model/api_country_model.dart` - Country data models

### `/lib/common/`
Shared widgets and utilities used across the application.
- `widgets/accessibility_fab.dart` - Accessibility floating action button
- `widgets/back_button.dart` - Custom back button component
- `widgets/common_error_box.dart` - Error display widget
- `widgets/common_loader.dart` - Loading indicator component
- `widgets/common_text_field.dart` - Reusable text input field
- `widgets/helper.dart` - UI helper functions
- `widgets/language_toggle.dart` - Language switching component

### `/lib/screen/`
All application screens organized by feature areas:

#### Authentication (`auth/`)
- `sign_in_screen/` - User login functionality
- `sign_up/` - User registration process
- `forgot_password/` - Password recovery
- `otp_page/` - OTP verification
- `reset_password_page/` - Password reset

#### Dashboard (`dashboard/`)
- `dashboard_screen.dart` - Main navigation container
- `home/` - Home screen with job recommendations
- `applications/` - User's job applications tracking
- `widget.dart` - Dashboard-specific widgets

#### Job Management (`job_detail_screen/`)
- `job_detail_screen.dart` - Individual job viewing
- `job_detail_upload_cv_screen/` - CV upload for applications
- `job_details_success_or_fails/` - Application result screens
- `job_detail_widget/` - Job-related UI components

#### Manager Section (`manager_section/`)
Employer/HR manager specific features:
- `manager_home_screen/` - Manager dashboard
- `auth_manager/` - Manager authentication flow
- `applicants_detail_screen/` - Candidate profile viewing
- `Jobdetails/` - Job posting management
- `Profile/` - Manager profile management
- `Notification/` - Manager notifications

#### Profile (`profile/`)
- `profile_screen.dart` - User profile display
- `edit_profile_user/` - Profile editing functionality

### `/lib/service/`
Business logic and external service integrations:
- `google_auth_service.dart` - Google Sign-In implementation
- `translation_service.dart` - Multi-language support
- `accessibility_service.dart` - Accessibility features
- `auto_translation_service.dart` - Automatic translation
- `http_services.dart` - HTTP client configuration
- `pref_services.dart` - SharedPreferences wrapper

### `/lib/utils/`
Application constants, styles, and utility functions:
- `color_res.dart` - Centralized color definitions
- `app_style.dart` - Text styles and typography
- `asset_res.dart` - Asset path constants
- `string.dart` - String constants and localization
- `pref_keys.dart` - SharedPreferences key constants
- `app_res.dart` - General app resources

## 🎯 State Management

The application uses **GetX** for state management, providing:
- **Controllers**: Business logic and state management
- **Dependency Injection**: Service locator pattern
- **Route Management**: Navigation handling
- **Reactive Programming**: Observable state updates

### Controller Pattern
Each major screen has an associated controller:
- `HomeController` - Home screen state management
- `DashBoardController` - Main navigation state
- `SignInController` - Authentication logic
- `JobDetailController` - Job detail interactions

## 🔐 Authentication Flow

```
1. First Screen → Introduction/Onboarding
2. Authentication Options:
   - Google Sign-In
   - Email/Password
   - Guest Mode (Anonymous)
3. User Role Detection:
   - Job Seeker → Dashboard
   - Employer/Manager → Manager Dashboard
4. Profile Completion (if required)
```

## 🗄️ Data Layer

### Firebase Integration
- **Authentication**: User sign-in/sign-up
- **Firestore**: Job data, user profiles, applications
- **Storage**: CV uploads, profile images
- **Messaging**: Push notifications

### Local Storage
- **SharedPreferences**: User preferences, tokens
- **Local Assets**: Demo data, static content

## 🎨 UI/UX Architecture

### Design System
- **Colors**: Centralized in `color_res.dart`
- **Typography**: Google Fonts (Poppins) via `app_style.dart`
- **Components**: Reusable widgets in `/common/widgets/`
- **Themes**: Material Design 3 with custom branding

### Accessibility Features
- Screen reader support
- High contrast mode
- Font scaling support
- Color-blind friendly design
- Voice navigation compatibility

## 🚀 Navigation Structure

```
Main App
├── Splash Screen
├── Introduction/Onboarding
├── Authentication
│   ├── Sign In
│   ├── Sign Up
│   └── Password Recovery
└── Main Application
    ├── Dashboard (Job Seekers)
    │   ├── Home
    │   ├── Applications
    │   ├── Profile
    │   └── Chat
    └── Manager Dashboard (Employers)
        ├── Home
        ├── Job Management
        ├── Applicants
        └── Profile
```

## 🧪 Testing Strategy

### Test Structure
- **Unit Tests**: Business logic validation
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end workflows
- **Screenshot Tests**: Visual regression testing

### Test Files Location
- `/test/` - Unit and widget tests
- `/integration_test/` - Integration tests
- `/scripts/screenshot_generator.dart` - Screenshot automation

## 🔧 Configuration Files

### Root Level
- `pubspec.yaml` - Dependencies and assets
- `firebase_options.dart` - Firebase configuration
- `main.dart` - Application entry point

### Platform Specific
- `android/app/build.gradle` - Android build configuration
- `android/app/google-services.json` - Firebase Android config
- `ios/Runner/GoogleService-Info.plist` - Firebase iOS config

## 📦 Key Dependencies

### Core
- `flutter` - UI framework
- `get` - State management and navigation
- `firebase_core` - Firebase initialization
- `cloud_firestore` - Database
- `firebase_auth` - Authentication

### UI/UX
- `google_fonts` - Typography
- `smooth_page_indicator` - Onboarding
- `salomon_bottom_bar` - Navigation
- `image_picker` - Media selection

### Utilities
- `http` - HTTP client
- `shared_preferences` - Local storage
- `country_picker` - Country selection
- `file_picker` - File selection

## 🌐 Internationalization

### Multi-language Support
- `translation_service.dart` - Core translation logic
- `auto_translation_service.dart` - Automatic translation
- `language_toggle.dart` - Language switching UI

### Supported Features
- Real-time language switching
- Auto-translation of dynamic content
- Right-to-left (RTL) language support
- Cultural date/number formatting

This architecture ensures scalability, maintainability, and a great user experience across all supported platforms.