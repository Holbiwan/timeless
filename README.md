# Timeless Powered Job Matching Platform

<div align="center">
  <img src="assets/images/timeless_splash.png" alt="Timeless Logo" width="200"/>
  
  **Bridging the gap with timeless talent**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)](https://firebase.google.com/)
  [![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-3DDC84?style=for-the-badge)](https://flutter.dev/)
</div>

## 🌟 Overview

**Timeless** is a revolutionary AI-powered job matching platform built with Flutter that connects talented professionals with their dream opportunities. Our platform leverages advanced algorithms to provide personalized job recommendations, streamlined application processes, and real-time communication between job seekers and employers.

### 🎯 Key Features

- **🤖 AI-Powered Job Matching**: Intelligent algorithms that match candidates with relevant opportunities
- **⚡ Smart Apply**: One-click application system with AI-optimized profiles
- **💬 Real-time Chat**: Direct communication between candidates and employers
- **📊 Analytics Dashboard**: Comprehensive insights for both job seekers and employers
- **🌐 Multi-language Support**: Accessible in multiple languages with auto-translation
- **♿ Accessibility Features**: Built-in accessibility tools for inclusive user experience
- **🔐 Secure Authentication**: Firebase-based authentication with Google Sign-in integration

## 📱 Screenshots

<div align="center">
  <img src="screenshots/01_splash_screen.png" width="200" alt="Splash Screen"/>
  <img src="screenshots/05_dashboard_home.png" width="200" alt="Dashboard"/>
  <img src="screenshots/07_job_detail.png" width="200" alt="Job Detail"/>
  <img src="screenshots/11_smart_apply.png" width="200" alt="Smart Apply"/>
</div>

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: Version 3.0.0 or higher
- **Dart SDK**: Version 3.0.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Firebase Project** with Firestore, Authentication, and Storage enabled
- **Android/iOS Device** or Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/timeless.git
   cd timeless
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update `firebase_options.dart` with your Firebase configuration

4. **Run the application**
   ```bash
   flutter run
   ```

### 📸 Capturing Screenshots

To capture screenshots of all app screens:

```bash
# Make sure your device/emulator is connected
./scripts/capture_screenshots.sh
```

## 🏗️ Architecture

Timeless follows **Clean Architecture** principles with **GetX** state management:

```
lib/
├── 📁 api/                    # API services and models
├── 📁 common/                 # Shared widgets and utilities
├── 📁 screen/                 # UI screens organized by feature
│   ├── 📁 auth/              # Authentication screens
│   ├── 📁 dashboard/         # Main dashboard and home
│   ├── 📁 job_detail_screen/ # Job details and applications
│   ├── 📁 manager_section/   # Employer/manager features
│   └── 📁 profile/           # User profile management
├── 📁 service/               # Business logic and services
├── 📁 utils/                 # Constants, styles, and helpers
└── main.dart                 # Application entry point
```

## 🔑 Core Components

### 📋 Important Files

| File/Directory | Description |
|---------------|-------------|
| `lib/main.dart` | Application entry point and configuration |
| `lib/utils/color_res.dart` | Centralized color theme management |
| `lib/service/google_auth_service.dart` | Google authentication implementation |
| `lib/service/translation_service.dart` | Multi-language support service |
| `lib/service/accessibility_service.dart` | Accessibility features service |
| `lib/common/widgets/` | Reusable UI components |
| `lib/screen/dashboard/` | Main user dashboard and navigation |
| `lib/screen/auth/` | Authentication flow (sign in/up, forgot password) |
| `lib/screen/job_detail_screen/` | Job viewing and application features |
| `lib/screen/manager_section/` | Employer dashboard and job management |

### 🎨 Design System

- **Color Palette**: Royal Blue (#3B82F6), Golden Yellow (#FFD700), Vibrant Red (#DC2626)
- **Typography**: Google Fonts (Poppins) for consistent branding
- **Theme**: Light background (#F8FAFC) with high contrast for accessibility
- **Components**: Material Design 3 with custom branding elements

## 🛠️ Technologies & Dependencies

### Core Framework
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language
- **GetX**: State management and dependency injection

### Backend & Database
- **Firebase Auth**: User authentication
- **Cloud Firestore**: NoSQL database
- **Firebase Storage**: File storage for CVs and images
- **Firebase Messaging**: Push notifications

### UI & UX
- **Google Fonts**: Typography
- **Smooth Page Indicator**: Onboarding indicators
- **Salomon Bottom Bar**: Navigation bar
- **Image Picker**: Profile and document uploads

### Integrations
- **Google Sign-In**: OAuth authentication
- **HTTP**: API communications
- **Country Picker**: International phone numbers
- **File Picker**: Document uploads

## 👥 User Roles

### 🎓 Job Seekers
- Create and optimize profiles
- Browse and apply to jobs
- Use AI-powered job recommendations
- Track application status
- Communicate with employers
- Access career tips and resources

### 🏢 Employers/Managers
- Post job openings
- Review applications and candidate profiles
- Use AI-powered candidate matching
- Manage hiring pipeline
- Communicate with candidates
- Access hiring analytics

## 🔐 Security & Privacy

- **End-to-end Encryption**: Secure communication
- **Firebase Security Rules**: Database access control
- **Data Privacy**: GDPR-compliant data handling
- **Authentication**: Multi-factor authentication support
- **Secure Storage**: Encrypted local data storage

## 🌍 Accessibility & Internationalization

- **Screen Reader Support**: Full VoiceOver/TalkBack compatibility
- **High Contrast Mode**: Enhanced visibility options
- **Font Scaling**: Supports system font size preferences
- **Multi-language**: Auto-translation capabilities
- **Color Blind Friendly**: Accessible color palette

## 📊 Analytics & Monitoring

- **User Analytics**: Track engagement and usage patterns
- **Performance Monitoring**: Monitor app performance and crashes
- **A/B Testing**: Feature testing and optimization
- **Conversion Tracking**: Monitor application success rates

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests (with screenshots)
flutter test integration_test/
```

### Test Coverage
- **Unit Tests**: Business logic and services
- **Widget Tests**: UI components and screens
- **Integration Tests**: End-to-end user flows
- **Screenshot Tests**: Visual regression testing

## 🚀 Deployment

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### CI/CD Pipeline
- **GitHub Actions**: Automated testing and building
- **Firebase App Distribution**: Beta testing distribution
- **Code Quality**: Static analysis and linting

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit changes**: `git commit -m 'Add amazing feature'`
4. **Push to branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful commit messages
- Add tests for new features
- Ensure accessibility compliance

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Sabrina Papeau**
- Email: [sabrina.papeau@example.com](mailto:sabrina.papeau@example.com)
- LinkedIn: [LinkedIn Profile](https://linkedin.com/in/sabrina-papeau)
- GitHub: [@sabrinapapeau](https://github.com/sabrinapapeau)

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Firebase** for comprehensive backend services
- **Material Design** for design guidelines
- **Open Source Community** for valuable packages and inspiration

---

<div align="center">
  <p><strong>Timeless</strong> - Bridging the gap with timeless talent 🌟</p>
  <p>Made with ❤️ and Flutter</p>
</div>

